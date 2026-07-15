import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/mock_book.dart';
import '../../theme/app_colors.dart';
import '../../widgets/search_bar_widget.dart';
import '../../widgets/category_chip.dart';
import '../main_layout/logic/main_layout_logic.dart';
import 'widgets/book_list_tile.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if we need to auto-focus the search bar (navigated from Home)
    final autoFocusSearch = Provider.of<MainLayoutLogic>(context, listen: false).consumeSearchFocus();

    // Combine all books for the explore list
    final allBooks = [...mockTrendingBooks, ...mockRecommendedBooks, ...mockNewArrivals];
    
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
            SearchBarWidget(autoFocus: autoFocusSearch),
            SizedBox(height: 20.h),
            
            // Filter and Sort Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Row(
                children: [
                  _buildOutlinedButton(Icons.filter_list_rounded, 'filter'.tr()),
                  SizedBox(width: 12.w),
                  _buildOutlinedButton(Icons.sort_rounded, 'sort'.tr()),
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
                children: [
                  CategoryChip(label: 'all'.tr(), backgroundColor: Colors.transparent, textColor: Colors.white, isSelected: true),
                  CategoryChip(label: 'cat_novel'.tr(), backgroundColor: const Color(0xFFF1E6FA), textColor: const Color(0xFF9E86E1)),
                  CategoryChip(label: 'cat_technology'.tr(), backgroundColor: const Color(0xFFE0F4FA), textColor: const Color(0xFF63B8D9)),
                  CategoryChip(label: 'cat_history'.tr(), backgroundColor: const Color(0xFFE8F9EE), textColor: const Color(0xFF75D9A5)),
                  CategoryChip(label: 'cat_business'.tr(), backgroundColor: const Color(0xFFFDF0E5), textColor: const Color(0xFFD67D55)),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Book List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                physics: const BouncingScrollPhysics(),
                itemCount: allBooks.length,
                itemBuilder: (context, index) {
                  return BookListTile(book: allBooks[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutlinedButton(IconData icon, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: AppColors.textPrimary),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
