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
import '../home/widgets/book_card.dart'; // Import BookCard for grid view
import 'function/build_outlined_button.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/sort_bottom_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isGridView = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Fetch books on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchBooks();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        context.read<BookProvider>().fetchBooks(isRefresh: false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if we need to auto-focus the search bar (navigated from Home)
    final autoFocusSearch = Provider.of<MainLayoutLogic>(context, listen: false)
        .consumeSearchFocus();

    final provider = context.watch<BookProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'explore_books'.tr(),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

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
                  buildOutlinedButton(
                    Icons.filter_list_rounded,
                    'filter'.tr(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => FilterBottomSheet(
                          initialRating: provider.selectedMinRating,
                          onApply: (rating) {
                            provider.onMinRatingSelected(rating);
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 12.w),
                  buildOutlinedButton(
                    Icons.sort_rounded,
                    'sort'.tr(),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => SortBottomSheet(
                          initialSortBy: provider.selectedSortBy,
                          onApply: (sortBy) {
                            provider.onSortBySelected(sortBy);
                          },
                        ),
                      );
                    },
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F2F5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isGridView
                            ? Icons.view_list_rounded
                            : Icons.grid_view_rounded,
                        color: AppColors.textPrimary,
                        size: 20.w,
                      ),
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
              child: provider.isLoadingBooks && provider.books.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.booksErrorMessage != null && provider.books.isEmpty
                      ? Center(
                          child: Text(provider.booksErrorMessage!,
                              style: const TextStyle(color: Colors.red)))
                      : provider.books.isEmpty
                          ? const Center(child: Text('No books found'))
                          : _isGridView
                              ? GridView.builder(
                                  controller: _scrollController,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  physics: const BouncingScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 16.h,
                                    crossAxisSpacing: 16.w,
                                    childAspectRatio: 0.52,
                                  ),
                                  itemCount: provider.books.length + (provider.isFetchingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == provider.books.length) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    // Use BookCard for grid view
                                    return BookCard(
                                        book: provider.books[index],
                                        isGrid: true);
                                  },
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 24.w),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: provider.books.length + (provider.isFetchingMore ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == provider.books.length) {
                                      return Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16.h),
                                        child: const Center(
                                            child: CircularProgressIndicator()),
                                      );
                                    }
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
