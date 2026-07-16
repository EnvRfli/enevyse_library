import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import 'logic/admin_book_logic.dart';

class AddBookScreen extends StatelessWidget {
  const AddBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AdminBookLogic(),
      child: const _AddBookView(),
    );
  }
}

class _AddBookView extends StatelessWidget {
  const _AddBookView();

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<AdminBookLogic>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('add_book'.tr(), style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Form(
          key: logic.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cover Image Picker
              GestureDetector(
                onTap: () {
                  _showImageSourceActionSheet(context, logic);
                },
                child: Container(
                  height: 200.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: logic.coverImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.file(
                            logic.coverImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40.w, color: Colors.grey.shade600),
                            SizedBox(height: 8.h),
                            Text(
                              'tap_to_add_cover_image'.tr(),
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              CustomTextField(
                controller: logic.titleController,
                hintText: 'title'.tr(),
                prefixIcon: Icons.book,
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
              ),
              SizedBox(height: 16.h),

              // Author
              CustomTextField(
                controller: logic.authorController,
                hintText: 'author'.tr(),
                prefixIcon: Icons.person,
                validator: (value) => value == null || value.isEmpty ? 'Author is required' : null,
              ),
              SizedBox(height: 16.h),

              // Publisher
              CustomTextField(
                controller: logic.publisherController,
                hintText: 'publisher'.tr(),
                prefixIcon: Icons.business,
              ),
              SizedBox(height: 16.h),

              // Published Date
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: logic.publishedDate ?? DateTime.now(),
                    firstDate: DateTime(1800),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    logic.setPublishedDate(date);
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 20.w, color: AppColors.primary),
                      SizedBox(width: 12.w),
                      Text(
                        logic.publishedDate != null
                            ? DateFormat('MMM dd, yyyy').format(logic.publishedDate!)
                            : 'select_published_date'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: logic.publishedDate != null ? AppColors.textPrimary : Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Language Dropdown
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'language'.tr(),
                  prefixIcon: const Icon(Icons.language),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16.r)),
                ),
                value: logic.selectedLanguage,
                items: AdminBookLogic.availableLanguages.map((lang) {
                  return DropdownMenuItem(value: lang, child: Text(lang));
                }).toList(),
                onChanged: logic.setLanguage,
              ),
              SizedBox(height: 16.h),

              // Categories Multi-select
              Text('categories'.tr(), style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                children: AdminBookLogic.availableCategories.map((category) {
                  final isSelected = logic.selectedCategories.contains(category);
                  return FilterChip(
                    label: Text('cat_${category.toLowerCase()}'.tr()),
                    selected: isSelected,
                    onSelected: (_) => logic.toggleCategory(category),
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
              SizedBox(height: 16.h),

              if (logic.isNovelSelected) ...[
                // Genres Multi-select
                Text('genres'.tr(), style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 4.h,
                  children: AdminBookLogic.availableGenres.map((genre) {
                    final isSelected = logic.selectedGenres.contains(genre);
                    return FilterChip(
                      label: Text('gen_${genre.toLowerCase()}'.tr()),
                      selected: isSelected,
                      onSelected: (_) => logic.toggleGenre(genre),
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.primary,
                    );
                  }).toList(),
                ),
                SizedBox(height: 16.h),
              ],

              // Total Copies
              CustomTextField(
                controller: logic.totalCopiesController,
                hintText: 'total_copies'.tr(),
                prefixIcon: Icons.library_books,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Total Pages
              CustomTextField(
                controller: logic.totalPagesController,
                hintText: 'total_pages'.tr(),
                prefixIcon: Icons.pages,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  if (int.tryParse(value) == null) return 'Must be a number';
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Synopsis
              CustomTextField(
                controller: logic.synopsisController,
                hintText: 'synopsis'.tr(),
                prefixIcon: Icons.description,
              ),
              SizedBox(height: 32.h),

              // Submit Button
              ElevatedButton(
                onPressed: logic.isLoading
                    ? null
                    : () async {
                        final success = await logic.addBook(context);
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('book_successfully_added'.tr())),
                          );
                          context.pop();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: logic.isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        'add_book'.tr(),
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, AdminBookLogic logic) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text('choose_from_gallery'.tr()),
              onTap: () {
                Navigator.of(context).pop();
                logic.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text('take_photo'.tr()),
              onTap: () {
                Navigator.of(context).pop();
                logic.pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
}
