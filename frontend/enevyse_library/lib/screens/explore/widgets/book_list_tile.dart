import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../models/mock_book.dart';
import '../../../theme/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';

class BookListTile extends StatelessWidget {
  final MockBook book;

  const BookListTile({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/book/${book.id}');
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image Placeholder
            Container(
              width: 80.w,
              height: 110.h,
              decoration: BoxDecoration(
                color: book.placeholderColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(width: 16.w),
            
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          book.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        Icons.bookmark_outline_rounded,
                        color: AppColors.textSecondary,
                        size: 24.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${book.author} · ${book.genre}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 14.w),
                      Icon(Icons.star, color: Colors.amber, size: 14.w),
                      Icon(Icons.star, color: Colors.amber, size: 14.w),
                      Icon(Icons.star, color: Colors.amber, size: 14.w),
                      Icon(Icons.star_half, color: Colors.amber, size: 14.w),
                      SizedBox(width: 4.w),
                      Text(
                        book.rating.toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '${book.availableCount} ${'copies_available'.tr()}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
