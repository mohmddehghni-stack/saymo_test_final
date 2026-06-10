import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.white.withOpacity(.12);

    final path1 = Path();

    path1.moveTo(0, size.height * .55);

    path1.quadraticBezierTo(
      size.width * .25,
      size.height * .35,
      size.width * .5,
      size.height * .55,
    );

    path1.quadraticBezierTo(
      size.width * .75,
      size.height * .75,
      size.width,
      size.height * .45,
    );

    path1.lineTo(size.width, size.height);
    path1.lineTo(0, size.height);
    path1.close();

    canvas.drawPath(path1, paint1);

    final paint2 = Paint()..color = Colors.white.withOpacity(.18);

    final path2 = Path();

    path2.moveTo(0, size.height * .75);

    path2.quadraticBezierTo(
      size.width * .30,
      size.height * .55,
      size.width * .55,
      size.height * .78,
    );

    path2.quadraticBezierTo(
      size.width * .80,
      size.height,
      size.width,
      size.height * .70,
    );

    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
