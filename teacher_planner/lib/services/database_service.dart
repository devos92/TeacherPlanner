import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/database_models.dart';

class DatabaseService {
  static DatabaseService? _instance;
  static DatabaseService get instance => _instance ??= DatabaseService._();
  
  DatabaseService._();
  
  final SupabaseClient _supabase = Supabase.instance.client;

  // User Management
  Future<DatabaseUser?> getUserById(String userId) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return DatabaseUser.fromJson(response);
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<DatabaseUser?> getUserByEmail(String email) async {
    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .single();
      
      return DatabaseUser.fromJson(response);
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<DatabaseUser?> createUser({
    required String email,
    required String passwordHash,
    required String salt,
    String? firstName,
    String? lastName,
  }) async {
    try {
      final response = await _supabase
          .from('users')
          .insert({
            'email': email,
            'password_hash': passwordHash,
            'salt': salt,
            'first_name': firstName,
            'last_name': lastName,
            'is_active': true,
            'is_email_verified': false,
          })
          .select()
          .single();
      
      return DatabaseUser.fromJson(response);
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('users')
          .update(updates)
          .eq('id', userId);
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  // Weekly Plans
  Future<List<WeeklyPlan>> getWeeklyPlans(String userId) async {
    try {
      final response = await _supabase
          .from('weekly_plans')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response.map((json) => WeeklyPlan.fromJson(json)).toList();
    } catch (e) {
      print('Error getting weekly plans: $e');
      return [];
    }
  }

  Future<WeeklyPlan?> createWeeklyPlan({
    required String userId,
    required String title,
    String? subtitle,
    String? description,
    required DateTime startDate,
    required DateTime endDate,
    String? color,
  }) async {
    try {
      final response = await _supabase
          .from('weekly_plans')
          .insert({
            'user_id': userId,
            'title': title,
            'subtitle': subtitle,
            'description': description,
            'start_date': startDate.toIso8601String().split('T')[0],
            'end_date': endDate.toIso8601String().split('T')[0],
            'color': color,
          })
          .select()
          .single();
      
      return WeeklyPlan.fromJson(response);
    } catch (e) {
      print('Error creating weekly plan: $e');
      return null;
    }
  }

  Future<bool> updateWeeklyPlan(String planId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('weekly_plans')
          .update(updates)
          .eq('id', planId);
      return true;
    } catch (e) {
      print('Error updating weekly plan: $e');
      return false;
    }
  }

  Future<bool> deleteWeeklyPlan(String planId) async {
    try {
      await _supabase
          .from('weekly_plans')
          .delete()
          .eq('id', planId);
      return true;
    } catch (e) {
      print('Error deleting weekly plan: $e');
      return false;
    }
  }

  // Daily Details
  Future<List<DailyDetail>> getDailyDetails(String weeklyPlanId) async {
    try {
      final response = await _supabase
          .from('daily_details')
          .select()
          .eq('weekly_plan_id', weeklyPlanId)
          .order('date', ascending: true);
      
      return response.map((json) => DailyDetail.fromJson(json)).toList();
    } catch (e) {
      print('Error getting daily details: $e');
      return [];
    }
  }

  Future<DailyDetail?> createDailyDetail({
    required String weeklyPlanId,
    required DateTime date,
    required String title,
    String? subtitle,
    String? description,
    String? notes,
    String? headerText,
    String? color,
    int? startHour,
    int? startMinute,
    int? finishHour,
    int? finishMinute,
    int? periodIndex,
    double? widthFactor,
    bool isFullWeekEvent = false,
  }) async {
    try {
      final response = await _supabase
          .from('daily_details')
          .insert({
            'weekly_plan_id': weeklyPlanId,
            'date': date.toIso8601String().split('T')[0],
            'title': title,
            'subtitle': subtitle,
            'description': description,
            'notes': notes,
            'header_text': headerText,
            'color': color,
            'start_hour': startHour,
            'start_minute': startMinute,
            'finish_hour': finishHour,
            'finish_minute': finishMinute,
            'period_index': periodIndex,
            'width_factor': widthFactor,
            'is_full_week_event': isFullWeekEvent,
          })
          .select()
          .single();
      
      return DailyDetail.fromJson(response);
    } catch (e) {
      print('Error creating daily detail: $e');
      return null;
    }
  }

  Future<bool> updateDailyDetail(String detailId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('daily_details')
          .update(updates)
          .eq('id', detailId);
      return true;
    } catch (e) {
      print('Error updating daily detail: $e');
      return false;
    }
  }

  Future<bool> deleteDailyDetail(String detailId) async {
    try {
      await _supabase
          .from('daily_details')
          .delete()
          .eq('id', detailId);
      return true;
    } catch (e) {
      print('Error deleting daily detail: $e');
      return false;
    }
  }

  // Weekly Plan Cells
  Future<List<WeeklyPlanCell>> getWeeklyPlanCells(String weeklyPlanId) async {
    try {
      final response = await _supabase
          .from('weekly_plan_cells')
          .select()
          .eq('weekly_plan_id', weeklyPlanId)
          .order('day_index', ascending: true)
          .order('period_index', ascending: true);
      
      return response.map((json) => WeeklyPlanCell.fromJson(json)).toList();
    } catch (e) {
      print('Error getting weekly plan cells: $e');
      return [];
    }
  }

  Future<WeeklyPlanCell?> createWeeklyPlanCell({
    required String weeklyPlanId,
    required int dayIndex,
    required int periodIndex,
    String? content,
    String? subject,
    String? notes,
    String? lessonId,
    DateTime? date,
    bool isLesson = false,
    bool isFullWeekEvent = false,
    List<Map<String, dynamic>> subLessons = const [],
    int? lessonColor,
  }) async {
    try {
      final response = await _supabase
          .from('weekly_plan_cells')
          .insert({
            'weekly_plan_id': weeklyPlanId,
            'day_index': dayIndex,
            'period_index': periodIndex,
            'content': content,
            'subject': subject,
            'notes': notes,
            'lesson_id': lessonId,
            'date': date?.toIso8601String(),
            'is_lesson': isLesson,
            'is_full_week_event': isFullWeekEvent,
            'sub_lessons': jsonEncode(subLessons),
            'lesson_color': lessonColor,
          })
          .select()
          .single();
      
      return WeeklyPlanCell.fromJson(response);
    } catch (e) {
      print('Error creating weekly plan cell: $e');
      return null;
    }
  }

  Future<bool> updateWeeklyPlanCell(String cellId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('weekly_plan_cells')
          .update(updates)
          .eq('id', cellId);
      return true;
    } catch (e) {
      print('Error updating weekly plan cell: $e');
      return false;
    }
  }

