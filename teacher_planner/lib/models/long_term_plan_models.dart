// lib/models/long_term_plan_models.dart

import 'package:flutter/material.dart';

class LongTermPlan {
  final String id;
  final String title;
  final String subject;
  final String yearLevel;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startDate;
  final DateTime? endDate;
  final String teacherId;
  final Color color;
  final List<String> curriculumOutcomeIds;
  final PlanningDocument document;

  const LongTermPlan({
    required this.id,
    required this.title,
    required this.subject,
    required this.yearLevel,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    this.startDate,
    this.endDate,
    required this.teacherId,
    required this.color,
    this.curriculumOutcomeIds = const [],
    required this.document,
  });

  LongTermPlan copyWith({
    String? id,
    String? title,
    String? subject,
    String? yearLevel,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startDate,
    DateTime? endDate,
    String? teacherId,
    Color? color,
    List<String>? curriculumOutcomeIds,
    PlanningDocument? document,
  }) {
    return LongTermPlan(
      id: id ?? this.id,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      yearLevel: yearLevel ?? this.yearLevel,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      teacherId: teacherId ?? this.teacherId,
      color: color ?? this.color,
      curriculumOutcomeIds: curriculumOutcomeIds ?? this.curriculumOutcomeIds,
      document: document ?? this.document,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'year_level': yearLevel,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'teacher_id': teacherId,
      'color': color.value,
      'curriculum_outcome_ids': curriculumOutcomeIds,
      'document': document.toJson(),
    };
  }

  factory LongTermPlan.fromJson(Map<String, dynamic> json) {
    return LongTermPlan(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      yearLevel: json['year_level'],
      description: json['description'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      startDate: json['start_date'] != null ? DateTime.parse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      teacherId: json['teacher_id'],
      color: Color(json['color']),
      curriculumOutcomeIds: List<String>.from(json['curriculum_outcome_ids'] ?? []),
      document: PlanningDocument.fromJson(json['document']),
    );
  }
}

class PlanningDocument {
  final String id;
  final String content; // Rich text content in HTML or Delta format
  final List<DocumentImage> images;
  final List<DocumentLink> hyperlinks;
  final Map<String, dynamic> formatting; // Text formatting metadata
  final DateTime lastModified;

  const PlanningDocument({
    required this.id,
    required this.content,
    this.images = const [],
    this.hyperlinks = const [],
    this.formatting = const {},
    required this.lastModified,
  });

  PlanningDocument copyWith({
    String? id,
    String? content,
    List<DocumentImage>? images,
    List<DocumentLink>? hyperlinks,
    Map<String, dynamic>? formatting,
    DateTime? lastModified,
  }) {
    return PlanningDocument(
      id: id ?? this.id,
      content: content ?? this.content,
      images: images ?? this.images,
      hyperlinks: hyperlinks ?? this.hyperlinks,
      formatting: formatting ?? this.formatting,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'images': images.map((img) => img.toJson()).toList(),
      'hyperlinks': hyperlinks.map((link) => link.toJson()).toList(),
      'formatting': formatting,
      'last_modified': lastModified.toIso8601String(),
    };
  }

  factory PlanningDocument.fromJson(Map<String, dynamic> json) {
    return PlanningDocument(
      id: json['id'],
      content: json['content'] ?? '',
      images: (json['images'] as List<dynamic>?)
          ?.map((img) => DocumentImage.fromJson(img))
          .toList() ?? [],
      hyperlinks: (json['hyperlinks'] as List<dynamic>?)
          ?.map((link) => DocumentLink.fromJson(link))
          .toList() ?? [],
      formatting: Map<String, dynamic>.from(json['formatting'] ?? {}),
      lastModified: DateTime.parse(json['last_modified']),
    );
  }
}

class DocumentImage {
  final String id;
  final String url;
  final String fileName;
  final int fileSize;
  final double? width;
  final double? height;
  final String alt;
  final int position; // Position in document

  const DocumentImage({
    required this.id,
    required this.url,
    required this.fileName,
    required this.fileSize,
    this.width,
    this.height,
    this.alt = '',
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'file_name': fileName,
      'file_size': fileSize,
      'width': width,
      'height': height,
      'alt': alt,
      'position': position,
    };
  }

  factory DocumentImage.fromJson(Map<String, dynamic> json) {
    return DocumentImage(
      id: json['id'],
      url: json['url'],
      fileName: json['file_name'],
      fileSize: json['file_size'],
      width: json['width']?.toDouble(),
      height: json['height']?.toDouble(),
      alt: json['alt'] ?? '',
      position: json['position'],
    );
  }
}

class DocumentLink {
  final String id;
  final String url;
  final String title;
  final String description;
  final int position; // Position in document

  const DocumentLink({
    required this.id,
    required this.url,
    required this.title,
    this.description = '',
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'title': title,
      'description': description,
      'position': position,
    };
  }

