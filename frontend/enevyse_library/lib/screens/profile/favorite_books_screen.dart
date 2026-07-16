import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_colors.dart';
import '../explore/widgets/book_list_tile.dart';
import '../home/widgets/book_card.dart';

class FavoriteBooksScreen extends StatefulWidget {
  const FavoriteBooksScreen({super.key});

  @override
  State<FavoriteBooksScreen> createState() => _FavoriteBooksScreenState();
}

class _FavoriteBooksScreenState extends State<FavoriteBooksScreen> {
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookProvider>();

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
          'favorites'.tr(),
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
        child: provider.isLoadingFavorites
            ? const Center(child: CircularProgressIndicator())
            : provider.favoriteBooks.isEmpty
                ? Center(
                    child: Text(
                      'no_favorites'.tr(),
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 16.sp),
                    ),
                  )
                : _isGridView
                    ? GridView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 16.h),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16.h,
                          crossAxisSpacing: 16.w,
                          childAspectRatio: 0.52,
                        ),
                        itemCount: provider.favoriteBooks.length,
                        itemBuilder: (context, index) {
                          return BookCard(
                            book: provider.favoriteBooks[index],
                            isGrid: true,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                            horizontal: 24.w, vertical: 16.h),
                        physics: const BouncingScrollPhysics(),
                        itemCount: provider.favoriteBooks.length,
                        itemBuilder: (context, index) {
                          return BookListTile(
                            book: provider.favoriteBooks[index],
                          );
                        },
                      ),
      ),
    );
  }
}
