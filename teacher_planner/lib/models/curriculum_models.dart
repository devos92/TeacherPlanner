// lib/models/curriculum_models.dart

import 'package:flutter/material.dart';

// Curriculum Data model for the service
class CurriculumData {
  final String id;
  final String name;
  final String? code;
  final String? description;
  final String? elaboration;
  final String? yearLevel;
  final String? subjectCode;
  final String? strandId;
  final String? subStrand;

  CurriculumData({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.elaboration,
    this.yearLevel,
    this.subjectCode,
    this.strandId,
    this.subStrand,
  });

  factory CurriculumData.fromJson(Map<String, dynamic> json) {
    return CurriculumData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? json['description'] ?? '',
      code: json['code'],
      description: json['description'],
      elaboration: json['elaboration'],
      yearLevel: json['year_level'],
      subjectCode: json['subject_code'],
      strandId: json['strand_id'],
      subStrand: json['sub_strand'],
    );
  }
}

// Australian Curriculum Models
class CurriculumYear {
  final String id;
  final String name;
  final String description;
  final List<CurriculumSubject> subjects;

  CurriculumYear({
    required this.id,
    required this.name,
    required this.description,
    required this.subjects,
  });
}

class CurriculumSubject {
  final String id;
  final String name;
  final String code;
  final String description;
  List<CurriculumStrand> strands;

  CurriculumSubject({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    required this.strands,
  });
}

class CurriculumStrand {
  final String id;
  final String name;
  final String description;
  List<CurriculumOutcome> outcomes;

  CurriculumStrand({
    required this.id,
    required this.name,
    required this.description,
    required this.outcomes,
  });
}

class CurriculumOutcome {
  final String id;
  final String code;
  final String description;
  final String elaboration;
  final String yearLevel;
  bool isSelected;

  CurriculumOutcome({
    required this.id,
    required this.code,
    required this.description,
    required this.elaboration,
    this.yearLevel = '',
    this.isSelected = false,
  });
}

// Attachment Models
class Attachment {
  final String id;
  final String name;
  final String url;
  final AttachmentType type;
  final DateTime uploadedAt;
  final int size; // in bytes

  Attachment({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.uploadedAt,
    required this.size,
  });
}

enum AttachmentType {
  image,
  document,
  video,
  audio,
  other,
}

// Reflection Models
class DailyReflection {
  final String id;
  final String day;
  final String content;
  final List<String> attachmentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReflection({
    required this.id,
    required this.day,
    required this.content,
    required this.attachmentIds,
    required this.createdAt,
    required this.updatedAt,
  });
}

// Enhanced Event Block with attachments and curriculum links
class EnhancedEventBlock {
  final String id;
  final String day;
  final String subject;
  final String subtitle;
  final String body;
  final Color color;
  final int startHour;
  final int startMinute;
  final int finishHour;
  final int finishMinute;
  final double widthFactor;
  final List<String> attachmentIds;
  final List<String> curriculumOutcomeIds;
  final List<String> hyperlinks;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFullWeekEvent; // Add this field to distinguish full week events

  EnhancedEventBlock({
    required this.id,
    required this.day,
    required this.subject,
    this.subtitle = '',
    this.body = '',
    required this.color,
    required this.startHour,
    this.startMinute = 0,
    required this.finishHour,
    this.finishMinute = 0,
    this.widthFactor = 1.0,
    this.attachmentIds = const [],
    this.curriculumOutcomeIds = const [],
    this.hyperlinks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFullWeekEvent = false, // Default to false for regular lessons
  });

  // Helper getter for duration in minutes
  int get durationMinutes {
    final duration = (finishHour * 60 + finishMinute) - (startHour * 60 + startMinute);
    return duration > 0 ? duration : 15;
  }

  // Helper getter for duration in hours
  double get durationHours {
    return durationMinutes / 60.0;
  }

  // Create a copy with updated fields
  EnhancedEventBlock copyWith({
    String? id,
    String? day,
    String? subject,
    String? subtitle,
    String? body,
    Color? color,
    int? startHour,
    int? startMinute,
    int? finishHour,
    int? finishMinute,
    double? widthFactor,
    List<String>? attachmentIds,
    List<String>? curriculumOutcomeIds,
    List<String>? hyperlinks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFullWeekEvent,
  }) {
    return EnhancedEventBlock(
      id: id ?? this.id,
      day: day ?? this.day,
      subject: subject ?? this.subject,
      subtitle: subtitle ?? this.subtitle,
      body: body ?? this.body,
      color: color ?? this.color,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      finishHour: finishHour ?? this.finishHour,
      finishMinute: finishMinute ?? this.finishMinute,
      widthFactor: widthFactor ?? this.widthFactor,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      curriculumOutcomeIds: curriculumOutcomeIds ?? this.curriculumOutcomeIds,
      hyperlinks: hyperlinks ?? this.hyperlinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFullWeekEvent: isFullWeekEvent ?? this.isFullWeekEvent,
    );
  }
}

// Hyperlink Model
class Hyperlink {
  final String id;
  final String title;
  final String url;
  final String description;

  Hyperlink({
    required this.id,
    required this.title,
    required this.url,
    this.description = '',
  });
} 