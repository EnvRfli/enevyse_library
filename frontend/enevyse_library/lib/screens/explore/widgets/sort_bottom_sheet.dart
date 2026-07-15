import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../theme/app_colors.dart';

class SortBottomSheet extends StatefulWidget {
  final String initialSortBy;
  final Function(String) onApply;

  const SortBottomSheet({
    super.key,
    required this.initialSortBy,
    required this.onApply,
  });

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late String _selectedSortBy;

  final Map<String, String> _sortOptions = {
    'created_at_desc': 'newest_first',
    'available_copies_asc': 'most_available',
    'rating_desc': 'highest_rating',
    'title_asc': 'title_a_z',
    'title_desc': 'title_z_a',
  };

  @override
  void initState() {
    super.initState();
    _selectedSortBy = widget.initialSortBy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'sort_by'.tr(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ..._sortOptions.entries.map((entry) {
            return RadioListTile<String>(
              value: entry.key,
              groupValue: _selectedSortBy,
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
              title: Text(
                entry.value.tr(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSortBy = value;
                  });
                }
              },
            );
          }),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedSortBy);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'apply'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
