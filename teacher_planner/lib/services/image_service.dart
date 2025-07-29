// lib/services/image_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';

/// Image service for handling image uploads, compression, and storage
/// Used in day detail page for lesson attachments
class ImageService {
  static ImageService? _instance;
  static ImageService get instance => _instance ??= ImageService._();
  
  ImageService._();

  final SupabaseClient _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  /// Pick image from camera or gallery
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );
      
      if (image != null) {
        debugPrint('✅ Image picked: ${image.path}');
        return image;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error picking image: $e');
      return null;
    }
  }

  /// Pick multiple images
  Future<List<XFile>> pickMultipleImages({
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality ?? 80,
      );
      
      debugPrint('✅ ${images.length} images picked');
      return images;
    } catch (e) {
      debugPrint('❌ Error picking multiple images: $e');
      return [];
    }
  }

  /// Upload image to Supabase storage
  Future<String?> uploadImage({
    required XFile imageFile,
    required String bucketName,
    String? folderPath,
  }) async {
    try {
      final file = File(imageFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final filePath = folderPath != null ? '$folderPath/$fileName' : fileName;

      // Upload to Supabase storage
      await _supabase.storage
          .from(bucketName)
          .upload(filePath, file);

      // Get public URL
      final url = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      debugPrint('✅ Image uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Compress image for better performance
  Future<Uint8List?> compressImage({
    required XFile imageFile,
    int quality = 80,
    int maxWidth = 1024,
    int maxHeight = 1024,
  }) async {
    try {
      final file = File(imageFile.path);
      final bytes = await file.readAsBytes();
      
      // For now, return the original bytes
      // In a real implementation, you'd use image compression
      return bytes;
    } catch (e) {
      debugPrint('❌ Error compressing image: $e');
      return null;
    }
  }

  /// Save image to local storage
  Future<String?> saveImageLocally({
    required XFile imageFile,
    String? fileName,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final name = fileName ?? '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedPath = path.join(directory.path, name);
      
      final file = File(imageFile.path);
      await file.copy(savedPath);
      
      debugPrint('✅ Image saved locally: $savedPath');
      return savedPath;
    } catch (e) {
      debugPrint('❌ Error saving image locally: $e');
      return null;
    }
  }

  /// Delete image from storage
  Future<bool> deleteImage({
    required String imageUrl,
    required String bucketName,
  }) async {
    try {
      final fileName = path.basename(imageUrl);
      await _supabase.storage
          .from(bucketName)
          .remove([fileName]);
      
      debugPrint('✅ Image deleted: $fileName');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Get image thumbnail
  Future<String?> getImageThumbnail({
    required String imageUrl,
    int width = 150,
    int height = 150,
  }) async {
    try {
      // In a real implementation, you'd generate thumbnails
      // For now, return the original URL
      return imageUrl;
    } catch (e) {
      debugPrint('❌ Error generating thumbnail: $e');
      return null;
    }
  }

  /// Validate image file
  bool validateImage({
    required XFile imageFile,
    int maxSizeMB = 10,
    List<String> allowedTypes = const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
  }) {
    try {
      final extension = path.extension(imageFile.path).toLowerCase().replaceAll('.', '');
      
      // Check file type
      if (!allowedTypes.contains(extension)) {
        return false;
      }
      
      // Check file size (basic check)
      final file = File(imageFile.path);
      final sizeInBytes = file.lengthSync();
      final sizeInMB = sizeInBytes / (1024 * 1024);
      
      return sizeInMB <= maxSizeMB;
    } catch (e) {
      debugPrint('❌ Error validating image: $e');
      return false;
    }
  }

  /// Get image info
  Future<Map<String, dynamic>?> getImageInfo({
    required XFile imageFile,
  }) async {
    try {
      final file = File(imageFile.path);
      final stat = await file.stat();
      
      return {
        'path': imageFile.path,
        'name': path.basename(imageFile.path),
        'size': stat.size,
        'modified': stat.modified,
        'extension': path.extension(imageFile.path),
      };
    } catch (e) {
      debugPrint('❌ Error getting image info: $e');
      return null;
    }
  }
} 