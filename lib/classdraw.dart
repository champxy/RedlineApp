import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<Offset> points;
  final Color lineColor;
  final double lineWidth;

  LinePainter({
    required this.points,
    required this.lineColor,
    this.lineWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = lineColor
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
