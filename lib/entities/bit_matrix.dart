import 'dart:typed_data';

class BitMatrix {
  final int width;
  final int height;
  final Uint8ClampedList _data;

  static createEmpty(int width, int height) {
    return BitMatrix(Uint8ClampedList(width * height), width);
  }

  BitMatrix(this._data, this.width) : height = (_data.length / width).round();

  bool get(int x, int y) {
    if (x < 0 || x >= width || y < 0 || y >= height) {
      return false;
    }
    return _data[y * width + x] != 0;
  }

  set(int x, int y, bool v) {
    _data[y * width + x] = v ? 1 : 0;
  }

  void setRegion(int left, int top, int width, int height, bool v) {
    for (int y = top; y < top + height; y++) {
      for (int x = left; x < left + width; x++) {
        set(x, y, v);
      }
    }
  }
}
