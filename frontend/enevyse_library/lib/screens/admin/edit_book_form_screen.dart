import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../repository/book_repository.dart';
import 'logic/edit_book_logic.dart';

class EditBookFormScreen extends StatelessWidget {
  final String bookId;

  const EditBookFormScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final logic = EditBookLogic(BookRepository());
        logic.idController.text = bookId;
        logic.fetchBook(bookId);
        return logic;
      },
      child: const _EditBookFormView(),
    );
  }
}

class _EditBookFormView extends StatelessWidget {
  const _EditBookFormView();

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<EditBookLogic>();

    return Scaffold(
      appBar: AppBar(
        title: Text('edit_book'.tr()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: logic.isLoading && !logic.hasLoadedBook
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (logic.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        logic.errorMessage!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ),
                  if (logic.hasLoadedBook) ...[
                    // Cover Image
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) => SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.camera_alt),
                                    title: Text('take_photo'.tr()),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      logic.pickImage(ImageSource.camera);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: Text('choose_from_gallery'.tr()),
                                    onTap: () {
                                      Navigator.pop(ctx);
                                      logic.pickImage(ImageSource.gallery);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          height: 200.h,
                          width: double.infinity,
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
                              : logic.currentCoverUrl != null &&
                                      logic.currentCoverUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(16.r),
                                      child: Image.network(
                                        logic.currentCoverUrl!,
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      ),
                                    )
                                  : Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add_a_photo,
                                            size: 40.w,
                                            color: Colors.grey.shade600),
                                        SizedBox(height: 8.h),
                                        Text(
                                          'tap_to_add_cover_image'.tr(),
                                          style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14.sp),
                                        ),
                                      ],
                                    ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Title
                    _buildTextField(
                        logic.titleController, 'title'.tr(), Icons.book),
                    SizedBox(height: 16.h),

                    // Author
                    _buildTextField(
                        logic.authorController, 'author'.tr(), Icons.person),
                    SizedBox(height: 16.h),

                    // Publisher
                    _buildTextField(logic.publisherController, 'publisher'.tr(),
                        Icons.business),
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
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
                            Icon(Icons.calendar_today,
                                size: 20.w, color: AppColors.primary),
                            SizedBox(width: 12.w),
                            Text(
                              logic.publishedDate != null
                                  ? DateFormat('MMM dd, yyyy')
                                      .format(logic.publishedDate!)
                                  : 'select_published_date'.tr(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: logic.publishedDate != null
                                        ? AppColors.textPrimary
                                        : Colors.grey.shade600,
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
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16.r)),
                      ),
                      value: EditBookLogic.availableLanguages
                              .contains(logic.selectedLanguage)
                          ? logic.selectedLanguage
                          : null,
                      items: EditBookLogic.availableLanguages.map((lang) {
                        return DropdownMenuItem(value: lang, child: Text(lang));
                      }).toList(),
                      onChanged: logic.setLanguage,
                    ),
                    SizedBox(height: 16.h),

                    // Categories Multi-select
                    Text('categories'.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children:
                          EditBookLogic.availableCategories.map((category) {
                        final isSelected =
                            logic.selectedCategories.contains(category);
                        return FilterChip(
                          label: Text('cat_${category.toLowerCase()}'.tr()),
                          selected: isSelected,
                          onSelected: (_) => logic.toggleCategory(category),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.2),
                          checkmarkColor: AppColors.primary,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),

                    if (logic.isNovelSelected) ...[
                      // Genres Multi-select
                      Text('genres'.tr(),
                          style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 4.h,
                        children: EditBookLogic.availableGenres.map((genre) {
                          final isSelected =
                              logic.selectedGenres.contains(genre);
                          return FilterChip(
                            label: Text('gen_${genre.toLowerCase()}'.tr()),
                            selected: isSelected,
                            onSelected: (_) => logic.toggleGenre(genre),
                            selectedColor:
                                AppColors.primary.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.primary,
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 16.h),
                    ],

                    // Total Copies
                    _buildTextField(logic.totalCopiesController,
                        'total_copies'.tr(), Icons.library_books,
                        keyboardType: TextInputType.number),
                    SizedBox(height: 16.h),

                    // Total Pages
                    _buildTextField(
                        logic.pagesController, 'total_pages'.tr(), Icons.pages,
                        keyboardType: TextInputType.number),
                    SizedBox(height: 16.h),

                    // Synopsis
                    _buildTextField(logic.synopsisController, 'synopsis'.tr(),
                        Icons.description,
                        maxLines: 5),
                    SizedBox(height: 32.h),

                    // Submit
                    SizedBox(
                      width: double.infinity,
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: logic.isLoading
                            ? null
                            : () async {
                                final success = await logic.updateBook();
                                if (success && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'book_successfully_updated'.tr())),
                                  );
                                  context.pop();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        child: logic.isLoading
                            ? SizedBox(
                                width: 24.w,
                                height: 24.w,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'save_changes'.tr(),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String hint, IconData icon,
      {int maxLines = 1, TextInputType? keyboardType}) {
    return Container(
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
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: maxLines == 1
              ? Icon(icon, color: AppColors.primary)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 80.0),
                  child: Icon(icon, color: AppColors.primary),
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.r),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }
}
