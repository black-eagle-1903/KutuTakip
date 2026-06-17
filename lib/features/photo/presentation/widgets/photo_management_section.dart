import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:kututakip/core/constants/app_constants.dart';
import 'package:kututakip/providers/app_providers.dart';

/// Widget to manage photos in a box (pick, compress, list, delete)
class PhotoManagementSection extends ConsumerWidget {
  final int boxId;

  const PhotoManagementSection({
    Key? key,
    required this.boxId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photosAsync = ref.watch(photosByBoxIdProvider(boxId));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppConstants.photosLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () =>
                        _pickImage(context, ref, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Çek'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () =>
                        _pickImage(context, ref, ImageSource.gallery),
                    icon: const Icon(Icons.image),
                    label: const Text('Seç'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Photos Grid
          photosAsync.when(
            data: (photos) {
              if (photos.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      AppConstants.noPhotosMessage,
                      style: TextStyle(
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: photos.length,
                itemBuilder: (context, index) {
                  final photo = photos[index];
                  return _buildPhotoCard(context, ref, photo);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Text(AppConstants.errorMessage),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, WidgetRef ref, dynamic photo) {
    return Card(
      child: Stack(
        children: [
          // Photo Image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[300],
            ),
            child: _PhotoImageWidget(filePath: photo.filePath),
          ),

          // Category Chip
          Positioned(
            bottom: 8,
            left: 8,
            child: GestureDetector(
              onTap: () => _showCategoryPicker(context, ref, photo),
              child: Chip(
                label: Text(
                  photo.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                backgroundColor: _categoryColor(photo.category),
                padding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ),

          // Delete Button
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.red.withOpacity(0.8),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 16),
                onPressed: () {
                  ref
                      .read(photoMutationProvider.notifier)
                      .deletePhoto(photo.id ?? 0, boxId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(AppConstants.deleteSuccessMessage),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile == null) return;

      // Show loading indicator
      if (!context.mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Compress and save image
      final compressedPath = await _compressAndSaveImage(pickedFile.path);

      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading

      if (compressedPath != null) {
        // Extract relative path
        final relativePath = _getRelativePath(compressedPath);

        // Show category picker
        if (context.mounted) {
          _showCategoryPickerForNew(
            context,
            ref,
            relativePath,
          );
        }
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Dismiss loading if still visible
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String?> _compressAndSaveImage(String imagePath) async {
    try {
      final fileName = const Uuid().v4();
      final appDocDir = await getApplicationDocumentsDirectory();
      final photosDir =
          Directory('${appDocDir.path}/${AppConstants.photosDirectoryName}');

      // Create photos directory if it doesn't exist
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final targetPath =
          '${photosDir.path}/$fileName.jpg';

      // Compress image
      final compressed = await FlutterImageCompress.compressAndGetFile(
        imagePath,
        targetPath,
        minWidth: 1024,
        minHeight: 1024,
        quality: AppConstants.photoCompressQuality,
        rotate: 0,
      );

      return compressed?.path;
    } catch (e) {
      print('Image compression error: $e');
      return null;
    }
  }

  String _getRelativePath(String fullPath) {
    try {
      final photoDirName = AppConstants.photosDirectoryName;
      final index = fullPath.indexOf(photoDirName);
      if (index != -1) {
        return fullPath.substring(index);
      }
      return fullPath;
    } catch (_) {
      return fullPath;
    }
  }

  void _showCategoryPickerForNew(
    BuildContext context,
    WidgetRef ref,
    String filePath,
  ) {
    _showCategoryPicker(
      context,
      ref,
      null,
      filePath: filePath,
      isNew: true,
    );
  }

  void _showCategoryPicker(
    BuildContext context,
    WidgetRef ref,
    dynamic photo, {
    String? filePath,
    bool isNew = false,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Kategori Seç',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              ...AppConstants.photoCategories.map((category) {
                return ListTile(
                  leading: Icon(
                    _categoryIcon(category),
                    color: _categoryColor(category),
                  ),
                  title: Text(category),
                  onTap: () {
                    if (isNew) {
                      // Create new photo
                      ref
                          .read(photoMutationProvider.notifier)
                          .createPhoto(
                            boxId: boxId,
                            filePath: filePath!,
                            category: category,
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppConstants.createSuccessMessage),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    } else {
                      // Update existing photo
                      ref
                          .read(photoMutationProvider.notifier)
                          .updatePhotoCategory(
                            photoId: photo.id ?? 0,
                            boxId: boxId,
                            category: category,
                          );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(AppConstants.updateSuccessMessage),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    }

                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'Dış':
        return Colors.blue;
      case 'İç':
        return Colors.green;
      case 'Diğer':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Dış':
        return Icons.photo_camera_back;
      case 'İç':
        return Icons.photo_camera_front;
      case 'Diğer':
        return Icons.image;
      default:
        return Icons.image;
    }
  }
}

/// Widget to display photo from file path
class _PhotoImageWidget extends StatelessWidget {
  final String filePath;

  const _PhotoImageWidget({
    required this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
      future: _getPhotoFile(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.grey[400],
              size: 32,
            ),
          );
        }

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            snapshot.data!,
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Future<File> _getPhotoFile() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/$filePath');
    return file;
  }
}
