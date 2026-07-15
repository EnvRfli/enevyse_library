import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../main_layout/logic/main_layout_logic.dart';
import 'widgets/home_header.dart';
import '../../widgets/search_bar_widget.dart';
import 'widgets/trending_books_list.dart';
import 'widgets/return_reminder_card.dart';

import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      final preferredCategories = user?.preferredCategories ?? [];
      context.read<BookProvider>().fetchHomeBooks(preferredCategories);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: bookProvider.isLoadingHome
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                        // Switch to Explore tab and focus search
                        Provider.of<MainLayoutLogic>(context, listen: false)
                            .triggerSearchFocus();
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Recommended Books List
                    if (bookProvider.recommendedBooks.isNotEmpty) ...[
                      TrendingBooksList(
                        title: 'recommended_for_you'.tr(),
                        books: bookProvider.recommendedBooks,
                      ),
                      SizedBox(height: 12.h),
                    ],

                    // Reminder Card
                    const ReturnReminderCard(),
                    SizedBox(height: 12.h),

                    // New Arrivals List
                    if (bookProvider.newArrivalBooks.isNotEmpty) ...[
                      TrendingBooksList(
                        title: 'new_arrivals'.tr(),
                        books: bookProvider.newArrivalBooks,
                      ),
                      SizedBox(height: 32.h),
                    ],

                    SizedBox(height: 40.h), // Bottom padding
                  ],
                ),
              ),
      ),
    );
  }
}
