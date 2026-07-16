import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../models/book.dart';
import '../../../theme/app_colors.dart';
import '../explore/widgets/book_list_tile.dart';
import 'widgets/book_card.dart';

class BookListScreen extends StatefulWidget {
  final String title;
  final List<Book> books;

  const BookListScreen({
    super.key,
    required this.title,
    required this.books,
  });

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  bool _isGridView = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: widget.books.isEmpty
            ? Center(
                child: Text(
                  'No books found',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 16.sp),
                ),
              )
            : _isGridView
                ? GridView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    physics: const BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16.h,
                      crossAxisSpacing: 16.w,
                      childAspectRatio: 0.52,
                    ),
                    itemCount: widget.books.length,
                    itemBuilder: (context, index) {
                      return BookCard(
                        book: widget.books[index],
                        isGrid: true,
                      );
                    },
                  )
                : ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: widget.books.length,
                    itemBuilder: (context, index) {
                      return BookListTile(
                        book: widget.books[index],
                      );
                    },
                  ),
      ),
    );
  }
}
