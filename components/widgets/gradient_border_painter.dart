import 'package:flutter/material.dart'  hide SearchBar;

class GradientBorderPainter extends CustomPainter {
  final Gradient gradient;
  final Radius? radius;
  final double strokeWidth;

  GradientBorderPainter({
    required this.gradient,
    required this.radius,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);
    final RRect rRect = RRect.fromRectAndRadius(rect, radius ?? Radius.zero);
    final Paint _paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rRect, _paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
