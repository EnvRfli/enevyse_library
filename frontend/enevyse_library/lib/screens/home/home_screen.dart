import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../main_layout/logic/main_layout_logic.dart';
import 'widgets/home_header.dart';
import '../../widgets/search_bar_widget.dart';
import 'widgets/trending_books_list.dart';
import 'widgets/return_reminder_card.dart';
import 'widgets/home_shimmer.dart';
import '../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/book_provider.dart';
import '../../providers/transaction_provider.dart';

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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final user = context.read<AuthProvider>().currentUser;
    final preferredCategories = user?.preferredCategories ?? [];
    await Future.wait([
      context.read<BookProvider>().fetchHomeBooks(preferredCategories),
      context.read<BookProvider>().fetchFavorites(),
      context.read<TransactionProvider>().fetchMyTransactions(),
    ]);
  }

  Future<void> _onRefresh() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = context.watch<BookProvider>();
    final transactionProvider = context.watch<TransactionProvider>();

    final borrowingTransactions = transactionProvider.myTransactions
        .where((tx) => tx.status == 'BORROWING')
        .toList();
    borrowingTransactions.sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Profile (Fixed)
            const HomeHeader(),

            // Search Bar (Fixed)
            SearchBarWidget(
              readOnly: true,
              onTap: () {
                Provider.of<MainLayoutLogic>(context, listen: false)
                    .triggerSearchFocus();
              },
            ),
            SizedBox(height: 24.h),

            // Scrollable Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.primary,
                child: bookProvider.isLoadingHome
                    ? const HomeShimmer()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Recommended Books List
                            if (bookProvider.recommendedBooks.isNotEmpty) ...[
                              TrendingBooksList(
                                title: 'recommended_for_you'.tr(),
                                books: bookProvider.recommendedBooks,
                              ),
                            ],

                            // Reminder Card
                            if (borrowingTransactions.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 24.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'return_reminder_title'.tr(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                    if (borrowingTransactions.length > 1)
                                      GestureDetector(
                                        onTap: () {
                                          Provider.of<MainLayoutLogic>(context,
                                                  listen: false)
                                              .setIndex(2);
                                        },
                                        child: Text(
                                          'see_all'.tr(),
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              ReturnReminderCard(
                                  transaction: borrowingTransactions.first),
                              SizedBox(height: 12.h),
                            ],

                            // New Arrivals List
                            if (bookProvider.newArrivalBooks.isNotEmpty) ...[
                              TrendingBooksList(
                                title: 'new_arrivals'.tr(),
                                books: bookProvider.newArrivalBooks,
                              ),
                              SizedBox(height: 32.h),
                            ],

                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
