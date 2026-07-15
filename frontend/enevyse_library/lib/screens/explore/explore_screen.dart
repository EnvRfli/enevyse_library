import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../providers/book_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_chip.dart';
import '../main_layout/logic/main_layout_logic.dart';
import 'widgets/book_list_tile.dart';
import 'function/build_outlined_button.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch books on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to auto-focus the search bar (navigated from Home)
    final autoFocusSearch = Provider.of<MainLayoutLogic>(context, listen: false)
        .consumeSearchFocus();

    final provider = context.watch<BookProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'explore_books'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            SizedBox(height: 20.h),

            // Search Bar
            SearchBarWidget(
              autoFocus: autoFocusSearch,
              onChanged: provider.onSearchChanged,
            ),
            SizedBox(height: 20.h),

            // Filter and Sort Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  buildOutlinedButton(Icons.filter_list_rounded, 'filter'.tr()),
                  SizedBox(width: 12.w),
                  buildOutlinedButton(Icons.sort_rounded, 'sort'.tr()),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F2F5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.grid_view_rounded,
                      color: AppColors.textPrimary,
                      size: 20.w,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Categories
            SizedBox(
              height: 40.h,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: provider.categories.map((category) {
                  // Assuming translation keys match 'cat_category', except 'all'
                  String label = category.toLowerCase();
                  if (label != 'all') label = 'cat_$label';
                  return CategoryChip(
                    label: label.tr(),
                    backgroundColor: provider.selectedCategory == category
                        ? AppColors.primary
                        : const Color(0xFFF2F2F5),
                    textColor: provider.selectedCategory == category
                        ? Colors.white
                        : AppColors.textPrimary,
                    isSelected: provider.selectedCategory == category,
                    onTap: () => provider.onCategorySelected(category),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 24.h),

            // Book List
            Expanded(
              child: provider.isLoadingBooks
                  ? const Center(child: CircularProgressIndicator())
                  : provider.booksErrorMessage != null
                      ? Center(
                          child: Text(provider.booksErrorMessage!,
                              style: const TextStyle(color: Colors.red)))
                      : provider.books.isEmpty
                          ? const Center(child: Text('No books found'))
                          : ListView.builder(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              physics: const BouncingScrollPhysics(),
                              itemCount: provider.books.length,
                              itemBuilder: (context, index) {
                                return BookListTile(
                                    book: provider.books[index]);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}
