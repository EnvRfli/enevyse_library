import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/book.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:go_router/go_router.dart';
import 'book_card.dart';

class TrendingBooksList extends StatelessWidget {
  final String title;
  final List<Book> books;

  const TrendingBooksList(
      {super.key, required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/book-list', extra: {
                    'title': title,
                    'books': books,
                  });
                },
                child: Text(
                  'see_all'.tr(),
                  style: TextStyle(
                    color: const Color(0xFF9E86E1), // Purple accent from image
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // Horizontal List
        SizedBox(
          height: 330.h, // Fixed height to accommodate card content and shadows
          child: ListView.builder(
            padding: EdgeInsets.only(left: 24.w, right: 8.w),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: books.length,
            clipBehavior: Clip.none, // Allow shadows to draw outside bounds
            itemBuilder: (context, index) {
              return BookCard(book: books[index]);
            },
          ),
        ),
      ],
    );
  }
}
