import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import '../../theme/app_colors.dart';

class BorrowSuccessScreen extends StatefulWidget {
  final String borrowId;
  final String bookTitle;
  final DateTime deadline;
  final bool isFromBorrowing;
  final String status;

  const BorrowSuccessScreen({
    super.key,
    required this.borrowId,
    required this.bookTitle,
    required this.deadline,
    this.isFromBorrowing = false,
    required this.status,
  });

  @override
  State<BorrowSuccessScreen> createState() => _BorrowSuccessScreenState();
}

class _BorrowSuccessScreenState extends State<BorrowSuccessScreen> {
  final GlobalKey _globalKey = GlobalKey();

  Future<void> _downloadTicket() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      await Gal.putImageBytes(pngBytes, album: 'Library Tickets');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket saved to gallery!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save ticket')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy · h:mm a');

    return Scaffold(
      backgroundColor: const Color(0xFFFDFBF7),
      appBar: widget.isFromBorrowing
          ? AppBar(
              backgroundColor: const Color(0xFFFDFBF7),
              elevation: 0,
              automaticallyImplyLeading: false, // NO back button
              title: Text(
                'QR Detail',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
            )
          : AppBar(
              backgroundColor: const Color(0xFFFDFBF7),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'QR Detail',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.sp,
                ),
              ),
            ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.isFromBorrowing) ...[
                  SizedBox(height: 40.h),
                  // Success Icon
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F9EE), // Light green
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        color: const Color(0xFF32B37A),
                        size: 40.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  Text(
                    'borrow_request_submitted'.tr(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'show_qr_instruction'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),
                ] else ...[
                  SizedBox(height: 16.h),
                ],
                // Ticket Card
                RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.border),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Top part: QR Code
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            children: [
                              Text(
                                'BORROW ID · ${widget.borrowId}',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.sp,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              SizedBox(height: 16.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: QrImageView(
                                  data: widget.borrowId,
                                  version: QrVersions.auto,
                                  size: 160.w,
                                  eyeStyle: const QrEyeStyle(
                                    eyeShape: QrEyeShape.square,
                                    color: AppColors.primary,
                                  ),
                                  dataModuleStyle: const QrDataModuleStyle(
                                    dataModuleShape: QrDataModuleShape.square,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Dashed Line Simulator
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 1,
                              margin: EdgeInsets.symmetric(horizontal: 24.w),
                              color: AppColors
                                  .border, // Should ideally be dashed, using solid for simplicity
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 16.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: const Color(
                                        0xFFFDFBF7), // Background color
                                    borderRadius: BorderRadius.horizontal(
                                        right: Radius.circular(16.r)),
                                    border: Border(
                                      right:
                                          BorderSide(color: AppColors.border),
                                      top: BorderSide(color: AppColors.border),
                                      bottom:
                                          BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 16.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFDFBF7),
                                    borderRadius: BorderRadius.horizontal(
                                        left: Radius.circular(16.r)),
                                    border: Border(
                                      left: BorderSide(color: AppColors.border),
                                      top: BorderSide(color: AppColors.border),
                                      bottom:
                                          BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        // Bottom part: Info
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                  'book_title'.tr(), widget.bookTitle),
                              SizedBox(height: 12.h),
                              _buildInfoRow('pickup_deadline'.tr(),
                                  dateFormat.format(widget.deadline)),
                              SizedBox(height: 12.h),
                              _buildInfoRow(
                                'status'.tr(),
                                widget.status == 'BORROWING'
                                    ? 'borrowing'.tr()
                                    : 'waiting_approval'.tr(),
                                isStatus: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // Buttons
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: OutlinedButton.icon(
                    onPressed: _downloadTicket,
                    icon: const Icon(Icons.download_rounded),
                    label: Text(
                      'download_qr'.tr(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.r)),
                    ),
                  ),
                ),
                if (widget.isFromBorrowing) ...[
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: () {
                        context.go('/home'); // Go back to Home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B9CEB), // Soft Indigo
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r)),
                      ),
                      child: Text(
                        'back_to_home'.tr(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16.sp),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isStatus = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14.sp,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: isStatus
              ? Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDF0E5), // Soft orange
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        color: const Color(0xFFD67D55),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                  textAlign: TextAlign.right,
                ),
        ),
      ],
    );
  }
}
