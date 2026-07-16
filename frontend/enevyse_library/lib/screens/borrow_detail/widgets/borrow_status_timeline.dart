import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';
import '../../../models/transaction.dart';

class BorrowStatusTimeline extends StatelessWidget {
  final Transaction transaction;

  const BorrowStatusTimeline({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final steps = _buildTimelineSteps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'borrow_status'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
        ),
        SizedBox(height: 16.h),
        ...steps.map((step) => _buildStep(
              title: step.title,
              subtitle: step.subtitle,
              state: step.state,
              isLast: step == steps.last,
            )),
      ],
    );
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required _StepState state,
    required bool isLast,
  }) {
    Color iconColor;
    Color iconBgColor;
    Widget iconChild;

    switch (state) {
      case _StepState.completed:
        iconColor = Colors.white;
        iconBgColor = const Color(0xFF8B9CEB); // Soft blue
        iconChild = Icon(Icons.check, size: 14.w, color: Colors.white);
        break;
      case _StepState.active:
        iconColor = const Color(0xFFD67D55); // Orange
        iconBgColor = const Color(0xFFFDF0E5); // Soft orange
        iconChild = Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: iconColor,
            shape: BoxShape.circle,
          ),
        );
        break;
      case _StepState.pending:
        iconColor = Colors.transparent;
        iconBgColor = Colors.white;
        iconChild = Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: const Color(0xFFD3D4DD),
            shape: BoxShape.circle,
          ),
        );
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line and icon
          Column(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                  border: state == _StepState.pending
                      ? Border.all(color: const Color(0xFFE5E6EB))
                      : null,
                ),
                child: Center(child: iconChild),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    color: state == _StepState.completed
                        ? const Color(0xFF8B9CEB)
                        : const Color(0xFFE5E6EB),
                  ),
                ),
            ],
          ),
          SizedBox(width: 16.w),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      color: state == _StepState.pending
                          ? const Color(0xFFB1B3C0)
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFF6B6E80),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_TimelineStep> _buildTimelineSteps() {
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');
    final steps = <_TimelineStep>[];

    // 1. Request Submitted
    steps.add(_TimelineStep(
      title: 'request_submitted'.tr(),
      subtitle: dateFormat.format(transaction.createdAt),
      state: _StepState.completed,
    ));

    // 2. Approved
    steps.add(_TimelineStep(
      title: 'approved'.tr(),
      subtitle: transaction.approvedAt != null
          ? dateFormat.format(transaction.approvedAt!)
          : 'Pending',
      state: transaction.approvedAt != null
          ? _StepState.completed
          : _StepState.active,
    ));

    // 3. Picked Up
    steps.add(_TimelineStep(
      title: 'book_picked_up'.tr(),
      subtitle: transaction.pickedUpAt != null
          ? dateFormat.format(transaction.pickedUpAt!)
          : 'Pending',
      state: transaction.pickedUpAt != null
          ? _StepState.completed
          : (transaction.approvedAt != null
              ? _StepState.active
              : _StepState.pending),
    ));

    // 4. Borrowing (Active)
    steps.add(_TimelineStep(
      title: 'borrowing'.tr(),
      subtitle: 'Due ${DateFormat('MMM d, yyyy').format(transaction.dueDate)}',
      state: transaction.returnedAt != null
          ? _StepState.completed
          : (transaction.pickedUpAt != null
              ? _StepState.active
              : _StepState.pending),
    ));

    // 5. Returned
    steps.add(_TimelineStep(
      title: 'returned'.tr(),
      subtitle: transaction.returnedAt != null
          ? dateFormat.format(transaction.returnedAt!)
          : 'Pending',
      state: transaction.returnedAt != null
          ? _StepState.completed
          : _StepState.pending,
    ));

    return steps;
  }
}

enum _StepState {
  completed,
  active,
  pending,
}

class _TimelineStep {
  final String title;
  final String subtitle;
  final _StepState state;

  _TimelineStep(
      {required this.title, required this.subtitle, required this.state});
}
