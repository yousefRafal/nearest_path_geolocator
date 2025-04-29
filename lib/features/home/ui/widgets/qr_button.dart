import 'package:flutter/material.dart';

class DiamondSquare extends StatelessWidget {
  final double size;
  final Color color;

  const DiamondSquare({super.key, this.size = 100, this.color = Colors.blue});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _DiamondPainter(color),
      child: SizedBox(
        height: 70,
        width: 70,
        child: Icon(
          Icons.qr_code,
          size: 30,
          color: Theme.of(context).colorScheme.background,
        ),
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  final Color color;

  _DiamondPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;

    final path =
        Path()
          ..moveTo(size.width / 2, 0) // أعلى (الزاوية الشمالية)
          ..lineTo(size.width, size.height / 2) // يمين (الزاوية الشرقية)
          ..lineTo(size.width / 2, size.height) // أسفل (الزاوية الجنوبية)
          ..lineTo(0, size.height / 2) // يسار (الزاوية الغربية)
          ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
