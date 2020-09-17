import 'package:flutter/material.dart';
import 'package:photonix_app/styles/colors.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class RoundedImageWidget extends StatelessWidget {
  final double imageSize;
  final String image;

  const RoundedImageWidget({Key key, this.imageSize, this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RoundedImageBorder(),
      child: Container(
        width: imageSize,
        height: imageSize,
        child: ClipOval(
          child: Image.asset(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class RoundedImageBorder extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    borderPaint.color = secondColor;

    canvas.drawArc(Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90), math.radians(360), false, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
