import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import 'package:image_picker/image_picker.dart';
import '../../repository/book_repository.dart';
import 'logic/edit_book_logic.dart';

class EditBookScreen extends StatelessWidget {
  const EditBookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => EditBookLogic(BookRepository()),
      child: const _EditBookView(),
    );
  }
}

class _EditBookView extends StatelessWidget {
  const _EditBookView();

  @override
  Widget build(BuildContext context) {
    final logic = context.watch<EditBookLogic>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Book'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
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
            if (logic.successMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  logic.successMessage!,
                  style: TextStyle(color: Colors.green.shade700),
                ),
              ),

            // Search Box
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: logic.idController,
                    decoration: InputDecoration(
                      labelText: 'Book ID (UUID)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: logic.isLoading
                      ? null
                      : () => logic.fetchBook(logic.idController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: logic.isLoading && !logic.hasLoadedBook
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Load',
                          style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            if (logic.hasLoadedBook) ...[
              const Text(
                'Edit Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Cover Image Picker
              GestureDetector(
                onTap: () {
                  _showImageSourceActionSheet(context, logic);
                },
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: logic.coverImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            logic.coverImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        )
                      : logic.currentCoverUrl != null &&
                              logic.currentCoverUrl!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                logic.currentCoverUrl!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo,
                                    size: 40, color: Colors.grey.shade600),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to change cover image',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14),
                                ),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 24),

              _buildTextField('Title', logic.titleController),
              const SizedBox(height: 12),
              _buildTextField('Author', logic.authorController),
              const SizedBox(height: 12),
              _buildTextField('Publisher', logic.publisherController),
              const SizedBox(height: 12),
              _buildTextField('Total Pages', logic.pagesController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField('Total Copies', logic.totalCopiesController,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField('Synopsis', logic.synopsisController,
                  maxLines: 5),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: logic.isLoading
                      ? null
                      : () async {
                          final success = await logic.updateBook();
                          if (success && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Book updated successfully')),
                            );
                            context.pop();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentMocca,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: logic.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Update Book',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet(BuildContext context, EditBookLogic logic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Photo Library'),
              onTap: () {
                Navigator.of(context).pop();
                logic.pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Camera'),
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
