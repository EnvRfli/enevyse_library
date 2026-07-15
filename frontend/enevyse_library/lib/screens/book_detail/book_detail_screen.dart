import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_colors.dart';
import 'widgets/book_info_grid.dart';
import 'widgets/expandable_synopsis.dart';
import 'widgets/reviews_section.dart';
import 'function/build_fallback_cover.dart';

class BookDetailScreen extends StatefulWidget {
  final String id;

  const BookDetailScreen({super.key, required this.id});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchBookDetails(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();

    if (provider.isLoadingBookDetail) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.bookDetailErrorMessage != null ||
        provider.selectedBook == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, elevation: 0),
        body: Center(
            child: Text(provider.bookDetailErrorMessage ?? 'Book not found',
                style: const TextStyle(color: Colors.red))),
      );
    }

    final book = provider.selectedBook!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding:
                  EdgeInsets.only(bottom: 100.h), // Space for bottom button
              child: Column(
                children: [
                  // Header Bar
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Image.network(
                                book.coverUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    buildFallbackCover(book.title),
                              ),
                            )
                          : buildFallbackCover(book.title),
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
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'by ${book.author}',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
                            Icon(Icons.star_half,
                                color: Colors.amber, size: 16.w),
                            SizedBox(width: 8.w),
                            Text(
                              '${book.ratings} · 2,340 reviews',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
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
                        ExpandableSynopsis(description: book.synopsis),
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
                    onPressed: () {
                      context.push('/borrow/${book.id}');
                    },
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
