import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final bool readOnly;
  final VoidCallback? onTap;
  final bool autoFocus;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    this.readOnly = false,
    this.onTap,
    this.autoFocus = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          color:
              const Color(0xFFF2F2F5), // Light gray background like the image
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: TextField(
          readOnly: readOnly,
          onTap: onTap,
          autofocus: autoFocus,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'search_books'.tr(),
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              fontSize: 14.sp,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
              size: 20.w,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            filled: false,
          ),
        ),
      ),
    );
  }
}
