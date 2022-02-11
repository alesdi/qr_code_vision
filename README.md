This package provides both high-level and low-level functions to extract QR code
data from an image, including its location, type and content. In addition, it
can be used to efficiently track a QR code position and content between frames,
e.g. for AR (Augmented Reality) applications in Flutter. qr_code_vision is
written in pure Dart, and is based on the popular jsQR javascript QR reader.

## Features

![Screen recording of the example](https://user-images.githubusercontent.com/54476193/153677665-7df21310-d46d-498a-8a21-5b22e7eef043.gif)

This package is still in early development: it could be subject to radical
changes and many features are incomplete or not thoroughly tested.

## Usage

In order to locate and decode QR code in an image, you need to first obtain its
byte data in an RGBA format. This can be done in many ways depending on the
image source and format. for example for a dart:ui `Image` you can use the
`toByteData()` method.. Then just instantiate a new `QrCode` object and call
`scanRgbaBytes(imageData, imageWidth, imageHeight)` to attempt to locate and decode the QR code:

```dart
// Let frames be a list dart:ui images
final List<ui.Image> frames = getSomeCameraFrames();

final qrCode = QrCode();

for(final frame in frames){
    final byteData =
        (await frame.toByteData(format: ui.ImageByteFormat.rawRgba))!
            .buffer
            .asUint8List();
    qrCode.scanRgbaBytes(byteData, frame.width, frame.height);

    if(qrCode.location == null){
        print('No QR code found');
    }else{
        print('QR code here: ${qrCode.location}');

        if(qrCode.content == null){
            print('The content of the QR code could not be decoded');
        }else{
            print('This is the content: ${qrCode.content.text}');
        }
    }
}
```

The `location` property contains extensive information, including position of
the finder and alignment patterns in the image and size. The
`computePerspectiveTransform` method can be used to obtain a
`PerspectiveTransform` object that describes the perspective transformation of
the QR code and can be used to transform AR elements accordingly (a
`to3DPerspectiveMatrix()` returns an equivalent 4x4 transformation matrix that
can be used for example with the `Transform` widget or `Canvas` transform
method). Refer to the `example` for more details on how to use this package for
simple AR applications.

Note that the qr code location will be updated if the correct pattern is
identified, even if the content cannot be read. To avoid this behavior, you can
pass the optional `ignoreIfUnreadable` parameter. In addition, content will be
cached for a certain number of frames in case of decoding errors. This can be
controlled with the `contentCacheLimit` parameter of the `QrCode` constructor or
by passing the `invalidateContentCache` flag when calling `scanRgbaBytes`.

## Missing features and future developments

- The package currently supports only a single QR code. Multiple QR codes in the
  same image will lead to unstable and mostly incorrect results.

- Many improvements could be made to take advantage of multi-frame scanning, for
  example to select the best finder patterns based on the previous QR code
  position, or rejecting evident glitches

- Performance can be very poor for large images, especially with high noise
  content

- Code could be greatly optimized and refactored to comply with Dart best
  practices (most of the code still closely resembles the original jsQR
  TypeScript code)

Pull requests are very welcome.
