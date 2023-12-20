import 'dart:math';
import 'package:flutter/material.dart';

class NightSky extends StatelessWidget {
  const NightSky({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: NightSkyPainter(),
    );
  }
}

class NightSkyPainter extends CustomPainter {
  final Paint _backgroundPaint = Paint()..color = Colors.black;
  final Paint _starPaint = Paint()..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, _backgroundPaint);

    final random = Random();

    for (int i = 0; i < 100; i++) {
      final starX = random.nextDouble() * size.width;
      final starY = random.nextDouble() * size.height;
      final starRadius = random.nextDouble() * 1.5;

      canvas.drawCircle(Offset(starX, starY), starRadius, _starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
