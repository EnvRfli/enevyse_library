import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'logic/history_logic.dart';
import 'widgets/segmented_tab.dart';
import 'widgets/borrowing_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HistoryLogic(),
      child: const _HistoryScreenView(),
    );
  }
}

class _HistoryScreenView extends StatelessWidget {
  const _HistoryScreenView();

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<HistoryLogic>(context);
    final transactions = logic.isCurrentTab ? logic.currentTransactions : logic.historyTransactions;

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
                'my_borrowing'.tr(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
              ),
            ),
            SizedBox(height: 24.h),
            
            // Tabs
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SegmentedTab(
                leftLabel: 'current_borrowing'.tr(),
                rightLabel: 'borrowing_history'.tr(),
                isLeftActive: logic.isCurrentTab,
                onLeftTap: () => logic.setTab(true),
                onRightTap: () => logic.setTab(false),
              ),
            ),
            SizedBox(height: 24.h),

            // Content
            Expanded(
              child: logic.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? Center(
                          child: Text(
                            'no_transactions'.tr(),
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 16.sp),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          physics: const BouncingScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            return BorrowingCard(
                              transaction: transactions[index],
                              isHistory: !logic.isCurrentTab,
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