  Future<bool> deleteWeeklyPlanCell(String cellId) async {
    try {
      await _supabase
          .from('weekly_plan_cells')
          .delete()
          .eq('id', cellId);
      return true;
    } catch (e) {
      print('Error deleting weekly plan cell: $e');
      return false;
    }
  }

  // Attachments
  Future<List<Attachment>> getAttachments(String parentId, String tableName) async {
    try {
      final response = await _supabase
          .from('${tableName}_attachments')
          .select()
          .eq('${tableName}_id', parentId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Attachment.fromJson(json)).toList();
    } catch (e) {
      print('Error getting attachments: $e');
      return [];
    }
  }

  Future<Attachment?> createAttachment({
    required String parentId,
    required String tableName,
    required String filePath,
    String? name,
    String? mimeType,
    int? size,
  }) async {
    try {
      final response = await _supabase
          .from('${tableName}_attachments')
          .insert({
            '${tableName}_id': parentId,
            'file_path': filePath,
            'name': name,
            'mime_type': mimeType,
            'size': size,
          })
          .select()
          .single();
      
      return Attachment.fromJson(response);
    } catch (e) {
      print('Error creating attachment: $e');
      return null;
    }
  }

  Future<bool> deleteAttachment(String attachmentId, String tableName) async {
    try {
      await _supabase
          .from('${tableName}_attachments')
          .delete()
          .eq('id', attachmentId);
      return true;
    } catch (e) {
      print('Error deleting attachment: $e');
      return false;
    }
  }

  // Hyperlinks
  Future<List<Hyperlink>> getHyperlinks(String parentId, String tableName) async {
    try {
      final response = await _supabase
          .from('${tableName}_hyperlinks')
          .select()
          .eq('${tableName}_id', parentId)
          .order('created_at', ascending: false);
      
      return response.map((json) => Hyperlink.fromJson(json)).toList();
    } catch (e) {
      print('Error getting hyperlinks: $e');
      return [];
    }
  }

