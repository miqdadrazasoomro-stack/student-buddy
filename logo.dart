import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Student Buddy logo: graduation cap (education) + AI sparkle.
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 72});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final bg = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s), Radius.circular(s * .26));
    canvas.drawRRect(
      bg,
      Paint()
        ..shader = AppColors.heroGradient.createShader(Offset.zero & size),
    );

    final white = Paint()..color = Colors.white;

    final board = Path()
      ..moveTo(s * .5, s * .24)
      ..lineTo(s * .86, s * .42)
      ..lineTo(s * .5, s * .60)
      ..lineTo(s * .14, s * .42)
      ..close();
    canvas.drawPath(board, white);

    final base = Path()
      ..moveTo(s * .28, s * .53)
      ..lineTo(s * .28, s * .68)
      ..quadraticBezierTo(s * .5, s * .80, s * .72, s * .68)
      ..lineTo(s * .72, s * .53)
      ..lineTo(s * .5, s * .62)
      ..close();
    canvas.drawPath(base, Paint()..color = Colors.white.withAlpha(235));

    canvas.drawLine(
      Offset(s * .86, s * .42),
      Offset(s * .86, s * .62),
      Paint()
        ..color = Colors.white
        ..strokeWidth = s * .03
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(s * .86, s * .65), s * .035, white);

    // AI sparkle
    final r = s * .11;
    final c = Offset(s * .74, s * .20);
    final spark = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(spark, Paint()..color = const Color(0xFFBFDBFF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
