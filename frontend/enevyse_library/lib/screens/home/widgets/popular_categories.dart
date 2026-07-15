import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../widgets/category_chip.dart';

class PopularCategories extends StatelessWidget {
  const PopularCategories({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'cat_novel'.tr(), 'color': const Color(0xFFF1E6FA), 'textColor': const Color(0xFF9E86E1)},
      {'name': 'cat_technology'.tr(), 'color': const Color(0xFFE0F4FA), 'textColor': const Color(0xFF63B8D9)},
      {'name': 'cat_history'.tr(), 'color': const Color(0xFFE8F9EE), 'textColor': const Color(0xFF75D9A5)},
      {'name': 'cat_business'.tr(), 'color': const Color(0xFFFDF0E5), 'textColor': const Color(0xFFD67D55)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            'popular_categories'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        SizedBox(height: 16.h),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return CategoryChip(
                label: cat['name'] as String,
                backgroundColor: cat['color'] as Color,
                textColor: cat['textColor'] as Color,
              );
            },
          ),
        ),
      ],
    );
  }
}

