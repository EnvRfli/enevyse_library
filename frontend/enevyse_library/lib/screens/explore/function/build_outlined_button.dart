import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../theme/app_colors.dart';

Widget buildOutlinedButton(IconData icon, String label) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(20.r),
    ),
    child: Row(
      children: [
        Icon(icon, color: AppColors.textPrimary, size: 20.w),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ],
    ),
  );
}
