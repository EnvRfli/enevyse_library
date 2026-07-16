import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../../theme/app_colors.dart';
import '../../../repository/transaction_repository.dart';

class ApproveBookScreen extends StatefulWidget {
  const ApproveBookScreen({super.key});

  @override
  State<ApproveBookScreen> createState() => _ApproveBookScreenState();
}

class _ApproveBookScreenState extends State<ApproveBookScreen> {
  final TextEditingController _manualInputController = TextEditingController();
  final _repository = TransactionRepository();

  bool _isProcessing = false;
  String? _errorMessage;

  @override
  void dispose() {
    _manualInputController.dispose();
    super.dispose();
  }

  Future<void> _processBorrowId(String borrowId) async {
    if (borrowId.isEmpty || borrowId == '-1') return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await _repository.scanBorrow(borrowId);

      if (!mounted) return;

      if (result['success'] == true) {
        final newStatus = result['status'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'BORROWING'
                  ? 'book_picked_up_success'.tr()
                  : 'book_returned_success'.tr(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        _manualInputController.clear();
      } else {
        setState(() {
          _errorMessage =
              result['error'] ?? 'failed_to_process_transaction'.tr();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'connection_error_try_again'.tr();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'approve_book'.tr(),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.qr_code_scanner_rounded,
              size: 100.w,
              color: AppColors.primary,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: _isProcessing
                  ? null
                  : () async {
                      var res = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SimpleBarcodeScannerPage(),
                          ));
                      if (res is String) {
                        _processBorrowId(res);
                      }
                    },
              icon: const Icon(Icons.camera_alt_outlined),
              label:
                  Text('scan_qr_code'.tr(), style: TextStyle(fontSize: 16.sp)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
            ),
            SizedBox(height: 32.h),
            Row(
              children: [
                Expanded(child: Divider(color: AppColors.border)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'or'.tr(),
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(child: Divider(color: AppColors.border)),
              ],
            ),
            SizedBox(height: 32.h),
            Text(
              'enter_borrow_id_manually'.tr(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _manualInputController,
              decoration: InputDecoration(
                hintText: '#LB-YYYYMMDD-XXX',
                prefixIcon: const Icon(Icons.tag),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _isProcessing
                      ? null
                      : () {
                          FocusScope.of(context).unfocus();
                          _processBorrowId(_manualInputController.text.trim());
                        },
                ),
              ),
              onSubmitted: (value) {
                if (!_isProcessing) {
                  _processBorrowId(value.trim());
                }
              },
            ),
            if (_errorMessage != null) ...[
              SizedBox(height: 16.h),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 14.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (_isProcessing) ...[
              SizedBox(height: 24.h),
              const Center(child: CircularProgressIndicator()),
            ]
          ],
        ),
      ),
    );
  }
}
