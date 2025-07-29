import 'dart:convert';

// Database Models that match the actual database schema

class DatabaseUser {
  final String id;
  final String email;
  final String passwordHash;
  final String salt;
  final String? firstName;
  final String? lastName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  DatabaseUser({
    required this.id,
    required this.email,
    required this.passwordHash,
    required this.salt,
    this.firstName,
    this.lastName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DatabaseUser.fromJson(Map<String, dynamic> json) {
    return DatabaseUser(
      id: json['id'],
      email: json['email'],
      passwordHash: json['password_hash'],
      salt: json['salt'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password_hash': passwordHash,
      'salt': salt,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WeeklyPlan {
  final String id;
  final String userId;
  final String title;
  final String? subtitle;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyPlan({
    required this.id,
    required this.userId,
    required this.title,
    this.subtitle,
    this.description,
    required this.startDate,
    required this.endDate,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyPlan.fromJson(Map<String, dynamic> json) {
    return WeeklyPlan(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DailyDetail {
  final String id;
  final String weeklyPlanId;
  final DateTime date;
  final String title;
  final String? subtitle;
  final String? description;
  final String? notes;
  final String? headerText;
  final String? color;
  final int? startHour;
  final int? startMinute;
  final int? finishHour;
  final int? finishMinute;
  final int? periodIndex;
  final double? widthFactor;
  final bool isFullWeekEvent;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyDetail({
    required this.id,
    required this.weeklyPlanId,
    required this.date,
    required this.title,
    this.subtitle,
    this.description,
    this.notes,
    this.headerText,
    this.color,
    this.startHour,
    this.startMinute,
    this.finishHour,
    this.finishMinute,
    this.periodIndex,
    this.widthFactor,
    required this.isFullWeekEvent,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyDetail.fromJson(Map<String, dynamic> json) {
    return DailyDetail(
      id: json['id'],
      weeklyPlanId: json['weekly_plan_id'],
      date: DateTime.parse(json['date']),
      title: json['title'],
      subtitle: json['subtitle'],
      description: json['description'],
      notes: json['notes'],
      headerText: json['header_text'],
      color: json['color'],
      startHour: json['start_hour'],
      startMinute: json['start_minute'],
      finishHour: json['finish_hour'],
      finishMinute: json['finish_minute'],
      periodIndex: json['period_index'],
      widthFactor: json['width_factor']?.toDouble(),
      isFullWeekEvent: json['is_full_week_event'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class WeeklyPlanCell {
  final String id;
  final String weeklyPlanId;
  final int dayIndex;
  final int periodIndex;
  final String? content;
  final String? subject;
  final String? notes;
  final String? lessonId;
  final DateTime? date;
  final bool isLesson;
  final bool isFullWeekEvent;
  final List<Map<String, dynamic>> subLessons;
  final int? lessonColor;
  final DateTime createdAt;

  WeeklyPlanCell({
    required this.id,
    required this.weeklyPlanId,
    required this.dayIndex,
    required this.periodIndex,
    this.content,
    this.subject,
    this.notes,
    this.lessonId,
    this.date,
    required this.isLesson,
    required this.isFullWeekEvent,
    required this.subLessons,
    this.lessonColor,
    required this.createdAt,
  });

  factory WeeklyPlanCell.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanCell(
      id: json['id'],
      weeklyPlanId: json['weekly_plan_id'],
      dayIndex: json['day_index'],
      periodIndex: json['period_index'],
      content: json['content'],
      subject: json['subject'],
      notes: json['notes'],
      lessonId: json['lesson_id'],
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      isLesson: json['is_lesson'],
      isFullWeekEvent: json['is_full_week_event'],
      subLessons: List<Map<String, dynamic>>.from(
        jsonDecode(json['sub_lessons'] ?? '[]'),
      ),
      lessonColor: json['lesson_color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Attachment {
  final String id;
  final String parentId; // weekly_plan_id, daily_detail_id, etc.
  final String filePath;
  final String? name;
  final String? mimeType;
  final int? size;
  final DateTime createdAt;

  Attachment({
    required this.id,
    required this.parentId,
    required this.filePath,
    this.name,
    this.mimeType,
    this.size,
    required this.createdAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      parentId: json['weekly_plan_id'] ?? 
                json['daily_detail_id'] ?? 
                json['long_term_plan_id'] ?? 
                json['daily_reflection_id'] ?? '',
      filePath: json['file_path'],
      name: json['name'],
      mimeType: json['mime_type'],
      size: json['size'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_path': filePath,
      'name': name,
      'mime_type': mimeType,
      'size': size,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Hyperlink {
  final String id;
  final String parentId; // weekly_plan_id, daily_detail_id, etc.
  final String? title;
  final String url;
  final DateTime createdAt;

  Hyperlink({
    required this.id,
    required this.parentId,
    this.title,
    required this.url,
    required this.createdAt,
  });

  factory Hyperlink.fromJson(Map<String, dynamic> json) {
    return Hyperlink(
      id: json['id'],
      parentId: json['weekly_plan_id'] ?? 
                json['daily_detail_id'] ?? 
                json['long_term_plan_id'] ?? '',
      title: json['title'],
      url: json['url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Curriculum {
  final String code;
  final int learningAreaId;
  final int subjectId;
  final int levelId;
  final int? strandId;
  final int? subStrandId;
  final String? contentDescription;
  final String? elaboration;

  Curriculum({
    required this.code,
    required this.learningAreaId,
    required this.subjectId,
    required this.levelId,
    this.strandId,
    this.subStrandId,
    this.contentDescription,
    this.elaboration,
  });

  factory Curriculum.fromJson(Map<String, dynamic> json) {
    return Curriculum(
      code: json['code'],
      learningAreaId: json['learning_area_id'],
      subjectId: json['subject_id'],
      levelId: json['level_id'],
      strandId: json['strand_id'],
      subStrandId: json['sub_strand_id'],
      contentDescription: json['content_description'],
      elaboration: json['elaboration'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'learning_area_id': learningAreaId,
      'subject_id': subjectId,
      'level_id': levelId,
      'strand_id': strandId,
      'sub_strand_id': subStrandId,
      'content_description': contentDescription,
      'elaboration': elaboration,
    };
  }
}

class Subject {
  final int id;
  final String? name;

  Subject({
    required this.id,
    this.name,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class LearningArea {
  final int id;
  final String? name;

  LearningArea({
    required this.id,
    this.name,
  });

  factory LearningArea.fromJson(Map<String, dynamic> json) {
    return LearningArea(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Level {
  final int id;
  final String? name;

  Level({
    required this.id,
    this.name,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Strand {
  final int id;
  final String? name;

  Strand({
    required this.id,
    this.name,
  });

  factory Strand.fromJson(Map<String, dynamic> json) {
    return Strand(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class SubStrand {
  final int id;
  final String? name;

  SubStrand({
    required this.id,
    this.name,
  });

  factory SubStrand.fromJson(Map<String, dynamic> json) {
    return SubStrand(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class LongTermPlan {
  final String id;
  final String userId;
  final int subjectId;
  final int year;
  final int? color;
  final String? details;
  final DateTime createdAt;
  final DateTime updatedAt;

  LongTermPlan({
    required this.id,
    required this.userId,
    required this.subjectId,
    required this.year,
    this.color,
    this.details,
    required this.createdAt,
    required this.updatedAt,
  });

  factory LongTermPlan.fromJson(Map<String, dynamic> json) {
    return LongTermPlan(
      id: json['id'],
      userId: json['user_id'],
      subjectId: json['subject_id'],
      year: json['year'],
      color: json['color'],
      details: json['details'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'subject_id': subjectId,
      'year': year,
      'color': color,
      'details': details,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TermPlanner {
  final String id;
  final String userId;
  final String name;
  final DateTime startDate;
  final int weekCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  TermPlanner({
    required this.id,
    required this.userId,
    required this.name,
    required this.startDate,
    required this.weekCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TermPlanner.fromJson(Map<String, dynamic> json) {
    return TermPlanner(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      startDate: DateTime.parse(json['start_date']),
      weekCount: json['week_count'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'start_date': startDate.toIso8601String(),
      'week_count': weekCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class TermEvent {
  final String id;
  final String termPlannerId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime? endDate;
  final String type;
  final int? color;
  final DateTime createdAt;

  TermEvent({
    required this.id,
    required this.termPlannerId,
    required this.title,
    this.description,
    required this.startDate,
    this.endDate,
    required this.type,
    this.color,
    required this.createdAt,
  });

  factory TermEvent.fromJson(Map<String, dynamic> json) {
    return TermEvent(
      id: json['id'],
      termPlannerId: json['term_planner_id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null ? DateTime.parse(json['end_date']) : null,
      type: json['type'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'term_planner_id': termPlannerId,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'type': type,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class WeeklyPlanEvent {
  final String id;
  final String weeklyPlanId;
  final String title;
  final String? description;
  final DateTime eventDate;
  final String? color;
  final DateTime createdAt;
  final DateTime updatedAt;

  WeeklyPlanEvent({
    required this.id,
    required this.weeklyPlanId,
    required this.title,
    this.description,
    required this.eventDate,
    this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WeeklyPlanEvent.fromJson(Map<String, dynamic> json) {
    return WeeklyPlanEvent(
      id: json['id'],
      weeklyPlanId: json['weekly_plan_id'],
      title: json['title'],
      description: json['description'],
      eventDate: DateTime.parse(json['event_date']),
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekly_plan_id': weeklyPlanId,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'color': color,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class DailyReflection {
  final String id;
  final String dailyDetailId;
  final String? day;
  final String reflectionText;
  final DateTime createdAt;
  final DateTime updatedAt;

  DailyReflection({
    required this.id,
    required this.dailyDetailId,
    this.day,
    required this.reflectionText,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DailyReflection.fromJson(Map<String, dynamic> json) {
    return DailyReflection(
      id: json['id'],
      dailyDetailId: json['daily_detail_id'],
      day: json['day'],
      reflectionText: json['reflection_text'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'daily_detail_id': dailyDetailId,
      'day': day,
      'reflection_text': reflectionText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class EmailVerification {
  final String id;
  final String userId;
  final String token;
  final DateTime expiresAt;
  final DateTime createdAt;

  EmailVerification({
    required this.id,
    required this.userId,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
  });

  factory EmailVerification.fromJson(Map<String, dynamic> json) {
    return EmailVerification(
      id: json['id'],
      userId: json['user_id'],
      token: json['token'],
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class PasswordResetToken {
  final String id;
  final String userId;
  final String token;
  final DateTime expiresAt;
  final DateTime createdAt;

  PasswordResetToken({
    required this.id,
    required this.userId,
    required this.token,
    required this.expiresAt,
    required this.createdAt,
  });

  factory PasswordResetToken.fromJson(Map<String, dynamic> json) {
    return PasswordResetToken(
      id: json['id'],
      userId: json['user_id'],
      token: json['token'],
      expiresAt: DateTime.parse(json['expires_at']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'token': token,
      'expires_at': expiresAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class UserSettings {
  final String userId;
  final Map<String, dynamic> settings;

  UserSettings({
    required this.userId,
    required this.settings,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'],
      settings: json['settings'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'settings': settings,
    };
  }
} 