  Future<Hyperlink?> createHyperlink({
    required String parentId,
    required String tableName,
    String? title,
    required String url,
  }) async {
    try {
      final response = await _supabase
          .from('${tableName}_hyperlinks')
          .insert({
            '${tableName}_id': parentId,
            'title': title,
            'url': url,
          })
          .select()
          .single();
      
      return Hyperlink.fromJson(response);
    } catch (e) {
      print('Error creating hyperlink: $e');
      return null;
    }
  }

  Future<bool> deleteHyperlink(String hyperlinkId, String tableName) async {
    try {
      await _supabase
          .from('${tableName}_hyperlinks')
          .delete()
          .eq('id', hyperlinkId);
      return true;
    } catch (e) {
      print('Error deleting hyperlink: $e');
      return false;
    }
  }

  // Curriculum Data
  Future<List<Curriculum>> getCurriculum({
    int? learningAreaId,
    int? subjectId,
    int? levelId,
    int? strandId,
    int? subStrandId,
  }) async {
    try {
      var query = _supabase.from('curriculum').select();
      
      if (learningAreaId != null) {
        query = query.eq('learning_area_id', learningAreaId);
      }
      if (subjectId != null) {
        query = query.eq('subject_id', subjectId);
      }
      if (levelId != null) {
        query = query.eq('level_id', levelId);
      }
      if (strandId != null) {
        query = query.eq('strand_id', strandId);
      }
      if (subStrandId != null) {
        query = query.eq('sub_strand_id', subStrandId);
      }
      
      final response = await query;
      return response.map((json) => Curriculum.fromJson(json)).toList();
    } catch (e) {
      print('Error getting curriculum: $e');
      return [];
    }
  }

  Future<List<Subject>> getSubjects() async {
    try {
      final response = await _supabase
          .from('subject')
          .select()
          .order('name');
      
      return response.map((json) => Subject.fromJson(json)).toList();
    } catch (e) {
      print('Error getting subjects: $e');
      return [];
    }
  }

  Future<List<LearningArea>> getLearningAreas() async {
    try {
      final response = await _supabase
          .from('learning_area')
          .select()
          .order('name');
      
      return response.map((json) => LearningArea.fromJson(json)).toList();
    } catch (e) {
      print('Error getting learning areas: $e');
      return [];
    }
  }

  Future<List<Level>> getLevels() async {
    try {
      final response = await _supabase
          .from('level')
          .select()
          .order('name');
      
      return response.map((json) => Level.fromJson(json)).toList();
    } catch (e) {
      print('Error getting levels: $e');
      return [];
    }
  }

  Future<List<Strand>> getStrands() async {
    try {
      final response = await _supabase
          .from('strand')
          .select()
          .order('name');
      
      return response.map((json) => Strand.fromJson(json)).toList();
    } catch (e) {
      print('Error getting strands: $e');
      return [];
    }
  }

  Future<List<SubStrand>> getSubStrands() async {
    try {
      final response = await _supabase
          .from('sub_strand')
          .select()
          .order('name');
      
      return response.map((json) => SubStrand.fromJson(json)).toList();
    } catch (e) {
      print('Error getting sub strands: $e');
      return [];
    }
  }

  // Long Term Plans
  Future<List<LongTermPlan>> getLongTermPlans(String userId) async {
    try {
      final response = await _supabase
          .from('long_term_plans')
          .select()
          .eq('user_id', userId)
          .order('year', ascending: false);
      
      return response.map((json) => LongTermPlan.fromJson(json)).toList();
    } catch (e) {
      print('Error getting long term plans: $e');
      return [];
    }
  }

  Future<LongTermPlan?> createLongTermPlan({
    required String userId,
    required int subjectId,
    required int year,
    int? color,
    String? details,
  }) async {
    try {
      final response = await _supabase
          .from('long_term_plans')
          .insert({
            'user_id': userId,
            'subject_id': subjectId,
            'year': year,
            'color': color,
            'details': details,
          })
          .select()
          .single();
      
      return LongTermPlan.fromJson(response);
    } catch (e) {
      print('Error creating long term plan: $e');
      return null;
    }
  }

