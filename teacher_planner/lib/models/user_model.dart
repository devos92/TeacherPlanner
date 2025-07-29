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
  final bool isActive;
  final int loginAttempts;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.school,
    this.role,
    required this.isActive,
    required this.loginAttempts,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create user model from JSON with validation
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      school: json['school'] as String?,
      role: json['role'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      loginAttempts: json['login_attempts'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
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
      'is_active': isActive,
      'login_attempts': loginAttempts,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
    int? loginAttempts,
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
      loginAttempts: loginAttempts ?? this.loginAttempts,
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
    return false; // No locking mechanism in current schema
  }

  /// Check if user can login
  bool get canLogin {
    return isActive && !isLocked;
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
 