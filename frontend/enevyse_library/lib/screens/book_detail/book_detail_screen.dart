import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/mock_book.dart';
import '../../theme/app_colors.dart';
import 'widgets/book_info_grid.dart';
import 'widgets/expandable_synopsis.dart';
import 'widgets/reviews_section.dart';

class BookDetailScreen extends StatelessWidget {
  final String id;

  const BookDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    // In a real app, fetch from a repository. Here we find it from mock data.
    final allBooks = [...mockTrendingBooks, ...mockRecommendedBooks, ...mockNewArrivals];
    final book = allBooks.firstWhere(
      (b) => b.id == id,
      orElse: () => allBooks.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(bottom: 100.h), // Space for bottom button
              child: Column(
                children: [
                  // Header Bar
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: AppColors.textPrimary,
                          onPressed: () => context.pop(),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_outline_rounded),
                          color: AppColors.textPrimary,
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),

                  // Cover Image
                  Hero(
                    tag: 'book_cover_${book.id}',
                    child: Container(
                      width: 220.w,
                      height: 300.h,
                      decoration: BoxDecoration(
                        color: book.placeholderColor,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: book.placeholderColor.withValues(alpha: 0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Text(
                            book.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.sp,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Title and Author
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        Text(
                          book.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'by ${book.author}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16.w),
                            Icon(Icons.star, color: Colors.amber, size: 16.w),
                            Icon(Icons.star, color: Colors.amber, size: 16.w),
                            Icon(Icons.star, color: Colors.amber, size: 16.w),
                            Icon(Icons.star_half, color: Colors.amber, size: 16.w),
                            SizedBox(width: 8.w),
                            Text(
                              '${book.rating} · 2,340 reviews',
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // Content Sections
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BookInfoGrid(book: book),
                        SizedBox(height: 32.h),
                        ExpandableSynopsis(description: book.description),
                        SizedBox(height: 32.h),
                        const ReviewsSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Action Button
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.9),
                    Colors.white,
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B9CEB), // Soft Indigo
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: Text(
                      'borrow_book'.tr(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
