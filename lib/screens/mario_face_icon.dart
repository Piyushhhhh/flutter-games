import 'package:flutter/material.dart';

/// A custom widget that paints a simple Mario face (red cap, skin, mustache, eyes, 'M').
class MarioFaceIcon extends StatelessWidget {
  const MarioFaceIcon({Key? key, this.size = 40}) : super(key: key);
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MarioFacePainter(),
      ),
    );
  }
}

class _MarioFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Draw face (skin)
    final facePaint = Paint()..color = const Color(0xFFFFE0B2);
    canvas.drawOval(Rect.fromLTWH(w * 0.15, h * 0.35, w * 0.7, h * 0.5), facePaint);

    // Draw cap (red)
    final capPaint = Paint()..color = Colors.red;
    canvas.drawArc(Rect.fromLTWH(w * 0.05, h * 0.1, w * 0.9, h * 0.6),
      3.14, 3.14, false, capPaint);

    // Cap rim (darker red)
    final rimPaint = Paint()..color = Colors.red.shade700;
    canvas.drawOval(Rect.fromLTWH(w * 0.18, h * 0.32, w * 0.64, h * 0.18), rimPaint);

    // Draw white circle for 'M'
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.5, h * 0.32), w * 0.13, whitePaint);

    // Draw 'M' (red)
    final mPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;
    final mPath = Path();
    mPath.moveTo(w * 0.44, h * 0.32);
    mPath.lineTo(w * 0.47, h * 0.28);
    mPath.lineTo(w * 0.5, h * 0.32);
    mPath.lineTo(w * 0.53, h * 0.28);
    mPath.lineTo(w * 0.56, h * 0.32);
    canvas.drawPath(mPath, mPaint);

    // Eyes
    final eyePaint = Paint()..color = Colors.black;
    canvas.drawOval(Rect.fromLTWH(w * 0.36, h * 0.52, w * 0.08, h * 0.13), eyePaint);
    canvas.drawOval(Rect.fromLTWH(w * 0.56, h * 0.52, w * 0.08, h * 0.13), eyePaint);

    // Mustache
    final mustachePaint = Paint()
      ..color = Colors.brown.shade900
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    final mustachePath = Path();
    mustachePath.moveTo(w * 0.37, h * 0.7);
    mustachePath.quadraticBezierTo(w * 0.5, h * 0.78, w * 0.63, h * 0.7);
    canvas.drawPath(mustachePath, mustachePaint);

    // Nose
    final nosePaint = Paint()..color = const Color(0xFFF8C99E);
    canvas.drawOval(Rect.fromLTWH(w * 0.44, h * 0.6, w * 0.12, h * 0.11), nosePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
