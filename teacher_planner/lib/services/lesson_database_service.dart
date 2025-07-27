// lib/services/lesson_database_service.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;
import '../models/weekly_plan_data.dart';
import '../models/event_block.dart';
import '../models/curriculum_models.dart';

class LessonDatabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  // Save complete weekly plan
  static Future<bool> saveCompleteWeeklyPlan(List<WeeklyPlanData> planData, DateTime weekStartDate, int periods) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      // Save the weekly plan record
      await _supabase
          .from('weekly_plans')
          .upsert({
            'teacher_id': user.id,
            'week_start_date': weekStartDate.toIso8601String().split('T')[0],
            'periods': periods,
            'plan_data': planData.map((data) => {
              'dayIndex': data.dayIndex,
              'periodIndex': data.periodIndex,
              'content': data.content,
              'subject': data.subject,
              'notes': data.notes,
              'lessonId': data.lessonId,
              'date': data.date?.toIso8601String(),
              'isLesson': data.isLesson,
              'isFullWeekEvent': data.isFullWeekEvent,
              'lessonColor': data.lessonColor != null ? {
                'r': data.lessonColor!.red,
                'g': data.lessonColor!.green,
                'b': data.lessonColor!.blue,
                'a': data.lessonColor!.alpha,
              } : null,
            }).toList(),
            'metadata': {
              'last_saved': DateTime.now().toIso8601String(),
              'lesson_count': planData.where((d) => d.isLesson).length,
            }
          });

      // Save individual lessons to enhanced_events
      final lessons = planData.where((data) => 
        data.isLesson && (data.subject.isNotEmpty || data.content.isNotEmpty)
      ).toList();

      for (final lesson in lessons) {
        final lessonData = {
          'teacher_id': user.id,
          'date': lesson.date?.toIso8601String().split('T')[0] ?? 
                  weekStartDate.add(Duration(days: lesson.dayIndex)).toIso8601String().split('T')[0],
          'start_time': '${8 + lesson.periodIndex}:00:00',
          'end_time': '${9 + lesson.periodIndex}:00:00',
          'subject': lesson.subject,
          'subtitle': 'Period ${lesson.periodIndex + 1}',
          'body': lesson.content,
          'notes': lesson.notes,
          'status': 'planned',
          'priority': 1,
          'day_index': lesson.dayIndex,
          'period_index': lesson.periodIndex,
          'lesson_id': lesson.lessonId,
          'is_full_week_event': lesson.isFullWeekEvent,
          'lesson_color': lesson.lessonColor != null ? {
            'r': lesson.lessonColor!.red,
            'g': lesson.lessonColor!.green,
            'b': lesson.lessonColor!.blue,
            'a': lesson.lessonColor!.alpha,
          } : null,
          'metadata': {
            'week_start_date': weekStartDate.toIso8601String().split('T')[0],
            'auto_saved': true,
          },
        };

        // Check if lesson already exists
        final existing = await _supabase
            .from('enhanced_events')
            .select('id')
            .eq('teacher_id', user.id)
            .eq('lesson_id', lesson.lessonId)
            .maybeSingle();

        if (existing != null) {
          // Update existing lesson
          await _supabase
              .from('enhanced_events')
              .update(lessonData)
              .eq('id', existing['id']);
        } else {
          // Insert new lesson
          await _supabase
              .from('enhanced_events')
              .insert(lessonData);
        }
      }

      debugPrint('Successfully saved weekly plan with ${lessons.length} lessons');
      return true;
    } catch (e) {
      debugPrint('Error saving weekly plan: $e');
      return false;
    }
  }

  // Load complete weekly plan
  static Future<List<WeeklyPlanData>> loadCompleteWeeklyPlan(DateTime weekStartDate) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return [];
      }

      // Try to load from weekly_plans table first
      final weekPlan = await _supabase
          .from('weekly_plans')
          .select('plan_data')
          .eq('teacher_id', user.id)
          .eq('week_start_date', weekStartDate.toIso8601String().split('T')[0])
          .maybeSingle();

      if (weekPlan != null && weekPlan['plan_data'] != null) {
        final planDataList = weekPlan['plan_data'] as List;
        return planDataList.map((data) {
          Color? lessonColor;
          if (data['lessonColor'] != null) {
            final colorData = data['lessonColor'] as Map<String, dynamic>;
            lessonColor = Color.fromARGB(
              colorData['a'] ?? 255,
              colorData['r'] ?? 0,
              colorData['g'] ?? 0,
              colorData['b'] ?? 0,
            );
          }

          return WeeklyPlanData(
            dayIndex: data['dayIndex'] ?? 0,
            periodIndex: data['periodIndex'] ?? 0,
            content: data['content'] ?? '',
            subject: data['subject'] ?? '',
            notes: data['notes'] ?? '',
            lessonId: data['lessonId'] ?? '',
            date: data['date'] != null ? DateTime.parse(data['date']) : null,
            isLesson: data['isLesson'] ?? false,
            isFullWeekEvent: data['isFullWeekEvent'] ?? false,
            lessonColor: lessonColor,
          );
        }).toList();
      }

      // Fallback: load from individual enhanced_events
      final weekEndDate = weekStartDate.add(Duration(days: 4));
      final response = await _supabase
          .from('enhanced_events')
          .select('*')
          .eq('teacher_id', user.id)
          .gte('date', weekStartDate.toIso8601String().split('T')[0])
          .lte('date', weekEndDate.toIso8601String().split('T')[0]);

      final List<WeeklyPlanData> planData = [];
      for (final event in response) {
        Color? lessonColor;
        if (event['lesson_color'] != null) {
          final colorData = event['lesson_color'] as Map<String, dynamic>;
          lessonColor = Color.fromARGB(
            colorData['a'] ?? 255,
            colorData['r'] ?? 0,
            colorData['g'] ?? 0,
            colorData['b'] ?? 0,
          );
        }

        planData.add(WeeklyPlanData(
          dayIndex: event['day_index'] ?? 0,
          periodIndex: event['period_index'] ?? 0,
          content: event['body'] ?? '',
          subject: event['subject'] ?? '',
          notes: event['notes'] ?? '',
          lessonId: event['lesson_id'] ?? event['id'].toString(),
          date: DateTime.parse(event['date']),
          isLesson: true,
          isFullWeekEvent: event['is_full_week_event'] ?? false,
          lessonColor: lessonColor,
        ));
      }

      debugPrint('Successfully loaded ${planData.length} lessons from database');
      return planData;
    } catch (e) {
      debugPrint('Error loading weekly plan: $e');
      return [];
    }
  }

  // Save lesson with attachments and links (for enhanced detail page)
  static Future<String?> saveEnhancedLesson(EnhancedEventBlock lesson) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Save/update the lesson
      final lessonData = {
        'teacher_id': user.id,
        'date': lesson.createdAt.toIso8601String().split('T')[0],
        'start_time': '${lesson.startHour.toString().padLeft(2, '0')}:${lesson.startMinute.toString().padLeft(2, '0')}:00',
        'end_time': '${lesson.finishHour.toString().padLeft(2, '0')}:${lesson.finishMinute.toString().padLeft(2, '0')}:00',
        'subject': lesson.subject,
        'subtitle': lesson.subtitle,
        'body': lesson.body,
        'notes': '', // Notes can be added if needed
        'status': 'planned',
        'lesson_color': {
          'r': lesson.color.red,
          'g': lesson.color.green,
          'b': lesson.color.blue,
          'a': lesson.color.alpha,
        },
        'metadata': {
          'updated_from_detail_page': true,
          'last_updated': DateTime.now().toIso8601String(),
        },
      };

      // If lesson has an existing ID, update; otherwise insert
      Map<String, dynamic> savedLesson;
      if (lesson.id.isNotEmpty && lesson.id != 'new') {
        savedLesson = await _supabase
            .from('enhanced_events')
            .update(lessonData)
            .eq('id', lesson.id)
            .select('id')
            .single();
      } else {
        savedLesson = await _supabase
            .from('enhanced_events')
            .insert(lessonData)
            .select('id')
            .single();
      }

      final lessonId = savedLesson['id'] as String;

      // Save attachments (update file paths to work with your storage)
      for (final attachmentPath in lesson.attachmentIds) {
        await _saveAttachmentFile(lessonId, attachmentPath);
      }

      // Save hyperlinks
      for (final linkData in lesson.hyperlinks) {
        final parts = linkData.split('|');
        final title = parts.isNotEmpty ? parts[0] : 'Link';
        final url = parts.length > 1 ? parts[1] : linkData;
        await saveLessonHyperlink(lessonId, title, url);
      }

      debugPrint('Successfully saved enhanced lesson: ${lesson.subject}');
      return lessonId;
    } catch (e) {
      debugPrint('Error saving enhanced lesson: $e');
      return null;
    }
  }

  // Save attachment file
  static Future<bool> _saveAttachmentFile(String lessonId, String filePath) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      final file = File(filePath);
      if (!file.existsSync()) return false;

      final fileName = path.basename(filePath);
      final bytes = await file.readAsBytes();
      final fileExt = path.extension(fileName);
      final storagePath = 'lesson_attachments/${user.id}/${DateTime.now().millisecondsSinceEpoch}$fileExt';

      // Upload to Supabase storage
      await _supabase.storage
          .from('teacher_files')
          .uploadBinary(storagePath, bytes);

      final publicUrl = _supabase.storage
          .from('teacher_files')
          .getPublicUrl(storagePath);

      // Save attachment record - lessonId is already UUID string
      await _supabase.from('attachments').insert({
        'teacher_id': user.id,
        'parent_id': lessonId,
        'parent_type': 'event',
        'name': fileName,
        'file_path': storagePath,
        'file_url': publicUrl,
        'file_type': _getFileType(fileExt),
        'file_size': bytes.length,
        'mime_type': _getMimeType(fileExt),
        'description': 'Uploaded from lesson detail page',
      });

      return true;
    } catch (e) {
      debugPrint('Error saving attachment: $e');
      return false;
    }
  }

  // Save lesson hyperlink
  static Future<bool> saveLessonHyperlink(String lessonId, String title, String url) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      await _supabase.from('hyperlinks').insert({
        'teacher_id': user.id,
        'parent_id': lessonId,
        'parent_type': 'event',
        'title': title,
        'url': url,
        'description': 'Added from lesson detail page',
      });

      debugPrint('Successfully saved hyperlink: $title');
      return true;
    } catch (e) {
      debugPrint('Error saving hyperlink: $e');
      return false;
    }
  }

  // Load lesson with all resources using the new view
  static Future<EnhancedEventBlock?> loadEnhancedLesson(String lessonId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return null;

      // Use the comprehensive view
      final lessonData = await _supabase
          .from('lessons_with_full_details')
          .select('*')
          .eq('teacher_id', user.id)
          .eq('id', lessonId)
          .maybeSingle();

      if (lessonData == null) return null;

      // Parse lesson color
      Color lessonColor = Colors.blue;
      if (lessonData['lesson_color'] != null) {
        final colorData = lessonData['lesson_color'] as Map<String, dynamic>;
        lessonColor = Color.fromARGB(
          colorData['a'] ?? 255,
          colorData['r'] ?? 0,
          colorData['g'] ?? 0,
          colorData['b'] ?? 0,
        );
      }

      // Parse attachments - use file_path for local storage
      final attachments = (lessonData['attachments'] as List? ?? [])
          .map((a) => a['file_path'] as String? ?? '')
          .where((path) => path.isNotEmpty)
          .toList();

      // Parse hyperlinks
      final hyperlinks = (lessonData['hyperlinks'] as List? ?? [])
          .map((h) => '${h['title']}|${h['url']}')
          .toList();

      // Parse start/end times
      final startTimeParts = (lessonData['start_time'] as String? ?? '8:00:00').split(':');
      final endTimeParts = (lessonData['end_time'] as String? ?? '9:00:00').split(':');

      return EnhancedEventBlock(
        id: lessonData['id'],
        day: _getDayName(lessonData['day_index'] ?? 0),
        subject: lessonData['subject'] ?? '',
        subtitle: lessonData['subtitle'] ?? '',
        body: lessonData['body'] ?? '',
        color: lessonColor,
        startHour: int.tryParse(startTimeParts[0]) ?? 8,
        startMinute: int.tryParse(startTimeParts[1]) ?? 0,
        finishHour: int.tryParse(endTimeParts[0]) ?? 9,
        finishMinute: int.tryParse(endTimeParts[1]) ?? 0,
        widthFactor: 1.0,
        attachmentIds: attachments,
        curriculumOutcomeIds: [], // TODO: Parse curriculum outcomes from the view
        hyperlinks: hyperlinks,
        createdAt: DateTime.parse(lessonData['created_at']),
        updatedAt: DateTime.parse(lessonData['updated_at']),
        isFullWeekEvent: lessonData['is_full_week_event'] ?? false,
      );
    } catch (e) {
      debugPrint('Error loading enhanced lesson: $e');
      return null;
    }
  }

  // Helper methods (same as before)
  static String _getFileType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
      case '.png':
      case '.gif':
      case '.bmp':
      case '.webp':
        return 'image';
      case '.pdf':
      case '.doc':
      case '.docx':
      case '.txt':
        return 'document';
      case '.mp4':
      case '.avi':
      case '.mov':
        return 'video';
      case '.mp3':
      case '.wav':
        return 'audio';
      default:
        return 'other';
    }
  }

  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.txt':
        return 'text/plain';
      case '.mp4':
        return 'video/mp4';
      case '.mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }

  static String _getDayName(int dayIndex) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    return dayIndex < days.length ? days[dayIndex] : 'Monday';
  }

  // Delete lesson
  static Future<bool> deleteLesson(String lessonId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return false;

      // Delete from enhanced_events (cascade will handle attachments/hyperlinks)
      await _supabase
          .from('enhanced_events')
          .delete()
          .eq('teacher_id', user.id)
          .eq('id', lessonId);

      debugPrint('Successfully deleted lesson: $lessonId');
      return true;
    } catch (e) {
      debugPrint('Error deleting lesson: $e');
      return false;
    }
  }
} 