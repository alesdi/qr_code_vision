import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_code_vision/qr_code_vision.dart';

final cameras = <CameraDescription>[];
late ui.Image overlayImage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras.addAll(await availableCameras());

  overlayImage = await loadImage('assets/logo.png');
  runApp(const MyApp());
}

class PreviewFrame {
  final ui.Image image;
  final QrLocation? qrLocation;

  PreviewFrame({
    required this.image,
    this.qrLocation,
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
  final locator = QrLocator();

  bool _showDebugOverlay = true;
  bool _showImageOverlay = false;

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
                child: CustomPaint(
                  painter: CameraViewPainter(
                    frame: snapshot.data!,
                    showDebugOverlay: _showDebugOverlay,
                    showImageOverlay: _showImageOverlay,
                  ),
                  size: ui.Size(constraints.maxWidth, constraints.maxWidth),
                ),
                clipBehavior: Clip.hardEdge,
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<void> _processFrame(CameraImage image) async {
    try {
      final bytes = image.planes[0].bytes;
      final qrLocation =
          locator.locate(convertToBinary(bytes, image.width, image.height));

      final completer = Completer();
      ui.decodeImageFromPixels(
        bytes,
        image.width,
        image.height,
        ui.PixelFormat.bgra8888,
        completer.complete,
      );

      _frameStreamController.add(
        PreviewFrame(
          image: await completer.future,
          qrLocation: qrLocation,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}

class CameraViewPainter extends CustomPainter {
  CameraViewPainter({
    required this.frame,
    required this.showDebugOverlay,
    required this.showImageOverlay,
  });

  final PreviewFrame frame;
  final bool showDebugOverlay;
  final bool showImageOverlay;

  @override
  void paint(Canvas canvas, Size size) {
    final finderPatternPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = Colors.red;
    canvas.scale(
        size.width / frame.image.width, size.width / frame.image.width);
    canvas.drawImage(frame.image, Offset.zero, Paint());

    if (frame.qrLocation != null) {
      final topLeftOffset =
          Offset(frame.qrLocation!.topLeft.x, frame.qrLocation!.topLeft.y);
      final bottomLeftOffset = Offset(
          frame.qrLocation!.bottomLeft.x, frame.qrLocation!.bottomLeft.y);
      final topRightOffset =
          Offset(frame.qrLocation!.topRight.x, frame.qrLocation!.topRight.y);
      final alignmentPatternOffset = Offset(
          frame.qrLocation!.alignmentPattern.x,
          frame.qrLocation!.alignmentPattern.y);

      if (showDebugOverlay) {
        final finderPatternSize = frame.qrLocation!.dimension.module * 7 / 2;

        final alignmentPatternSize = frame.qrLocation!.dimension.module * 5 / 2;

        canvas.drawCircle(topLeftOffset, finderPatternSize, finderPatternPaint);

        canvas.drawCircle(
            bottomLeftOffset, finderPatternSize, finderPatternPaint);

        canvas.drawCircle(
            topRightOffset, finderPatternSize, finderPatternPaint);

        canvas.drawCircle(
            alignmentPatternOffset, alignmentPatternSize, finderPatternPaint);
      }

      if (showImageOverlay) {
        final overlaySize =
            max(overlayImage.width, overlayImage.height).toDouble();

        canvas.transform(frame.qrLocation!.toTransformationMatrix(overlaySize));

        canvas.drawImage(overlayImage, Offset.zero, Paint());
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
