import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget buildFallbackCover(String title) {
  return Align(
    alignment: Alignment.bottomLeft,
    child: Padding(
      padding: EdgeInsets.all(24.w),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
    ),
  );
}
