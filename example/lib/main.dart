/// This example illustrates how to build a simple AR Flutter app that uses the
/// qr_code_vision Dart package to locate and decode a QR code and, if it
/// contains the URL to an image, display it right on top of the code, with
/// accurate perspective and dimensions.
import 'dart:async';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_vision/qr_code_vision.dart';

final cameras = <CameraDescription>[];
late ui.Image overlayImage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras.addAll(await availableCameras());

  runApp(const MyApp());
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

  final _scannedFrameStreamController = StreamController<_ScannedFrame>();

  bool _showDebugOverlay = true;
  bool _showImageOverlay = false;
  bool _processFrameReady = true;

  // The scanned QR code
  final _qrCode = QrCode();

  @override
  void initState() {
    super.initState();
    // Initialize camera stream and listen to captured frames
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
          const ListTile(
            title:
                Text("Point your camera at a QR code containing an image URL."),
          ),
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
    return StreamBuilder<_ScannedFrame>(
      stream: _scannedFrameStreamController.stream,
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

  Widget _buildFrame(_ScannedFrame frame, double width, double height) {
    final scaleFactor = width / frame.image.width.toDouble();

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        CustomPaint(
          painter: _CameraViewPainter(frame: frame),
          size: ui.Size(width, height),
        ),
        (_showImageOverlay && frame.qrCode != null)
            ? _buildImageOverlay(frame.qrCode!, scaleFactor)
            : Container(),
        (_showDebugOverlay && frame.qrCode != null)
            ? CustomPaint(
                painter: _DebugOverlayPainter(frame: frame),
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

  /// Process a captured frame and scan it for QR codes
  Future<void> _processFrame(CameraImage cameraFrame) async {
    // Skip this frame if another frame is already being processed
    // (otherwise simultaneous processes could accumulate, leading to memory
    // leaks and crashes)
    if (!_processFrameReady) {
      return;
    }
    _processFrameReady = false;

    try {
      final width = cameraFrame.width;
      final height = cameraFrame.height;
      Uint8List bytes = Uint8List(cameraFrame.planes[0].bytes.length);

      if (cameraFrame.format.group == ImageFormatGroup.yuv420) {
        List<Uint8List> planes = ImageProcessingUtilities.getPlanes(cameraFrame);
        bytes = ImageProcessingUtilities.yuv420ToRgba8888(planes, width, height);
      } else if (cameraFrame.format.group == ImageFormatGroup.bgra8888) {
        bytes = cameraFrame.planes[0].bytes;
      }
      final image =
          await ImageProcessingUtilities.createImage(bytes, width, height, ui.PixelFormat.rgba8888);

      // Update the QR code by scanning the image content
      _qrCode.scanRgbaBytes(bytes, width, height);

      // Publish an update for the UI
      _scannedFrameStreamController.add(
        _ScannedFrame(
          image: image,
          qrCode: _qrCode,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }

    // Raise the flag to allow another frame to be processed
    _processFrameReady = true;
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scannedFrameStreamController.close();
    super.dispose();
  }
}

/// A frame scanned for QR codes
class _ScannedFrame {
  final ui.Image image;
  final QrCode? qrCode;

  _ScannedFrame({
    required this.image,
    this.qrCode,
  });
}

/// A custom painter to show the camera frames
class _CameraViewPainter extends CustomPainter {
  _CameraViewPainter({required this.frame});

  final _ScannedFrame frame;

  @override
  void paint(Canvas canvas, Size size) {
    Paint()
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

/// A custom painter to show the debug overlays (such as finder patterns)
/// over the camera image
class _DebugOverlayPainter extends CustomPainter {
  _DebugOverlayPainter({required this.frame});

  final _ScannedFrame frame;

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

class ImageProcessingUtilities {
  static List<Uint8List> getPlanes(CameraImage cameraFrame) {
    List<Uint8List> planes = [];
    for (int planeIndex = 0; planeIndex < 3; planeIndex++) {
      Uint8List buffer;
      int width;
      int height;
      if (planeIndex == 0) {
        width = cameraFrame.width;
        height = cameraFrame.height;
      } else {
        width = cameraFrame.width ~/ 2;
        height = cameraFrame.height ~/ 2;
      }

      buffer = Uint8List(width * height);

      int pixelStride = cameraFrame.planes[planeIndex].bytesPerPixel!;
      int rowStride = cameraFrame.planes[planeIndex].bytesPerRow;
      int index = 0;
      for (int i = 0; i < height; i++) {
        for (int j = 0; j < width; j++) {
          buffer[index++] = cameraFrame
              .planes[planeIndex].bytes[i * rowStride + j * pixelStride];
        }
      }

      planes.add(buffer);
    }
    return planes;
  }

  static Uint8List yuv420ToRgba8888(
      List<Uint8List> planes, int width, int height) {
    final yPlane = planes[0];
    final uPlane = planes[1];
    final vPlane = planes[2];

    final Uint8List rgbaBytes = Uint8List(width * height * 4);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int yIndex = y * width + x;
        final int uvIndex = (y ~/ 2) * (width ~/ 2) + (x ~/ 2);

        final int yValue = yPlane[yIndex] & 0xFF;
        final int uValue = uPlane[uvIndex] & 0xFF;
        final int vValue = vPlane[uvIndex] & 0xFF;

        final int r = (yValue + 1.13983 * (vValue - 128)).round().clamp(0, 255);
        final int g =
            (yValue - 0.39465 * (uValue - 128) - 0.58060 * (vValue - 128))
                .round()
                .clamp(0, 255);
        final int b = (yValue + 2.03211 * (uValue - 128)).round().clamp(0, 255);

        final int rgbaIndex = yIndex * 4;
        rgbaBytes[rgbaIndex] = r.toUnsigned(8);
        rgbaBytes[rgbaIndex + 1] = g.toUnsigned(8);
        rgbaBytes[rgbaIndex + 2] = b.toUnsigned(8);
        rgbaBytes[rgbaIndex + 3] = 255; // Alpha value
      }
    }

    return rgbaBytes;
  }

  static Future<ui.Image> createImage(
      Uint8List buffer, int width, int height, ui.PixelFormat pixelFormat) {
    final Completer<ui.Image> completer = Completer();

    ui.decodeImageFromPixels(buffer, width, height, pixelFormat,
        (ui.Image img) {
      completer.complete(img);
    });

    return completer.future;
  }
}
