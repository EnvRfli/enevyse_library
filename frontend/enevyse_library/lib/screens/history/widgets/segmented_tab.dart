import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../theme/app_colors.dart';

class SegmentedTab extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final bool isLeftActive;
  final VoidCallback onLeftTap;
  final VoidCallback onRightTap;

  const SegmentedTab({
    super.key,
    required this.leftLabel,
    required this.rightLabel,
    required this.isLeftActive,
    required this.onLeftTap,
    required this.onRightTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F5), // Light gray background
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Stack(
        children: [
          // Animated Selection Bubble
          AnimatedAlign(
            alignment: isLeftActive ? Alignment.centerLeft : Alignment.centerRight,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Tap Targets and Labels
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onLeftTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                        color: isLeftActive ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: isLeftActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      child: Text(leftLabel),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onRightTap,
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: TextStyle(
                        fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily,
                        color: !isLeftActive ? AppColors.textPrimary : AppColors.textSecondary,
                        fontWeight: !isLeftActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                      child: Text(rightLabel),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
