import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/segmented_tab.dart';
import 'widgets/borrowing_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isCurrentTab = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchMyTransactions();
    });
  }

  void _setTab(bool isCurrent) {
    setState(() {
      _isCurrentTab = isCurrent;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final allTransactions = provider.myTransactions;

    final currentTransactions = allTransactions
        .where((t) =>
            t.status == 'PENDING' ||
            t.status == 'APPROVED' ||
            t.status == 'BORROWED')
        .toList();
    final historyTransactions = allTransactions
        .where((t) =>
            t.status == 'RETURNED' ||
            t.status == 'REJECTED' ||
            t.status == 'CANCELLED')
        .toList();

    final transactions =
        _isCurrentTab ? currentTransactions : historyTransactions;

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
                isLeftActive: _isCurrentTab,
                onLeftTap: () => _setTab(true),
                onRightTap: () => _setTab(false),
              ),
            ),
            SizedBox(height: 24.h),

            // Content
            Expanded(
              child: provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : transactions.isEmpty
                      ? Center(
                          child: Text(
                            'no_transactions'.tr(),
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16.sp),
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          physics: const BouncingScrollPhysics(),
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            return BorrowingCard(
                              transaction: transactions[index],
                              isHistory: !_isCurrentTab,
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
