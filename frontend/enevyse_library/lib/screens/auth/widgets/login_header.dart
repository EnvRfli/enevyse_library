import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class LoginHeader extends StatelessWidget {
  /// Optional custom subtitle. Falls back to 'sign_in_subtitle'.tr() if null.
  final String? subtitle;
  const LoginHeader({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Vector logo
            Image.asset(
              'assets/images/Vector.png',
              width: 72.w,
              height: 72.w,
              color: Colors.white,
            ),
            SizedBox(height: 20.h),
            Text(
              'welcome'.tr(),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 26.sp,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              subtitle ?? 'sign_in_subtitle'.tr(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 15.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
