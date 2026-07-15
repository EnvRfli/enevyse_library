import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/mock_book.dart';
import '../../theme/app_colors.dart';
import 'logic/borrow_logic.dart';

class BorrowFormScreen extends StatelessWidget {
  final String bookId;

  const BorrowFormScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BorrowLogic(),
      child: _BorrowFormView(bookId: bookId),
    );
  }
}

class _BorrowFormView extends StatelessWidget {
  final String bookId;

  const _BorrowFormView({required this.bookId});

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<BorrowLogic>(context);

    // Mock book data for display
    final allBooks = [...mockTrendingBooks, ...mockRecommendedBooks, ...mockNewArrivals];
    final book = allBooks.firstWhere(
      (b) => b.id == bookId,
      orElse: () => allBooks.first,
    );

    // Format dates
    final now = DateTime.now();
    final returnDate = now.add(const Duration(days: 7));
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 16.w, color: AppColors.textPrimary),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'borrow_request'.tr(),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 85.h,
                      decoration: BoxDecoration(
                        color: book.placeholderColor,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            book.author,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14.sp,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F9EE),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              '${book.availableCount} ${'available'.tr()}',
                              style: TextStyle(
                                color: const Color(0xFF32B37A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Borrow Date
              _buildLabel('borrow_date'.tr()),
              _buildReadOnlyField(dateFormat.format(now), icon: Icons.calendar_today_rounded),
              SizedBox(height: 20.h),

              // Return Date
              _buildLabel('return_date'.tr()),
              _buildReadOnlyField(dateFormat.format(returnDate), isGrey: true),
              SizedBox(height: 20.h),

              // Purpose
              _buildLabel('purpose_borrowing'.tr()),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  maxLines: 3,
                  onChanged: logic.setPurpose,
                  decoration: InputDecoration(
                    hintText: 'purpose_hint'.tr(),
                    hintStyle: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16.w),
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Pickup Location
              _buildLabel('pickup_location'.tr()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: logic.pickupLocation,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                    items: logic.pickupLocations.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary)),
                      );
                    }).toList(),
                    onChanged: logic.setPickupLocation,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: Checkbox(
                      value: logic.agreedToTerms,
                      onChanged: logic.setAgreedToTerms,
                      activeColor: const Color(0xFF9E86E1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'agree_terms'.tr(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32.h),

              // Submit Button
              if (logic.errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Text(
                    logic.errorMessage!,
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
                
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: logic.isLoading
                      ? null
                      : () async {
                          final transactionId = await logic.submitBorrowRequest(bookId);
                          if (transactionId != null) {
                            if (context.mounted) {
                              context.pushReplacement('/borrow-success', extra: {
                                'transactionId': transactionId,
                                'bookTitle': book.title,
                                'deadline': returnDate,
                              });
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B9CEB), // Soft Indigo
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: logic.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'submit_request'.tr(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            letterSpacing: 1.0,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: const Color(0xFF6B6E80),
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String text, {IconData? icon, bool isGrey = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: isGrey ? const Color(0xFFF2F2F5) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              color: isGrey ? AppColors.textSecondary : AppColors.textPrimary,
            ),
          ),
          if (icon != null) Icon(icon, size: 20.w, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
