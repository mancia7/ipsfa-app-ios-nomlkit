import 'package:flutter/material.dart';

class DocumentFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    // Rectángulo guía centrado (como marco de documento)
    const double margin = 40;
    final rect = Rect.fromLTWH(
      margin,
      size.height * 0.1,
      size.width - 2 * margin,
      size.height * 0.65,
    );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}