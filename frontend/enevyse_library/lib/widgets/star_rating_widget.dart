import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StarRatingWidget extends StatelessWidget {
  final double rating;
  final double size;
  final Color color;

  const StarRatingWidget({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.color = Colors.amber,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: color, size: size.w);
        } else if (index == rating.floor() && rating - rating.floor() > 0) {
          return Icon(Icons.star_half, color: color, size: size.w);
        } else {
          return Icon(Icons.star_border, color: color, size: size.w);
        }
      }),
    );
  }
}
