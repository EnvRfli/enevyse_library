import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../models/mock_book.dart';
import '../main_layout/logic/main_layout_logic.dart';
import 'widgets/home_header.dart';
import '../../widgets/search_bar_widget.dart';
import 'widgets/trending_books_list.dart';
import 'widgets/return_reminder_card.dart';
import 'widgets/popular_categories.dart';
import 'widgets/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Profile
              const HomeHeader(),
              
              // Search Bar
              SearchBarWidget(
                readOnly: true,
                onTap: () {
                  // Switch to Explore tab (index 1)
                  Provider.of<MainLayoutLogic>(context, listen: false).setIndex(1);
                },
              ),
              SizedBox(height: 24.h),
              
              // Trending Books List
              TrendingBooksList(
                title: 'trending_books'.tr(),
                books: mockTrendingBooks,
              ),
              
              // Reminder Card
              const ReturnReminderCard(),
              
              // Recommended Books List
              TrendingBooksList(
                title: 'recommended_for_you'.tr(),
                books: mockRecommendedBooks,
              ),
              SizedBox(height: 24.h),

              // New Arrivals List
              TrendingBooksList(
                title: 'new_arrivals'.tr(),
                books: mockNewArrivals,
              ),
              SizedBox(height: 32.h),

              // Popular Categories
              const PopularCategories(),
              SizedBox(height: 32.h),

              // Quick Actions
              const QuickActions(),
              
              SizedBox(height: 40.h), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}