  factory DocumentLink.fromJson(Map<String, dynamic> json) {
    return DocumentLink(
      id: json['id'],
      url: json['url'],
      title: json['title'],
      description: json['description'] ?? '',
      position: json['position'],
    );
  }
}

enum PlanningTemplate {
  blank,
  termOverview,
  unitPlan,
  assessmentPlan,
  scopeAndSequence,
  yearOverview,
}

extension PlanningTemplateExtension on PlanningTemplate {
  String get displayName {
    switch (this) {
      case PlanningTemplate.blank:
        return 'Blank Document';
      case PlanningTemplate.termOverview:
        return 'Term Overview';
      case PlanningTemplate.unitPlan:
        return 'Unit Plan';
      case PlanningTemplate.assessmentPlan:
        return 'Assessment Plan';
      case PlanningTemplate.scopeAndSequence:
        return 'Scope and Sequence';
      case PlanningTemplate.yearOverview:
        return 'Year Overview';
    }
  }

  String get description {
    switch (this) {
      case PlanningTemplate.blank:
        return 'Start with a blank document';
      case PlanningTemplate.termOverview:
        return 'Plan an entire term with key learning areas';
      case PlanningTemplate.unitPlan:
        return 'Detailed unit planning with lessons and assessments';
      case PlanningTemplate.assessmentPlan:
        return 'Assessment schedule and rubrics';
      case PlanningTemplate.scopeAndSequence:
        return 'Curriculum scope and sequence mapping';
      case PlanningTemplate.yearOverview:
        return 'Full year curriculum overview';
    }
  }

  Color get color {
    switch (this) {
      case PlanningTemplate.blank:
        return Colors.grey;
      case PlanningTemplate.termOverview:
        return Colors.blue;
      case PlanningTemplate.unitPlan:
        return Colors.green;
      case PlanningTemplate.assessmentPlan:
        return Colors.orange;
      case PlanningTemplate.scopeAndSequence:
        return Colors.purple;
      case PlanningTemplate.yearOverview:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case PlanningTemplate.blank:
        return Icons.description;
      case PlanningTemplate.termOverview:
        return Icons.calendar_view_month;
      case PlanningTemplate.unitPlan:
        return Icons.school;
      case PlanningTemplate.assessmentPlan:
        return Icons.assignment;
      case PlanningTemplate.scopeAndSequence:
        return Icons.timeline;
      case PlanningTemplate.yearOverview:
        return Icons.calendar_today; 
    }
  }

  String get templateContent {
    switch (this) {
      case PlanningTemplate.blank:
        return '';
      case PlanningTemplate.termOverview:
        return '''
<h1>Term Overview</h1>
<h2>Learning Areas</h2>
<p>Key subjects and focus areas for this term...</p>

<h2>Term Goals</h2>
<ul>
<li>Goal 1</li>
<li>Goal 2</li>
<li>Goal 3</li>
</ul>

<h2>Assessment Schedule</h2>
<p>Key assessment dates and requirements...</p>

<h2>Resources Needed</h2>
<p>Materials, equipment, and resources required...</p>
''';
      case PlanningTemplate.unitPlan:
        return '''
<h1>Unit Plan</h1>
<h2>Unit Overview</h2>
<p>Brief description of the unit...</p>

<h2>Learning Objectives</h2>
<ul>
<li>Students will be able to...</li>
<li>Students will understand...</li>
<li>Students will demonstrate...</li>
</ul>

<h2>Lesson Sequence</h2>
<p>Week-by-week breakdown of lessons...</p>

<h2>Assessment</h2>
<p>How student learning will be assessed...</p>

<h2>Resources</h2>
<p>Required materials and resources...</p>
''';
      case PlanningTemplate.assessmentPlan:
        return '''
<h1>Assessment Plan</h1>
<h2>Assessment Overview</h2>
<p>Types of assessments and their purposes...</p>

<h2>Assessment Schedule</h2>
<table border="1">
<tr><th>Week</th><th>Assessment</th><th>Subject</th><th>Type</th></tr>
<tr><td>1</td><td></td><td></td><td></td></tr>
<tr><td>2</td><td></td><td></td><td></td></tr>
</table>

<h2>Rubrics and Criteria</h2>
<p>Assessment criteria and marking guidelines...</p>
''';
      case PlanningTemplate.scopeAndSequence:
        return '''
<h1>Scope and Sequence</h1>
<h2>Curriculum Mapping</h2>
<p>How curriculum outcomes are sequenced across the year...</p>

<h2>Term 1</h2>
<p>Key learning areas and outcomes...</p>

<h2>Term 2</h2>
<p>Key learning areas and outcomes...</p>

<h2>Term 3</h2>
<p>Key learning areas and outcomes...</p>

<h2>Term 4</h2>
<p>Key learning areas and outcomes...</p>
''';
      case PlanningTemplate.yearOverview:
        return '''
<h1>Year Overview</h1>
<h2>Year Goals</h2>
<p>Key objectives for the year...</p>

<h2>Term Breakdown</h2>
<h3>Term 1</h3>
<p>Focus areas and key learning...</p>

<h3>Term 2</h3>
<p>Focus areas and key learning...</p>

<h3>Term 3</h3>
<p>Focus areas and key learning...</p>

<h3>Term 4</h3>
<p>Focus areas and key learning...</p>

<h2>Annual Assessment Plan</h2>
<p>Major assessments and reporting periods...</p>
''';
    }
  }
} 