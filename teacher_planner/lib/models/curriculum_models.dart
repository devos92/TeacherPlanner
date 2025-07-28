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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'elaboration': elaboration,
      'year_level': yearLevel,
      'subject_code': subjectCode,
      'strand_id': strandId,
      'sub_strand': subStrand,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'description': description,
      'elaboration': elaboration,
      'year_level': yearLevel,
    };
  }

  factory CurriculumOutcome.fromJson(Map<String, dynamic> json) {
    return CurriculumOutcome(
      id: json['id'] as String,
      code: json['code'] as String,
      description: json['description'] as String,
      elaboration: json['elaboration'] as String,
      yearLevel: json['year_level'] as String,
      isSelected: json['is_selected'] as bool? ?? false,
    );
  }
}

// Attachment Models
class Attachment {
  final String id;
  final String name;
  final String path;
  final String type;
  final int size;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.name,
    required this.path,
    required this.type,
    required this.size,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'path': path,
      'type': type,
      'size': size,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['path'] as String,
      type: json['type'] as String,
      size: json['size'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
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
  final String notes; // Add notes property
  final Color color;
  final int startHour;
  final int startMinute;
  final int finishHour;
  final int finishMinute;
  final int periodIndex; // Add period index property
  final double widthFactor;
  final List<String> attachmentIds;
  final List<Attachment> attachments; // Add attachments list
  final List<String> curriculumOutcomeIds;
  final List<CurriculumOutcome> curriculumOutcomes; // Add curriculum outcomes list
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
    this.notes = '', // Default notes
    required this.color,
    required this.startHour,
    this.startMinute = 0,
    required this.finishHour,
    this.finishMinute = 0,
    this.periodIndex = 0, // Default period index
    this.widthFactor = 1.0,
    this.attachmentIds = const [],
    this.attachments = const [], // Default empty attachments
    this.curriculumOutcomeIds = const [],
    this.curriculumOutcomes = const [], // Default empty outcomes
    this.hyperlinks = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isFullWeekEvent = false, // Default to false for regular lessons
  });

  // Helper getter for start time string
  String get startTime {
    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  }

  // Helper getter for end time string
  String get endTime {
    return '${finishHour.toString().padLeft(2, '0')}:${finishMinute.toString().padLeft(2, '0')}';
  }

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
    String? notes,
    Color? color,
    int? startHour,
    int? startMinute,
    int? finishHour,
    int? finishMinute,
    int? periodIndex,
    double? widthFactor,
    List<String>? attachmentIds,
    List<Attachment>? attachments,
    List<String>? curriculumOutcomeIds,
    List<CurriculumOutcome>? curriculumOutcomes,
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
      notes: notes ?? this.notes,
      color: color ?? this.color,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      finishHour: finishHour ?? this.finishHour,
      finishMinute: finishMinute ?? this.finishMinute,
      periodIndex: periodIndex ?? this.periodIndex,
      widthFactor: widthFactor ?? this.widthFactor,
      attachmentIds: attachmentIds ?? this.attachmentIds,
      attachments: attachments ?? this.attachments,
      curriculumOutcomeIds: curriculumOutcomeIds ?? this.curriculumOutcomeIds,
      curriculumOutcomes: curriculumOutcomes ?? this.curriculumOutcomes,
      hyperlinks: hyperlinks ?? this.hyperlinks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFullWeekEvent: isFullWeekEvent ?? this.isFullWeekEvent,
    );
  }

  // JSON serialization for caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'subject': subject,
      'subtitle': subtitle,
      'body': body,
      'notes': notes,
      'color': color.value,
      'startHour': startHour,
      'startMinute': startMinute,
      'finishHour': finishHour,
      'finishMinute': finishMinute,
      'periodIndex': periodIndex,
      'widthFactor': widthFactor,
      'attachmentIds': attachmentIds,
      'attachments': attachments.map((e) => e.toJson()).toList(),
      'curriculumOutcomeIds': curriculumOutcomeIds,
      'curriculumOutcomes': curriculumOutcomes.map((e) => e.toJson()).toList(),
      'hyperlinks': hyperlinks,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isFullWeekEvent': isFullWeekEvent,
    };
  }

  factory EnhancedEventBlock.fromJson(Map<String, dynamic> json) {
    return EnhancedEventBlock(
      id: json['id'] as String,
      day: json['day'] as String,
      subject: json['subject'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      body: json['body'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      color: Color(json['color'] as int),
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int? ?? 0,
      finishHour: json['finishHour'] as int,
      finishMinute: json['finishMinute'] as int? ?? 0,
      periodIndex: json['periodIndex'] as int? ?? 0,
      widthFactor: (json['widthFactor'] as num?)?.toDouble() ?? 1.0,
      attachmentIds: List<String>.from(json['attachmentIds'] as List? ?? []),
      attachments: (json['attachments'] as List? ?? [])
          .map((e) => Attachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      curriculumOutcomeIds: List<String>.from(json['curriculumOutcomeIds'] as List? ?? []),
      curriculumOutcomes: (json['curriculumOutcomes'] as List? ?? [])
          .map((e) => CurriculumOutcome.fromJson(e as Map<String, dynamic>))
          .toList(),
      hyperlinks: List<String>.from(json['hyperlinks'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isFullWeekEvent: json['isFullWeekEvent'] as bool? ?? false,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'description': description,
    };
  }

  factory Hyperlink.fromJson(Map<String, dynamic> json) {
    return Hyperlink(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      description: json['description'] as String? ?? '',
    );
  }
} 