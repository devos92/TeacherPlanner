// lib/services/storage_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import '../models/curriculum_models.dart';

enum StorageProvider {
  supabase,
  awsS3,
}

abstract class StorageService {
  Future<String> uploadFile(File file, String folder);
  Future<String> uploadBytes(Uint8List bytes, String fileName, String folder);
  Future<void> deleteFile(String url);
  Future<Uint8List> downloadFile(String url);
  Future<List<Attachment>> listAttachments(String folder);
}

class SupabaseStorageService implements StorageService {
  // TODO: Add Supabase configuration
  // final SupabaseClient _supabase;
  
  SupabaseStorageService() {
    // Initialize Supabase client
  }

  @override
  Future<String> uploadFile(File file, String folder) async {
    // TODO: Implement Supabase file upload
    throw UnimplementedError('Supabase storage not yet implemented');
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String fileName, String folder) async {
    // TODO: Implement Supabase bytes upload
    throw UnimplementedError('Supabase storage not yet implemented');
  }

  @override
  Future<void> deleteFile(String url) async {
    // TODO: Implement Supabase file deletion
    throw UnimplementedError('Supabase storage not yet implemented');
  }

  @override
  Future<Uint8List> downloadFile(String url) async {
    // TODO: Implement Supabase file download
    throw UnimplementedError('Supabase storage not yet implemented');
  }

  @override
  Future<List<Attachment>> listAttachments(String folder) async {
    // TODO: Implement Supabase file listing
    throw UnimplementedError('Supabase storage not yet implemented');
  }
}

class AWSS3StorageService implements StorageService {
  // TODO: Add AWS S3 configuration
  // final AWSClient _awsClient;
  
  AWSS3StorageService() {
    // Initialize AWS S3 client
  }

  @override
  Future<String> uploadFile(File file, String folder) async {
    // TODO: Implement AWS S3 file upload
    throw UnimplementedError('AWS S3 storage not yet implemented');
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String fileName, String folder) async {
    // TODO: Implement AWS S3 bytes upload
    throw UnimplementedError('AWS S3 storage not yet implemented');
  }

  @override
  Future<void> deleteFile(String url) async {
    // TODO: Implement AWS S3 file deletion
    throw UnimplementedError('AWS S3 storage not yet implemented');
  }

  @override
  Future<Uint8List> downloadFile(String url) async {
    // TODO: Implement AWS S3 file download
    throw UnimplementedError('AWS S3 storage not yet implemented');
  }

  @override
  Future<List<Attachment>> listAttachments(String folder) async {
    // TODO: Implement AWS S3 file listing
    throw UnimplementedError('AWS S3 storage not yet implemented');
  }
}

class MockStorageService implements StorageService {
  // Mock implementation for development/testing
  final Map<String, Uint8List> _files = {};
  final Map<String, Attachment> _attachments = {};

  @override
  Future<String> uploadFile(File file, String folder) async {
    final fileName = path.basename(file.path);
    final fileId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final url = 'mock://$folder/$fileId';
    
    _files[url] = await file.readAsBytes();
    _attachments[url] = Attachment(
      id: fileId,
      name: fileName,
      url: url,
      type: _getAttachmentType(fileName),
      uploadedAt: DateTime.now(),
      size: await file.length(),
    );
    
    return url;
  }

  @override
  Future<String> uploadBytes(Uint8List bytes, String fileName, String folder) async {
    final fileId = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    final url = 'mock://$folder/$fileId';
    
    _files[url] = bytes;
    _attachments[url] = Attachment(
      id: fileId,
      name: fileName,
      url: url,
      type: _getAttachmentType(fileName),
      uploadedAt: DateTime.now(),
      size: bytes.length,
    );
    
    return url;
  }

  @override
  Future<void> deleteFile(String url) async {
    _files.remove(url);
    _attachments.remove(url);
  }

  @override
  Future<Uint8List> downloadFile(String url) async {
    return _files[url] ?? Uint8List(0);
  }

  @override
  Future<List<Attachment>> listAttachments(String folder) async {
    return _attachments.values
        .where((attachment) => attachment.url.contains(folder))
        .toList();
  }

  AttachmentType _getAttachmentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return AttachmentType.image;
      case '.pdf':
      case '.doc':
      case '.docx':
      case '.txt':
      case '.rtf':
        return AttachmentType.document;
      case '.mp4':
      case '.avi':
      case '.mov':
      case '.wmv':
        return AttachmentType.video;
      case '.mp3':
      case '.wav':
      case '.aac':
      case '.ogg':
        return AttachmentType.audio;
      default:
        return AttachmentType.other;
    }
  }
}

class StorageServiceFactory {
  static StorageService create(StorageProvider provider) {
    switch (provider) {
      case StorageProvider.supabase:
        return SupabaseStorageService();
      case StorageProvider.awsS3:
        return AWSS3StorageService();
      default:
        return MockStorageService(); // Default to mock for development
    }
  }
} 