import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.menu_book_rounded, 'name': 'borrow_book'.tr(), 'color': const Color(0xFFF1E6FA), 'iconColor': const Color(0xFF9E86E1)},
      {'icon': Icons.access_time_filled_rounded, 'name': 'history'.tr(), 'color': const Color(0xFFE0F4FA), 'iconColor': const Color(0xFF63B8D9)},
      {'icon': Icons.favorite_rounded, 'name': 'favorite_books'.tr(), 'color': const Color(0xFFFDF0E5), 'iconColor': const Color(0xFFF28C50)},
      {'icon': Icons.map_rounded, 'name': 'library_map'.tr(), 'color': const Color(0xFFE8F9EE), 'iconColor': const Color(0xFF75D9A5)},
      {'icon': Icons.confirmation_number_rounded, 'name': 'my_reservations'.tr(), 'color': const Color(0xFFF5E6ED), 'iconColor': const Color(0xFFE892A8)},
      {'icon': Icons.auto_awesome_rounded, 'name': 'explore_more'.tr(), 'color': const Color(0xFFEAF0FA), 'iconColor': const Color(0xFF8B9CEB)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'quick_actions'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.0,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                decoration: BoxDecoration(
                  color: action['color'] as Color,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        action['icon'] as IconData,
                        color: action['iconColor'] as Color,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      action['name'] as String,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
