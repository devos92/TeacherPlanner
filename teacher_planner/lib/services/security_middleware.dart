// lib/services/security_middleware.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';
import 'auth_service.dart';

/// Security middleware for protecting routes and validating authentication
/// Adapted from JS authenticateToken pattern
class SecurityMiddleware {
  static SecurityMiddleware? _instance;
  static SecurityMiddleware get instance => _instance ??= SecurityMiddleware._();
  
  SecurityMiddleware._();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Check if user has required role (matching JS role-based access)
  Future<bool> hasRole(String requiredRole) async {
    try {
      final currentUser = await AuthService.instance.getCurrentUser();
      if (currentUser == null) return false;

      return currentUser.role == requiredRole;
    } catch (e) {
      debugPrint('Role check error: $e');
      return false;
    }
  }

  /// Check if user is admin (matching JS admin checks)
  Future<bool> isAdmin() async {
    return await hasRole('admin');
  }

  /// Check if user is teacher (matching JS role checks)
  Future<bool> isTeacher() async {
    return await hasRole('teacher');
  }

  /// Validate session and refresh if needed (matching JS authenticateToken pattern)
  Future<bool> validateSession() async {
    try {
      final isAuthenticated = await AuthService.instance.isAuthenticated();
      if (!isAuthenticated) {
        // Try to refresh token (matching JS handleRefreshToken pattern)
        final refreshResult = await AuthService.instance.refreshToken();
        return refreshResult.success;
      }
      return true;
    } catch (e) {
      debugPrint('Session validation error: $e');
      return false;
    }
  }

  /// Check if user can access resource (matching JS authorization pattern)
  Future<bool> canAccessResource(String resourceId, String resourceType) async {
    try {
      final currentUser = await AuthService.instance.getCurrentUser();
      if (currentUser == null) return false;

      // Admin can access everything
      if (currentUser.role == 'admin') return true;

      // Check resource ownership or permissions
      switch (resourceType) {
        case 'weekly_plan':
          return await _canAccessWeeklyPlan(resourceId, currentUser.id);
        case 'term_plan':
          return await _canAccessTermPlan(resourceId, currentUser.id);
        case 'long_term_plan':
          return await _canAccessLongTermPlan(resourceId, currentUser.id);
        case 'curriculum':
          return await _canAccessCurriculum(resourceId, currentUser.id);
        default:
          return false;
      }
    } catch (e) {
      debugPrint('Resource access check error: $e');
      return false;
    }
  }

  /// Check if user can access weekly plan
  Future<bool> _canAccessWeeklyPlan(String planId, String userId) async {
    try {
      final plan = await _supabase
          .from('weekly_plans')
          .select('user_id')
          .eq('id', planId)
          .maybeSingle();
      
      return plan != null && plan['user_id'] == userId;
    } catch (e) {
      return false;
    }
  }

  /// Check if user can access term plan
  Future<bool> _canAccessTermPlan(String planId, String userId) async {
    try {
      final plan = await _supabase
          .from('term_plans')
          .select('user_id')
          .eq('id', planId)
          .maybeSingle();
      
      return plan != null && plan['user_id'] == userId;
    } catch (e) {
      return false;
    }
  }

  /// Check if user can access long term plan
  Future<bool> _canAccessLongTermPlan(String planId, String userId) async {
    try {
      final plan = await _supabase
          .from('long_term_plans')
          .select('user_id')
          .eq('id', planId)
          .maybeSingle();
      
      return plan != null && plan['user_id'] == userId;
    } catch (e) {
      return false;
    }
  }

  /// Check if user can access curriculum
  Future<bool> _canAccessCurriculum(String curriculumId, String userId) async {
    try {
      // Curriculum is typically shared, but we can add user-specific access
      final curriculum = await _supabase
          .from('curriculum')
          .select('is_public, created_by')
          .eq('id', curriculumId)
          .maybeSingle();
      
      if (curriculum == null) return false;
      
      // Public curriculum or user's own curriculum
      return curriculum['is_public'] == true || curriculum['created_by'] == userId;
    } catch (e) {
      return false;
    }
  }

  /// Log security event (matching JS audit logging pattern)
  Future<void> logSecurityEvent({
    required String action,
    required String userId,
    String? resourceId,
    String? resourceType,
    String? details,
  }) async {
    try {
      await _supabase.from('audit_logs').insert({
        'user_id': userId,
        'action': action,
        'table_name': resourceType,
        'record_id': resourceId,
        'details': details,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Error logging security event: $e');
    }
  }

  /// Validate input data (matching JS validation patterns)
  bool validateInput(Map<String, dynamic> data, List<String> requiredFields) {
    for (final field in requiredFields) {
      if (!data.containsKey(field) || data[field] == null || data[field].toString().isEmpty) {
        return false;
      }
    }
    return true;
  }

  /// Sanitize user input (matching JS input sanitization)
  String sanitizeInput(String input) {
    // Remove potentially dangerous characters
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .trim();
  }

  /// Check rate limiting for specific actions
  Future<bool> checkRateLimit(String action, String userId) async {
    try {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(Duration(minutes: 1));
      
      final recentActions = await _supabase
          .from('audit_logs')
          .select('created_at')
          .eq('user_id', userId)
          .eq('action', action)
          .gte('created_at', oneMinuteAgo.toIso8601String());
      
      // Limit to 10 actions per minute
      return recentActions.length < 10;
    } catch (e) {
      debugPrint('Rate limit check error: $e');
      return true; // Allow if check fails
    }
  }

  /// Validate file upload (matching JS file validation)
  bool validateFileUpload(String fileName, int fileSize, List<String> allowedTypes) {
    // Check file size (max 10MB)
    if (fileSize > 10 * 1024 * 1024) return false;
    
    // Check file extension
    final extension = fileName.split('.').last.toLowerCase();
    return allowedTypes.contains(extension);
  }

  /// Generate secure random string (matching JS crypto patterns)
  String generateSecureString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
    );
  }

  /// Hash sensitive data (matching JS hashing patterns)
  String hashSensitiveData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

/// Security context for route protection
class SecurityContext {
  final String userId;
  final String userRole;
  final bool isAuthenticated;
  final DateTime sessionStart;

  SecurityContext({
    required this.userId,
    required this.userRole,
    required this.isAuthenticated,
    required this.sessionStart,
  });

  bool get isAdmin => userRole == 'admin';
  bool get isTeacher => userRole == 'teacher';
  bool get isPrincipal => userRole == 'principal';
  bool get isAssistant => userRole == 'assistant';

  Duration get sessionDuration => DateTime.now().difference(sessionStart);
} 