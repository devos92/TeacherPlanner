import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

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

  /// Pick any file (image, document, etc.)
  static Future<File?> pickAnyFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          return File(file.path!);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error picking file: $e');
      return null;
    }
  }

  /// Save image to app's local storage
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
        appDir = await getApplicationDocumentsDirectory();
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
      
      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return null;
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

  /// Delete local image file
  static Future<bool> deleteLocalImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  /// Get all local images
  static Future<List<File>> getLocalImages() async {
    try {
      // Handle web platform
      if (kIsWeb) {
        return [];
      }
      
      Directory appDir;
      try {
        appDir = await getApplicationDocumentsDirectory();
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
} 