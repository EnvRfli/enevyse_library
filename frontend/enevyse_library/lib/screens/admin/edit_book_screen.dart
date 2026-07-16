import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../theme/app_colors.dart';
import '../../repository/book_repository.dart';
import '../home/widgets/book_card.dart';
import '../explore/widgets/book_list_tile.dart';
import 'logic/manage_books_logic.dart';

class EditBookScreen extends StatelessWidget {
  const EditBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ManageBooksLogic(BookRepository()),
      child: const _EditBookListView(),
    );
  }
}

class _EditBookListView extends StatefulWidget {
  const _EditBookListView();

  @override
  State<_EditBookListView> createState() => _EditBookListViewState();
}

class _EditBookListViewState extends State<_EditBookListView> {
  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<ManageBooksLogic>();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'manage_books'.tr(),
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
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: TextField(
                controller: logic.searchController,
                decoration: InputDecoration(
                  hintText: 'search_book_title'.tr(),
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.r),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
                ),
                onChanged: (_) => logic.onSearchChanged(),
              ),
            ),
            
            Expanded(
              child: logic.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : logic.books.isEmpty
                      ? Center(
                          child: Text(
                            'No books found.',
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16.sp),
                          ),
                        )
                      : _isGridView
                          ? GridView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 16.h),
                              physics: const BouncingScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 16.h,
                                crossAxisSpacing: 16.w,
                                childAspectRatio: 0.52,
                              ),
                              itemCount: logic.books.length,
                              itemBuilder: (context, index) {
                                return _buildBookItem(
                                    context, logic.books[index], true);
                              },
                            )
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24.w, vertical: 16.h),
                              physics: const BouncingScrollPhysics(),
                              itemCount: logic.books.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: _buildBookItem(
                                      context, logic.books[index], false),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookItem(BuildContext context, book, bool isGrid) {
    return GestureDetector(
      onTap: () {
        context.push('/admin/edit-book/form/${book.id}');
      },
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            child: isGrid
                ? BookCard(book: book, isGrid: true)
                : BookListTile(book: book),
          ),
          Positioned(
            top: 12.h,
            right: isGrid ? 12.w : 24.w,
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  color: AppColors.primary,
                  onTap: () {
                    context.push('/admin/edit-book/form/${book.id}');
                  },
                ),
                SizedBox(width: 6.w),
                _buildActionButton(
                  icon: Icons.delete,
                  color: Colors.red,
                  onTap: () {
                    _showDeleteDialog(context, book);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(6.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 18.w),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, book) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete Book',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'ingin menghapus data buku ini?',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          final logic = context.read<ManageBooksLogic>();
                          final success = await logic.deleteBook(book.id);
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('book_successfully_deleted'.tr())),
                            );
                          } else if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('failed_delete_book'.tr())),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'Ya',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
