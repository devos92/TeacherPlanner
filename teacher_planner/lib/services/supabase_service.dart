// lib/services/supabase_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  /// Initialize storage buckets if they don't exist
  static Future<void> initializeStorage() async {
    try {
      // Check if buckets exist, create if not
      final buckets = await _client.storage.listBuckets();
      
      if (!buckets.any((bucket) => bucket.name == 'lesson-images')) {
        await _client.storage.createBucket(
          'lesson-images',
          const BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/gif'],
          ),
        );
        debugPrint('📦 Created lesson-images bucket');
      }
      
      if (!buckets.any((bucket) => bucket.name == 'lesson-attachments')) {
        await _client.storage.createBucket(
          'lesson-attachments',
          const BucketOptions(
            public: false,
          ),
        );
        debugPrint('📦 Created lesson-attachments bucket');
      }
      
      debugPrint('📦 Storage buckets initialized');
    } catch (e) {
      debugPrint('❌ Error initializing storage: $e');
    }
  }

  /// Get current user
  static User? get currentUser => _client.auth.currentUser;

  /// Check if user is authenticated
  static bool get isAuthenticated => currentUser != null;

  /// Sign in with email and password
  static Future<AuthResponse?> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ User signed in successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Error signing in: $e');
      return null;
    }
  }

  /// Sign up with email and password
  static Future<AuthResponse?> signUpWithEmail(
    String email, 
    String password, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: data,
      );
      debugPrint('✅ User signed up successfully');
      return response;
    } catch (e) {
      debugPrint('❌ Error signing up: $e');
      return null;
    }
  }

  /// Sign out current user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      debugPrint('✅ User signed out successfully');
    } catch (e) {
      debugPrint('❌ Error signing out: $e');
    }
  }

  /// Upload image to Supabase storage
  static Future<String?> uploadImage(
    File imageFile, {
    String? customName,
  }) async {
    try {
      if (!isAuthenticated) {
        debugPrint('❌ User not authenticated for image upload');
        return null;
      }

      final userId = currentUser!.id;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = imageFile.path.split('.').last;
      final fileName = customName ?? 'image_${timestamp}.$extension';
      final filePath = '$userId/$fileName';

      await _client.storage
          .from('lesson-images')
          .upload(filePath, imageFile);

      final publicUrl = _client.storage
          .from('lesson-images')
          .getPublicUrl(filePath);

      debugPrint('✅ Image uploaded successfully: $publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('❌ Error uploading image: $e');
      return null;
    }
  }

  /// Delete image from storage
  static Future<bool> deleteImage(String imageUrl) async {
    try {
      if (!isAuthenticated) {
        debugPrint('❌ User not authenticated for image deletion');
        return false;
      }

      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;
      final bucketIndex = pathSegments.indexOf('lesson-images');
      
      if (bucketIndex == -1 || bucketIndex >= pathSegments.length - 1) {
        debugPrint('❌ Invalid image URL format');
        return false;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      await _client.storage
          .from('lesson-images')
          .remove([filePath]);

      debugPrint('✅ Image deleted successfully: $filePath');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Subscribe to real-time events for a specific teacher
  static RealtimeChannel subscribeToEvents(
    String teacherId,
    Function(Map<String, dynamic>) onEvent,
  ) {
    final channel = _client
        .channel('events:$teacherId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'events',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'teacher_id',
            value: teacherId,
          ),
          callback: (payload) {
            debugPrint('📡 Event change received: ${payload.eventType}');
            onEvent(payload.newRecord);
          },
        )
        .subscribe();

    debugPrint('📡 Subscribed to events for teacher: $teacherId');
    return channel;
  }

  /// Subscribe to real-time reflection updates
  static RealtimeChannel subscribeToReflections(
    String teacherId,
    Function(Map<String, dynamic>) onReflection,
  ) {
    final channel = _client
        .channel('reflections:$teacherId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'reflections',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'teacher_id',
            value: teacherId,
          ),
          callback: (payload) {
            debugPrint('📡 Reflection change received: ${payload.eventType}');
            onReflection(payload.newRecord);
          },
        )
        .subscribe();

    debugPrint('📡 Subscribed to reflections for teacher: $teacherId');
    return channel;
  }

  /// Generic database query helper
  static SupabaseQueryBuilder from(String table) {
    return _client.from(table);
  }

  /// Get Supabase client for advanced operations
  static SupabaseClient get client => _client;
} 