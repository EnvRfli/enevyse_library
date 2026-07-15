import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';
import '../../../models/mock_book.dart';

class BookInfoGrid extends StatelessWidget {
  final MockBook book;

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
            _buildInfoCard('genre'.tr(), book.genre),
            _buildInfoCard('publisher'.tr(), book.publisher),
            _buildInfoCard('published'.tr(), book.year),
            _buildInfoCard('isbn'.tr(), book.isbn),
            _buildInfoCard('language'.tr(), book.language),
            _buildInfoCard('pages'.tr(), book.pages.toString()),
            _buildInfoCard('shelf'.tr(), book.shelf),
            _buildInfoCard(
              'status'.tr(),
              '${book.availableCount} ${'available'.tr()}',
              isStatus: true,
              isAvailable: book.availableCount > 0,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, {bool isStatus = false, bool isAvailable = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF9E86E1).withValues(alpha: 0.6), // Purple accent
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isStatus
                  ? (isAvailable ? const Color(0xFF32B37A) : const Color(0xFFF28C50))
                  : AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
