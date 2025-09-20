import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart';

void main() {
  final int size = 512;
  final img = Image(width: size, height: size);

  // gradient background (vertical)
  final c1 = [10, 12, 32]; // deep navy
  final c2 = [78, 56, 160]; // violet
  for (int y = 0; y < size; y++) {
    final t = y / (size - 1);
    final r = (c1[0] + (c2[0] - c1[0]) * t).toInt();
    final g = (c1[1] + (c2[1] - c1[1]) * t).toInt();
    final b = (c1[2] + (c2[2] - c1[2]) * t).toInt();
    for (int x = 0; x < size; x++) {
      img.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // subtle glow circle (fill) - manual implementation to avoid API mismatch
  _fillCircle(img, size ~/ 2, size ~/ 2 - 20, size ~/ 3, 138, 108, 255, 42);

  // encode
  final out = File('assets/images/landing_fallback.png');
  out.createSync(recursive: true);
  out.writeAsBytesSync(encodePng(img));
  if (kDebugMode) {
    print('Wrote ${out.path}');
  }
}

void _fillCircle(Image img, int cx, int cy, int r, int red, int green, int blue, int alpha) {
  final int r2 = r * r;
  for (int y = -r; y <= r; y++) {
    final yy = cy + y;
    if (yy < 0 || yy >= img.height) continue;
    for (int x = -r; x <= r; x++) {
      final xx = cx + x;
      if (xx < 0 || xx >= img.width) continue;
      if (x * x + y * y <= r2) {
        img.setPixelRgba(xx, yy, red, green, blue, alpha);
      }
    }
  }
}
