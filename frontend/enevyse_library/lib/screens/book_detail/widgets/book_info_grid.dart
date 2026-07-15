import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';
import '../../../models/book.dart';
import '../function/build_info_card.dart';

class BookInfoGrid extends StatelessWidget {
  final Book book;

  const BookInfoGrid({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'book_information'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        SizedBox(height: 16.h),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          children: [
            buildInfoCard('category'.tr(), book.categories.isNotEmpty ? book.categories.first : '-'),
            buildInfoCard('publisher'.tr(), book.publisher.isNotEmpty ? book.publisher : '-'),
            buildInfoCard('published'.tr(), book.published != null ? book.published!.year.toString() : '-'),
            buildInfoCard('language'.tr(), book.language.isNotEmpty ? book.language : '-'),
            buildInfoCard('pages'.tr(), book.totalPages.toString()),
            buildInfoCard(
              'status'.tr(),
              '${book.availableCopies} ${'available'.tr()}',
              isStatus: true,
              isAvailable: book.availableCopies > 0,
            ),
          ],
        ),
      ],
    );
  }
}
