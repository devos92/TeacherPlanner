// lib/models/user_model.dart

import 'package:flutter/foundation.dart';

/// Secure user model with proper validation and serialization
class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? school;
  final String? role;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool emailVerified;
  final DateTime? lastLogin;
  final int loginAttempts;
  final DateTime? lockedUntil;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.school,
    this.role,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
    required this.emailVerified,
    this.lastLogin,
    required this.loginAttempts,
    this.lockedUntil,
  });

  /// Create user model from JSON with validation
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['first_name'] as String,
        lastName: json['last_name'] as String,
        school: json['school'] as String?,
        role: json['role'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        isActive: json['is_active'] as bool? ?? true,
        emailVerified: json['email_verified'] as bool? ?? false,
        lastLogin: json['last_login'] != null 
          ? DateTime.parse(json['last_login'] as String)
          : null,
        loginAttempts: json['login_attempts'] as int? ?? 0,
        lockedUntil: json['locked_until'] != null 
          ? DateTime.parse(json['locked_until'] as String)
          : null,
      );
    } catch (e) {
      debugPrint('Error creating UserModel from JSON: $e');
      rethrow;
    }
  }

  /// Convert user model to JSON (excluding sensitive data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'school': school,
      'role': role,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
      'email_verified': emailVerified,
      'last_login': lastLogin?.toIso8601String(),
      'login_attempts': loginAttempts,
      'locked_until': lockedUntil?.toIso8601String(),
    };
  }

  /// Create a copy of the user model with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? school,
    String? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? emailVerified,
    DateTime? lastLogin,
    int? loginAttempts,
    DateTime? lockedUntil,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      school: school ?? this.school,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      loginAttempts: loginAttempts ?? this.loginAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
    );
  }

  /// Get user's full name
  String get fullName => '$firstName $lastName';

  /// Get user's display name (first name only)
  String get displayName => firstName;

  /// Get user's initials
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Check if user account is locked
  bool get isLocked {
    if (lockedUntil == null) return false;
    return DateTime.now().isBefore(lockedUntil!);
  }

  /// Check if user can login
  bool get canLogin {
    return isActive && !isLocked && emailVerified;
  }

  /// Get user's role display name
  String get roleDisplayName {
    switch (role?.toLowerCase()) {
      case 'teacher':
        return 'Teacher';
      case 'admin':
        return 'Administrator';
      case 'principal':
        return 'Principal';
      case 'assistant':
        return 'Teaching Assistant';
      default:
        return 'Teacher';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, firstName: $firstName, lastName: $lastName, role: $role)';
  }
}
 