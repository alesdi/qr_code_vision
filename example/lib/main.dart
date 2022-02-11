import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_vision/qr_code_vision.dart';

final cameras = <CameraDescription>[];
late ui.Image overlayImage;
late ui.Image demoImage;
late Uint8List demoImageBytes;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras.addAll(await availableCameras());

  overlayImage = await loadImage('assets/logo.png');
  demoImage = await loadImage('assets/demo.png');
  demoImageBytes =
      (await demoImage.toByteData(format: ui.ImageByteFormat.rawRgba))!
          .buffer
          .asUint8List();
  runApp(const MyApp());
}

class PreviewFrame {
  final ui.Image image;
  final QrCode? qrCode;

  PreviewFrame({
    required this.image,
    this.qrCode,
  });
}

Future<ui.Image> loadImage(final String assetPath) async {
  final data = await rootBundle.load(assetPath);
  final list = Uint8List.view(data.buffer);
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(list, completer.complete);
  return completer.future;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Vision Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late CameraController _cameraController;

  final _frameStreamController = StreamController<PreviewFrame>();

  bool _showDebugOverlay = true;
  bool _showImageOverlay = false;
  bool _useDemoImage = false;
  final qrCode = QrCode();

  bool _processFrameReady = true;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);

    _cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _cameraController.startImageStream(_processFrame);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _frameStreamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_cameraController.value.isInitialized) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Vision Demo"),
      ),
      body: ListView(
        children: [
          _buildPreview(),
          SwitchListTile(
            value: _showDebugOverlay,
            onChanged: (value) {
              setState(() {
                _showDebugOverlay = value;
              });
            },
            title: const Text("Show debug overlay"),
          ),
          SwitchListTile(
            value: _showImageOverlay,
            onChanged: (value) {
              setState(() {
                _showImageOverlay = value;
              });
            },
            title: const Text("Show image overlay"),
          ),
          SwitchListTile(
            value: _useDemoImage,
            onChanged: (value) {
              setState(() {
                _useDemoImage = value;
              });
            },
            title: const Text("Use demo image"),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return StreamBuilder<PreviewFrame>(
      stream: _frameStreamController.stream,
      initialData: null,
      builder: (context, snapshot) => snapshot.data != null
          ? LayoutBuilder(
              builder: (context, constraints) => ClipRect(
                child: _buildFrame(
                    snapshot.data!, constraints.maxWidth, constraints.maxWidth),
                clipBehavior: Clip.hardEdge,
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Widget _buildFrame(PreviewFrame frame, double width, double height) {
    final scaleFactor = width / frame.image.width.toDouble();

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        CustomPaint(
          painter: CameraViewPainter(frame: frame),
          size: ui.Size(width, height),
        ),
        (_showImageOverlay && frame.qrCode != null)
            ? _buildImageOverlay(frame.qrCode!, scaleFactor)
            : Container(),
        (_showDebugOverlay && frame.qrCode != null)
            ? CustomPaint(
                painter: DebugOverlayPainter(frame: frame),
                size: ui.Size(width, height),
              )
            : Container()
      ],
    );
  }

  Widget _buildImageOverlay(QrCode qrCode, double scaleFactor) {
    final transformMatrix =
        qrCode.location?.computePerspectiveTransform().to3DPerspectiveMatrix();

    final scaledTransformationMatrix = transformMatrix != null
        ? Matrix4.diagonal3Values(scaleFactor, scaleFactor, scaleFactor) *
            Matrix4.fromFloat64List(transformMatrix)
        : null;

    final content = qrCode.content?.text;
    final qrCodeSize = qrCode.location?.dimension.size.toDouble();

    // Check if content is a url
    final url = content != null ? Uri.tryParse(content) : null;

    if (qrCodeSize != null && url != null) {
      return Transform(
        alignment: Alignment.topLeft,
        transform: scaledTransformationMatrix,
        child: Image.network(
          url.toString(),
          width: qrCodeSize,
          height: qrCodeSize,
          errorBuilder:
              (BuildContext context, Object exception, StackTrace? stackTrace) {
            return SizedBox(
              height: qrCodeSize,
              width: qrCodeSize,
              child: Center(
                child: Icon(
                  Icons.image_not_supported,
                  size: qrCodeSize * 0.5,
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (!_processFrameReady) {
      return;
    }
    _processFrameReady = false;
    try {
      final width = _useDemoImage ? demoImage.width : image.width;
      final height = _useDemoImage ? demoImage.height : image.height;
      final bytes = _useDemoImage ? demoImageBytes : image.planes[0].bytes;

      qrCode.scanRgbaBytes(bytes, width, height);

      final completer = Completer();
      ui.decodeImageFromPixels(
        bytes,
        width,
        height,
        ui.PixelFormat.bgra8888,
        completer.complete,
      );

      _frameStreamController.add(
        PreviewFrame(
          image: await completer.future,
          qrCode: qrCode,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _processFrameReady = true;
  }
}

class CameraViewPainter extends CustomPainter {
  CameraViewPainter({required this.frame});

  final PreviewFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final finderPatternPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;
    canvas.scale(
        size.width / frame.image.width, size.width / frame.image.width);
    canvas.drawImage(frame.image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class DebugOverlayPainter extends CustomPainter {
  DebugOverlayPainter({required this.frame});

  final PreviewFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    final finderPatternPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;
    canvas.scale(
        size.width / frame.image.width, size.width / frame.image.width);

    if (frame.qrCode != null && frame.qrCode!.location != null) {
      final location = frame.qrCode!.location!;

      final topLeftOffset = Offset(location.topLeft.x, location.topLeft.y);
      final bottomLeftOffset =
          Offset(location.bottomLeft.x, location.bottomLeft.y);
      final topRightOffset = Offset(location.topRight.x, location.topRight.y);
      final alignmentPatternOffset =
          Offset(location.alignmentPattern.x, location.alignmentPattern.y);

      final finderPatternSize = location.dimension.module * 7 / 2;

      final alignmentPatternSize = location.dimension.module * 5 / 2;

      canvas.drawCircle(topLeftOffset, finderPatternSize, finderPatternPaint);

      canvas.drawCircle(
          bottomLeftOffset, finderPatternSize, finderPatternPaint);

      canvas.drawCircle(topRightOffset, finderPatternSize, finderPatternPaint);

      canvas.drawCircle(
          alignmentPatternOffset, alignmentPatternSize, finderPatternPaint);

      canvas.transform(
          location.computePerspectiveTransform().to3DPerspectiveMatrix());
      final targetSize = location.dimension.size.toDouble();
      final textStyle = TextStyle(
        color: Colors.red,
        fontSize: targetSize * 0.1,
      );
      final textSpan = TextSpan(
        text: frame.qrCode!.content?.text,
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: targetSize,
      );

      canvas.drawRect(
        Rect.fromLTWH(0, 0, targetSize, targetSize),
        Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = Colors.red,
      );

      textPainter.paint(canvas, Offset(0, targetSize * 1.1));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
