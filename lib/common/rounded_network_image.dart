import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vector_math/vector_math_64.dart' as math;

class RoundedNetworkImage extends StatelessWidget {
  final double imageSize;
  final String image;
  final double strokeWidth;

  RoundedNetworkImage(
      {@required this.imageSize, @required this.image, this.strokeWidth});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RoundedNetworkImageBorder(width: strokeWidth),
      child: Container(
        width: imageSize,
        height: imageSize,
        child: ClipOval(
          child: CachedNetworkImage(
            placeholder: (context, url) => Shimmer.fromColors(
                child: Container(
                  width: imageSize,
                  height: imageSize,
                  color: Colors.white,
                ),
                baseColor: Colors.grey[300],
                highlightColor: Colors.white),
            imageUrl: image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

class RoundedNetworkImageBorder extends CustomPainter {
  final double width;

  RoundedNetworkImageBorder({this.width});

  @override
  void paint(Canvas canvas, Size size) {
    Offset center = Offset(size.width / 2, size.height / 2);

    Paint borderPaint = Paint()
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    borderPaint.color = Colors.white;

    canvas.drawArc(Rect.fromCircle(center: center, radius: size.width / 2),
        math.radians(-90), math.radians(360), false, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
