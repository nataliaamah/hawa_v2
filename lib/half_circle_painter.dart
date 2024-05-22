import 'package:flutter/material.dart';

class HalfCirclePainter extends CustomPainter {
  final Color color;

  HalfCirclePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw a half-circle
    final path = Path()
      ..moveTo(0, 0)
      ..arcToPoint(
        Offset(size.width, size.height),
        radius: Radius.circular(size.width / 2),
        clockwise: false,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
