// lib/services/supabase_service.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  
  // Storage bucket names
  static const String _imagesBucket = 'lesson-images';
  static const String _documentsBucket = 'lesson-documents';
  static const String _avatarsBucket = 'teacher-avatars';

  // Initialize storage buckets if they don't exist
  static Future<void> initializeStorage() async {
    try {
      final buckets = await _client.storage.listBuckets();
      final bucketNames = buckets.map((b) => b.name).toSet();

      // Create buckets if they don't exist
      if (!bucketNames.contains(_imagesBucket)) {
        await _client.storage.createBucket(
          _imagesBucket,
          BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png', 'image/gif', 'image/webp'],
            fileSizeLimit: '10MB',
          ),
        );
      }

      if (!bucketNames.contains(_documentsBucket)) {
        await _client.storage.createBucket(
          _documentsBucket,
          BucketOptions(
            public: true,
            allowedMimeTypes: ['application/pdf', 'application/msword', 'text/plain'],
            fileSizeLimit: '50MB',
          ),
        );
      }

      if (!bucketNames.contains(_avatarsBucket)) {
        await _client.storage.createBucket(
          _avatarsBucket,
          BucketOptions(
            public: true,
            allowedMimeTypes: ['image/jpeg', 'image/png'],
            fileSizeLimit: '2MB',
          ),
        );
      }
    } catch (e) {
      debugPrint('Error initializing storage: $e');
    }
  }

  // Authentication methods
  static User? get currentUser => _client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail(String email, String password, {Map<String, dynamic>? data}) async {
    return await _client.auth.signUp(email: email, password: password, data: data);
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Teacher Profile methods
  static Future<Map<String, dynamic>?> getTeacherProfile(String userId) async {
    try {
      final response = await _client
          .from('teacher_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return response;
    } catch (e) {
      debugPrint('Error fetching teacher profile: $e');
      return null;
    }
  }

  static Future<bool> createTeacherProfile({
    required String userId,
    required String email,
    required String name,
    String? schoolName,
    String? yearLevel,
    List<String>? subjectSpecialization,
  }) async {
    try {
      await _client.from('teacher_profiles').insert({
        'id': userId,
        'email': email,
        'name': name,
        'school_name': schoolName,
        'year_level': yearLevel,
        'subject_specialization': subjectSpecialization,
      });
      return true;
    } catch (e) {
      debugPrint('Error creating teacher profile: $e');
      return false;
    }
  }

  static Future<bool> updateTeacherProfile(String userId, Map<String, dynamic> updates) async {
    try {
      await _client
          .from('teacher_profiles')
          .update(updates)
          .eq('id', userId);
      return true;
    } catch (e) {
      debugPrint('Error updating teacher profile: $e');
      return false;
    }
  }

  // Image Storage methods
  static Future<String?> uploadImage(File imageFile, {String? customName}) async {
    try {
      final fileName = customName ?? 
          '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final filePath = '$userId/$fileName';
      
      await _client.storage
          .from(_imagesBucket)
          .upload(filePath, imageFile);

      final publicUrl = _client.storage
          .from(_imagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  static Future<String?> uploadImageBytes(Uint8List imageBytes, String fileName) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final filePath = '$userId/$fileName';
      
      await _client.storage
          .from(_imagesBucket)
          .uploadBinary(filePath, imageBytes);

      final publicUrl = _client.storage
          .from(_imagesBucket)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image bytes: $e');
      return null;
    }
  }

  static Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final filePath = uri.pathSegments.skip(4).join('/'); // Skip /storage/v1/object/public/{bucket}/
      
      await _client.storage
          .from(_imagesBucket)
          .remove([filePath]);

      return true;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  // Enhanced Events methods
  static Future<List<Map<String, dynamic>>> getEventsForDay(String date) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('events_with_attachments')
          .select()
          .eq('teacher_id', userId)
          .eq('date', date)
          .order('start_time');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching events for day: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getEventsForDateRange(String startDate, String endDate) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('events_with_attachments')
          .select()
          .eq('teacher_id', userId)
          .gte('date', startDate)
          .lte('date', endDate)
          .order('date')
          .order('start_time');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching events for date range: $e');
      return [];
    }
  }

  static Future<String?> saveEvent(Map<String, dynamic> eventData) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      eventData['teacher_id'] = userId;

      final response = await _client
          .from('enhanced_events')
          .insert(eventData)
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error saving event: $e');
      return null;
    }
  }

  static Future<bool> updateEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('enhanced_events')
          .update(updates)
          .eq('id', eventId)
          .eq('teacher_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error updating event: $e');
      return false;
    }
  }

  static Future<bool> deleteEvent(String eventId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('enhanced_events')
          .delete()
          .eq('id', eventId)
          .eq('teacher_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error deleting event: $e');
      return false;
    }
  }

  // Attachments methods
  static Future<String?> saveAttachment({
    required String parentId,
    required String parentType,
    required String name,
    required String fileUrl,
    required String fileType,
    String? filePath,
    int? fileSize,
    String? mimeType,
    String? description,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('attachments')
          .insert({
            'teacher_id': userId,
            'parent_id': parentId,
            'parent_type': parentType,
            'name': name,
            'file_path': filePath,
            'file_url': fileUrl,
            'file_type': fileType,
            'file_size': fileSize,
            'mime_type': mimeType,
            'description': description,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error saving attachment: $e');
      return null;
    }
  }

  static Future<bool> deleteAttachment(String attachmentId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get attachment info to delete from storage
      final attachment = await _client
          .from('attachments')
          .select('file_url')
          .eq('id', attachmentId)
          .eq('teacher_id', userId)
          .maybeSingle();

      if (attachment != null && attachment['file_url'] != null) {
        // Delete from storage
        await deleteImage(attachment['file_url']);
      }

      // Delete from database
      await _client
          .from('attachments')
          .delete()
          .eq('id', attachmentId)
          .eq('teacher_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error deleting attachment: $e');
      return false;
    }
  }

  // Hyperlinks methods
  static Future<String?> saveHyperlink({
    required String parentId,
    required String parentType,
    required String title,
    required String url,
    String? description,
  }) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('hyperlinks')
          .insert({
            'teacher_id': userId,
            'parent_id': parentId,
            'parent_type': parentType,
            'title': title,
            'url': url,
            'description': description,
          })
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error saving hyperlink: $e');
      return null;
    }
  }

  static Future<bool> deleteHyperlink(String hyperlinkId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('hyperlinks')
          .delete()
          .eq('id', hyperlinkId)
          .eq('teacher_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error deleting hyperlink: $e');
      return false;
    }
  }

  // Daily Reflections methods
  static Future<Map<String, dynamic>?> getReflectionForDay(String date) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('daily_reflections')
          .select()
          .eq('teacher_id', userId)
          .eq('date', date)
          .maybeSingle();

      return response;
    } catch (e) {
      debugPrint('Error fetching reflection for day: $e');
      return null;
    }
  }

  static Future<String?> saveReflection(Map<String, dynamic> reflectionData) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      reflectionData['teacher_id'] = userId;

      final response = await _client
          .from('daily_reflections')
          .upsert(reflectionData)
          .select('id')
          .single();

      return response['id'] as String;
    } catch (e) {
      debugPrint('Error saving reflection: $e');
      return null;
    }
  }

  static Future<bool> deleteReflection(String reflectionId) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      await _client
          .from('daily_reflections')
          .delete()
          .eq('id', reflectionId)
          .eq('teacher_id', userId);

      return true;
    } catch (e) {
      debugPrint('Error deleting reflection: $e');
      return false;
    }
  }

  // Event-Outcome relationships
  static Future<List<String>> getOutcomesForEvent(String eventId) async {
    try {
      final response = await _client
          .from('event_outcomes')
          .select('outcome_id')
          .eq('event_id', eventId);

      return List<String>.from(response.map((item) => item['outcome_id']));
    } catch (e) {
      debugPrint('Error fetching outcomes for event: $e');
      return [];
    }
  }

  static Future<bool> saveEventOutcomes(String eventId, List<String> outcomeIds) async {
    try {
      // First, delete existing outcomes
      await _client
          .from('event_outcomes')
          .delete()
          .eq('event_id', eventId);

      // Then insert new ones
      if (outcomeIds.isNotEmpty) {
        final data = outcomeIds.map((outcomeId) => {
              'event_id': eventId,
              'outcome_id': outcomeId,
            }).toList();

        await _client.from('event_outcomes').insert(data);
      }

      return true;
    } catch (e) {
      debugPrint('Error saving event outcomes: $e');
      return false;
    }
  }

  // Search methods
  static Future<List<Map<String, dynamic>>> searchEvents(String query) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('enhanced_events')
          .select()
          .eq('teacher_id', userId)
          .textSearch('search_vector', query)
          .order('date', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching events: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> searchReflections(String query) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      final response = await _client
          .from('daily_reflections')
          .select()
          .eq('teacher_id', userId)
          .textSearch('search_vector', query)
          .order('date', ascending: false)
          .limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error searching reflections: $e');
      return [];
    }
  }

  // Statistics and analytics
  static Future<Map<String, dynamic>> getTeacherStats(String startDate, String endDate) async {
    try {
      final userId = currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      // Get event counts by subject
      final eventStats = await _client
          .rpc('get_event_stats', params: {
            'teacher_id': userId,
            'start_date': startDate,
            'end_date': endDate,
          });

      // Get reflection stats
      final reflectionStats = await _client
          .rpc('get_reflection_stats', params: {
            'teacher_id': userId,
            'start_date': startDate,
            'end_date': endDate,
          });

      return {
        'events': eventStats,
        'reflections': reflectionStats,
      };
    } catch (e) {
      debugPrint('Error fetching teacher stats: $e');
      return {};
    }
  }

  // Real-time subscriptions
  static RealtimeChannel subscribeToEvents(String teacherId, Function(Map<String, dynamic>) onEvent) {
    return _client
        .channel('enhanced_events')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'enhanced_events',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'teacher_id',
            value: teacherId,
          ),
          callback: (payload) => onEvent(payload.newRecord),
        )
        .subscribe();
  }

  static RealtimeChannel subscribeToReflections(String teacherId, Function(Map<String, dynamic>) onReflection) {
    return _client
        .channel('daily_reflections')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'daily_reflections',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'teacher_id',
            value: teacherId,
          ),
          callback: (payload) => onReflection(payload.newRecord),
        )
        .subscribe();
  }
} 