  Future<bool> updateLongTermPlan(String planId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('long_term_plans')
          .update(updates)
          .eq('id', planId);
      return true;
    } catch (e) {
      print('Error updating long term plan: $e');
      return false;
    }
  }

  Future<bool> deleteLongTermPlan(String planId) async {
    try {
      await _supabase
          .from('long_term_plans')
          .delete()
          .eq('id', planId);
      return true;
    } catch (e) {
      print('Error deleting long term plan: $e');
      return false;
    }
  }

  // Term Planners
  Future<List<TermPlanner>> getTermPlanners(String userId) async {
    try {
      final response = await _supabase
          .from('term_planners')
          .select()
          .eq('user_id', userId)
          .order('start_date', ascending: false);
      
      return response.map((json) => TermPlanner.fromJson(json)).toList();
    } catch (e) {
      print('Error getting term planners: $e');
      return [];
    }
  }

  Future<TermPlanner?> createTermPlanner({
    required String userId,
    required String name,
    required DateTime startDate,
    required int weekCount,
  }) async {
    try {
      final response = await _supabase
          .from('term_planners')
          .insert({
            'user_id': userId,
            'name': name,
            'start_date': startDate.toIso8601String(),
            'week_count': weekCount,
          })
          .select()
          .single();
      
      return TermPlanner.fromJson(response);
    } catch (e) {
      print('Error creating term planner: $e');
      return null;
    }
  }

  Future<bool> updateTermPlanner(String plannerId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('term_planners')
          .update(updates)
          .eq('id', plannerId);
      return true;
    } catch (e) {
      print('Error updating term planner: $e');
      return false;
    }
  }

  Future<bool> deleteTermPlanner(String plannerId) async {
    try {
      await _supabase
          .from('term_planners')
          .delete()
          .eq('id', plannerId);
      return true;
    } catch (e) {
      print('Error deleting term planner: $e');
      return false;
    }
  }

  // Term Events
  Future<List<TermEvent>> getTermEvents(String termPlannerId) async {
    try {
      final response = await _supabase
          .from('term_events')
          .select()
          .eq('term_planner_id', termPlannerId)
          .order('start_date', ascending: true);
      
      return response.map((json) => TermEvent.fromJson(json)).toList();
    } catch (e) {
      print('Error getting term events: $e');
      return [];
    }
  }

  Future<TermEvent?> createTermEvent({
    required String termPlannerId,
    required String title,
    String? description,
    required DateTime startDate,
    DateTime? endDate,
    required String type,
    int? color,
  }) async {
    try {
      final response = await _supabase
          .from('term_events')
          .insert({
            'term_planner_id': termPlannerId,
            'title': title,
            'description': description,
            'start_date': startDate.toIso8601String(),
            'end_date': endDate?.toIso8601String(),
            'type': type,
            'color': color,
          })
          .select()
          .single();
      
      return TermEvent.fromJson(response);
    } catch (e) {
      print('Error creating term event: $e');
      return null;
    }
  }

  Future<bool> updateTermEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('term_events')
          .update(updates)
          .eq('id', eventId);
      return true;
    } catch (e) {
      print('Error updating term event: $e');
      return false;
    }
  }

  Future<bool> deleteTermEvent(String eventId) async {
    try {
      await _supabase
          .from('term_events')
          .delete()
          .eq('id', eventId);
      return true;
    } catch (e) {
      print('Error deleting term event: $e');
      return false;
    }
  }

  // Weekly Plan Events
  Future<List<WeeklyPlanEvent>> getWeeklyPlanEvents(String weeklyPlanId) async {
    try {
      final response = await _supabase
          .from('weekly_plan_events')
          .select()
          .eq('weekly_plan_id', weeklyPlanId)
          .order('event_date', ascending: true);
      
      return response.map((json) => WeeklyPlanEvent.fromJson(json)).toList();
    } catch (e) {
      print('Error getting weekly plan events: $e');
      return [];
    }
  }

  Future<WeeklyPlanEvent?> createWeeklyPlanEvent({
    required String weeklyPlanId,
    required String title,
    String? description,
    required DateTime eventDate,
    String? color,
  }) async {
    try {
      final response = await _supabase
          .from('weekly_plan_events')
          .insert({
            'weekly_plan_id': weeklyPlanId,
            'title': title,
            'description': description,
            'event_date': eventDate.toIso8601String(),
            'color': color,
          })
          .select()
          .single();
      
      return WeeklyPlanEvent.fromJson(response);
    } catch (e) {
      print('Error creating weekly plan event: $e');
      return null;
    }
  }

  Future<bool> updateWeeklyPlanEvent(String eventId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('weekly_plan_events')
          .update(updates)
          .eq('id', eventId);
      return true;
    } catch (e) {
      print('Error updating weekly plan event: $e');
      return false;
    }
  }

  Future<bool> deleteWeeklyPlanEvent(String eventId) async {
    try {
      await _supabase
          .from('weekly_plan_events')
          .delete()
          .eq('id', eventId);
      return true;
    } catch (e) {
      print('Error deleting weekly plan event: $e');
      return false;
    }
  }

  // Daily Reflections
  Future<List<DailyReflection>> getDailyReflections(String dailyDetailId) async {
    try {
      final response = await _supabase
          .from('daily_reflections')
          .select()
          .eq('daily_detail_id', dailyDetailId)
          .order('created_at', ascending: false);
      
      return response.map((json) => DailyReflection.fromJson(json)).toList();
    } catch (e) {
      print('Error getting daily reflections: $e');
      return [];
    }
  }

  Future<DailyReflection?> createDailyReflection({
    required String dailyDetailId,
    String? day,
    required String reflectionText,
  }) async {
    try {
      final response = await _supabase
          .from('daily_reflections')
          .insert({
            'daily_detail_id': dailyDetailId,
            'day': day,
            'reflection_text': reflectionText,
          })
          .select()
          .single();
      
      return DailyReflection.fromJson(response);
    } catch (e) {
      print('Error creating daily reflection: $e');
      return null;
    }
  }

  Future<bool> updateDailyReflection(String reflectionId, Map<String, dynamic> updates) async {
    try {
      await _supabase
          .from('daily_reflections')
          .update(updates)
          .eq('id', reflectionId);
      return true;
    } catch (e) {
      print('Error updating daily reflection: $e');
      return false;
    }
  }

  Future<bool> deleteDailyReflection(String reflectionId) async {
    try {
      await _supabase
          .from('daily_reflections')
          .delete()
          .eq('id', reflectionId);
      return true;
    } catch (e) {
      print('Error deleting daily reflection: $e');
      return false;
    }
  }

  // Email Verification
  Future<EmailVerification?> createEmailVerification({
    required String userId,
    required String token,
    required DateTime expiresAt,
  }) async {
    try {
      final response = await _supabase
          .from('email_verifications')
          .insert({
            'user_id': userId,
            'token': token,
            'expires_at': expiresAt.toIso8601String(),
          })
          .select()
          .single();
      
      return EmailVerification.fromJson(response);
    } catch (e) {
      print('Error creating email verification: $e');
      return null;
    }
  }

  Future<EmailVerification?> getEmailVerification(String token) async {
    try {
      final response = await _supabase
          .from('email_verifications')
          .select()
          .eq('token', token)
          .single();
      
      return EmailVerification.fromJson(response);
    } catch (e) {
      print('Error getting email verification: $e');
      return null;
    }
  }

  Future<bool> deleteEmailVerification(String token) async {
    try {
      await _supabase
          .from('email_verifications')
          .delete()
          .eq('token', token);
      return true;
    } catch (e) {
      print('Error deleting email verification: $e');
      return false;
    }
  }

  // Password Reset Tokens
  Future<PasswordResetToken?> createPasswordResetToken({
    required String userId,
    required String token,
    required DateTime expiresAt,
  }) async {
    try {
      final response = await _supabase
          .from('password_reset_tokens')
          .insert({
            'user_id': userId,
            'token': token,
            'expires_at': expiresAt.toIso8601String(),
          })
          .select()
          .single();
      
      return PasswordResetToken.fromJson(response);
    } catch (e) {
      print('Error creating password reset token: $e');
      return null;
    }
  }

  Future<PasswordResetToken?> getPasswordResetToken(String token) async {
    try {
      final response = await _supabase
          .from('password_reset_tokens')
          .select()
          .eq('token', token)
          .single();
      
      return PasswordResetToken.fromJson(response);
    } catch (e) {
      print('Error getting password reset token: $e');
      return null;
    }
  }

  Future<bool> deletePasswordResetToken(String token) async {
    try {
      await _supabase
          .from('password_reset_tokens')
          .delete()
          .eq('token', token);
      return true;
    } catch (e) {
      print('Error deleting password reset token: $e');
      return false;
    }
  }

  // User Settings
  Future<UserSettings?> getUserSettings(String userId) async {
    try {
      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .single();
      
      return UserSettings.fromJson(response);
    } catch (e) {
      print('Error getting user settings: $e');
      return null;
    }
  }

  Future<bool> updateUserSettings(String userId, Map<String, dynamic> settings) async {
    try {
      await _supabase
          .from('user_settings')
          .upsert({
            'user_id': userId,
            'settings': settings,
          });
      return true;
    } catch (e) {
      print('Error updating user settings: $e');
      return false;
    }
  }
} 