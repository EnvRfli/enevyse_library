import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../../../providers/auth_provider.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';
import 'logic/update_profile_logic.dart';

class UpdateProfileScreen extends StatelessWidget {
  const UpdateProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UpdateProfileLogic(context.read<AuthProvider>()),
      child: const _UpdateProfileView(),
    );
  }
}

class _UpdateProfileView extends StatelessWidget {
  const _UpdateProfileView();

  @override
  Widget build(BuildContext context) {
    final logic = Provider.of<UpdateProfileLogic>(context);
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('update_profile'.tr(),
            style: Theme.of(context).textTheme.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: logic.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(24.w),
              child: Form(
                key: logic.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Picture
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          _showImageSourceActionSheet(context, logic);
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 60.r,
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              backgroundImage: logic.profileImage != null
                                  ? FileImage(logic.profileImage!)
                                  : (user?.profilePictureUrl.isNotEmpty == true
                                      ? NetworkImage(user!.profilePictureUrl)
                                      : null) as ImageProvider?,
                              child: (logic.profileImage == null &&
                                      (user == null ||
                                          user.profilePictureUrl.isEmpty))
                                  ? Text(
                                      user?.name.isNotEmpty == true
                                          ? user!.name[0].toUpperCase()
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 40.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Icon(Icons.camera_alt,
                                    size: 20.w, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Name — editable
                    CustomTextField(
                        controller: logic.nameController,
                        hintText: 'name'.tr(),
                        prefixIcon: Icons.person,
                        disabled: true),
                    SizedBox(height: 16.h),

                    // Email — disabled
                    CustomTextField(
                      controller: logic.emailController,
                      hintText: 'email'.tr(),
                      prefixIcon: Icons.email,
                      disabled: true,
                    ),
                    SizedBox(height: 16.h),

                    // Member ID — disabled
                    CustomTextField(
                      controller: logic.memberIdController,
                      hintText: 'Member ID',
                      prefixIcon: Icons.badge,
                      disabled: true,
                    ),
                    SizedBox(height: 16.h),

                    // Phone — digits only, max 13
                    CustomTextField(
                      controller: logic.phoneController,
                      hintText: 'Phone',
                      prefixIcon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(13),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: logic.addressController,
                      hintText: 'Address',
                      prefixIcon: Icons.location_on,
                    ),
                    SizedBox(height: 24.h),

                    // Preferred Categories
                    Text(
                      'Preferred Categories',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: UpdateProfileLogic.availableCategories
                          .map((category) {
                        final isSelected =
                            logic.selectedCategories.contains(category);
                        return FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (_) => logic.toggleCategory(category),
                          selectedColor: AppColors.primary.withOpacity(0.2),
                          checkmarkColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 32.h),

                    // Save Button
                    ElevatedButton(
                      onPressed: () async {
                        final success = await logic.saveProfile();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content:
                                    Text('Profile updated successfully'.tr())),
                          );
                          context.pop();
                        } else if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(logic.authProvider.errorMessage ??
                                  'error_occurred'.tr()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
    );
  }

  void _showImageSourceActionSheet(
      BuildContext context, UpdateProfileLogic logic) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  logic.pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  logic.pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
