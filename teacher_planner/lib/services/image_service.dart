import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'supabase_service.dart';

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from gallery
  static Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from camera
  static Future<File?> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick multiple images from gallery
  static Future<List<File>> pickMultipleImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }

  /// Show image picker dialog
  static void showImagePicker(BuildContext context, Function(File) onImageSelected) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromGallery();
                  if (file != null) {
                    onImageSelected(file);
                  }
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera),
                title: Text('Camera'),
                onTap: () async {
                  Navigator.pop(context);
                  final file = await pickImageFromCamera();
                  if (file != null) {
                    onImageSelected(file);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// Upload image to Supabase and return the public URL
  static Future<String?> uploadImageToSupabase(File imageFile, {String? customName}) async {
    try {
      if (!SupabaseService.isAuthenticated) {
        debugPrint('User not authenticated - falling back to local storage');
        return await saveImageToLocal(imageFile);
      }

      final result = await SupabaseService.uploadImage(imageFile, customName: customName);
      if (result != null) {
        debugPrint('✅ Image uploaded to Supabase: $result');
        return result;
      } else {
        debugPrint('⚠️ Supabase upload failed - falling back to local storage');
        return await saveImageToLocal(imageFile);
      }
    } catch (e) {
      debugPrint('Error uploading to Supabase: $e - falling back to local storage');
      return await saveImageToLocal(imageFile);
    }
  }

  /// Save image to app's local storage with improved error handling
  static Future<String?> saveImageToLocal(File imageFile) async {
    try {
      // Handle web platform differently
      if (kIsWeb) {
        // For web, we'll use a different approach or return the file path as is
        debugPrint('Web platform detected - using file path directly');
        return imageFile.path;
      }

      Directory appDir;
      try {
        if (Platform.isWindows) {
          // Special handling for Windows
          try {
            appDir = await getApplicationDocumentsDirectory();
          } catch (e) {
            debugPrint('Windows getApplicationDocumentsDirectory failed: $e');
            // Fallback to user directory
            final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
            if (userProfile != null) {
              appDir = Directory('$userProfile/Documents/TeacherPlanner');
            } else {
              appDir = Directory.current;
            }
          }
        } else {
          // Other platforms
          appDir = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        // Fallback to temporary directory if path_provider fails
        debugPrint('Failed to get application documents directory: $e');
        try {
          appDir = await getTemporaryDirectory();
        } catch (tempError) {
          debugPrint('Failed to get temporary directory: $tempError');
          // Last resort - use current directory
          appDir = Directory.current;
        }
      }
      
      final imagesDir = Directory('${appDir.path}/lesson_images');
      
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final savedFile = await imageFile.copy('${imagesDir.path}/$fileName');
      
      debugPrint('📁 Image saved locally: ${savedFile.path}');
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  /// Delete image (works with both Supabase URLs and local paths)
  static Future<bool> deleteImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) {
        debugPrint('Error deleting image: Empty path provided');
        return false;
      }

      // Check if it's a Supabase URL
      if (imagePath.startsWith('http') && imagePath.contains('supabase')) {
        if (SupabaseService.isAuthenticated) {
          final success = await SupabaseService.deleteImage(imagePath);
          debugPrint(success ? 
            '✅ Supabase image deleted: $imagePath' : 
            '❌ Failed to delete Supabase image: $imagePath');
          return success;
        } else {
          debugPrint('❌ Cannot delete Supabase image: User not authenticated');
          return false;
        }
      } else {
        // Handle local file deletion
        return await deleteLocalImage(imagePath);
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Delete local image file with better error handling
  static Future<bool> deleteLocalImage(String imagePath) async {
    try {
      if (imagePath.isEmpty) {
        debugPrint('Error deleting image: Empty path provided');
        return false;
      }

      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        debugPrint('✅ Local image deleted: $imagePath');
        return true;
      } else {
        debugPrint('⚠️ Local image file does not exist: $imagePath');
        return false;
      }
    } catch (e) {
      debugPrint('❌ Error deleting local image: $e');
      return false;
    }
  }

  /// Get file size in human readable format
  static String getFileSize(File file) {
    try {
      // Handle web platform
      if (kIsWeb) {
        return 'Web file';
      }
      
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 'Unknown size';
    }
  }

  /// Get file extension
  static String getFileExtension(File file) {
    return path.extension(file.path).toLowerCase();
  }

  /// Check if file is an image
  static bool isImageFile(File file) {
    final extension = getFileExtension(file);
    return ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'].contains(extension);
  }

  /// Compress image if needed
  static Future<File?> compressImage(File imageFile) async {
    try {
      // For now, we'll return the original file
      // In a full implementation, you might want to add image compression
      return imageFile;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return null;
    }
  }

  /// Get all local images with improved platform handling
  static Future<List<File>> getLocalImages() async {
    try {
      // Handle web platform
      if (kIsWeb) {
        return [];
      }
      
      Directory appDir;
      try {
        if (Platform.isWindows) {
          // Special handling for Windows
          try {
            appDir = await getApplicationDocumentsDirectory();
          } catch (e) {
            debugPrint('Windows getApplicationDocumentsDirectory failed: $e');
            // Fallback to user directory
            final userProfile = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
            if (userProfile != null) {
              appDir = Directory('$userProfile/Documents/TeacherPlanner');
            } else {
              return [];
            }
          }
        } else {
          appDir = await getApplicationDocumentsDirectory();
        }
      } catch (e) {
        debugPrint('Failed to get application documents directory: $e');
        return [];
      }
      
      final imagesDir = Directory('${appDir.path}/lesson_images');
      
      if (!await imagesDir.exists()) {
        return [];
      }

      final files = await imagesDir.list().toList();
      return files.whereType<File>().where((file) => isImageFile(file)).toList();
    } catch (e) {
      debugPrint('Error getting local images: $e');
      return [];
    }
  }

  /// Migrate local images to Supabase (for users who want to sync their data)
  static Future<Map<String, String>> migrateLocalImagesToSupabase() async {
    final migrationMap = <String, String>{};
    
    try {
      if (!SupabaseService.isAuthenticated) {
        debugPrint('Cannot migrate: User not authenticated');
        return migrationMap;
      }

      final localImages = await getLocalImages();
      debugPrint('Found ${localImages.length} local images to migrate');

      for (final imageFile in localImages) {
        try {
          final supabaseUrl = await SupabaseService.uploadImage(imageFile);
          if (supabaseUrl != null) {
            migrationMap[imageFile.path] = supabaseUrl;
            debugPrint('✅ Migrated: ${path.basename(imageFile.path)}');
            
            // Optionally delete local file after successful upload
            // await imageFile.delete();
          } else {
            debugPrint('❌ Failed to migrate: ${path.basename(imageFile.path)}');
          }
        } catch (e) {
          debugPrint('❌ Error migrating ${path.basename(imageFile.path)}: $e');
        }
      }

      debugPrint('🎉 Migration complete: ${migrationMap.length}/${localImages.length} images migrated');
    } catch (e) {
      debugPrint('❌ Migration error: $e');
    }

    return migrationMap;
  }
} 