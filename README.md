This package provides both high-level and low-level functions to extract QR code
data from an image, including its location, type and content. In addition, it
can be used to efficiently track a QR code position between frames, that can be
used for AR (Augmented Reality) applications in Flutter. qr_code_vision is
written in pure Dart, and is based on the popular jsQR javascript QR reader.

## Features

https://user-images.githubusercontent.com/54476193/150672495-f2def04c-5e60-4531-9c49-e2dfc72bab7b.mp4

This package is still in early development, and most features are not
implemented yet. Currently, you will be able to only locate a QR code in an
image, extracting the position of its finder patterns and alignment pattern.
This information already allows to build basic AR applications like the one in
the example.

Decoding the QR code content and handling multiple QR codes in a single image is
not yet implemented.

## Usage

In order to locate a QR code in an image, you need to first obtain a binary
version, represented by a `BitMatrix` object. You can use the
`convertToBinary()` function to turn any RGBA byte list (obtained from a
`dart:ui` `Image` object for example) into a `BitMatrix`.

```dart
// Let `image` be a `dart:ui` `Image` object
final BitMatrix bitMatrix = convertToBinary(image.toByteData());
```

In order to search and extract a QR location from the image, use the `locate()`
method of the `QrLocator` class.

```dart
final QrLocator locator = QrLocator();
final QrLocation location = locator.locate(bitMatrix);

if(location == null){
    print('No QR code found');
}else{
    print('QR code indentified!');
    print('- Top-left finder pattern: ${location.topLeft}');
    print('- Top-right finder pattern: ${location.topRight}');
    print('- Bottom-left finder pattern: ${location.bottomLeft}');
    print('- Alignment pattern: ${location.alignmentPattern}');
}
```

Location information can then be used to compute the QR code 4x4 transformation
matrix (at this time, only affine transformation is supported, based on the
finder patterns). Such matrix can be used to easily draw AR content over the QR
code in a Flutter application. Refer to the `example` for more details.
