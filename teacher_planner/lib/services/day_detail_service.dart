// lib/services/day_detail_service.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/curriculum_models.dart';
import '../models/weekly_plan_data.dart';
import '../services/image_service.dart';
import '../services/pdf_service.dart';

class DayDetailService {
  static const List<Color> lessonColors = [
    Color(0xFFD9BDAF), Color(0xFFC68484), Color(0xFFAE7A53), 
    Color(0xFF8F8369), Color(0xFF848370), Color(0xFFA1ADA7), 
    Color(0xFFB16B47), Color(0xFFE4D8C8), Color(0xFFD5916A), 
    Color(0xFFD6A48B), Color(0xFF7F6E5D), Color(0xFFC2914C),
    Color(0xFFB07B5C), Color(0xFF9A8C6F),
    Color(0xFFD9C89C), Color(0xFFC4C0B4),
    Color(0xFFBFAC84), Color(0xFFBFAC84),
    Color(0xFFF2DBC9), Color(0xFFD49F78),
    Color(0xFFF8ECD9),
  ];

  static Color getColorForPeriod(int periodIndex) {
    return lessonColors[periodIndex % lessonColors.length];
  }

  static List<EnhancedEventBlock> loadLessonsFromWeeklyPlan(
    List<WeeklyPlanData> weeklyPlanData,
    String day,
    int dayIndex,
  ) {
    List<EnhancedEventBlock> lessons = [];

    if (weeklyPlanData.isNotEmpty) {
      final dayLessons = weeklyPlanData.where((data) => 
        data.dayIndex == dayIndex && data.isLesson
      ).toList();

      dayLessons.sort((a, b) => a.periodIndex.compareTo(b.periodIndex));

      for (final lesson in dayLessons) {
        lessons.add(EnhancedEventBlock(
          id: lesson.lessonId.isNotEmpty ? lesson.lessonId : UniqueKey().toString(),
          day: day,
          subject: lesson.subject.isNotEmpty ? lesson.subject : 'Lesson ${lesson.periodIndex + 1}',
          subtitle: 'Period ${lesson.periodIndex + 1}',
          body: lesson.content.isNotEmpty ? lesson.content : 'No description available',
          notes: lesson.notes,
          color: lesson.lessonColor ?? getColorForPeriod(lesson.periodIndex),
          startHour: 8 + lesson.periodIndex,
          startMinute: 0,
          finishHour: 9 + lesson.periodIndex,
          finishMinute: 0,
          periodIndex: lesson.periodIndex,
          widthFactor: 1.0,
          attachmentIds: [],
          curriculumOutcomeIds: [],
          hyperlinks: [],
          createdAt: lesson.date ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    return lessons;
  }

  static List<EnhancedEventBlock> convertEventsToLessons(
    List<EventBlock> events,
    String day,
  ) {
    return events.map((e) => EnhancedEventBlock(
      id: UniqueKey().toString(),
      day: e.day,
      subject: e.subject,
      subtitle: e.subtitle,
      body: e.body,
      color: e.color,
      startHour: e.startHour,
      startMinute: e.startMinute,
      finishHour: e.finishHour,
      finishMinute: e.finishMinute,
      widthFactor: e.widthFactor,
      attachmentIds: [],
      curriculumOutcomeIds: [],
      hyperlinks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();
  }

  static Future<File?> pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      return await ImageService.pickImageFromCamera();
    } else if (source == ImageSource.gallery) {
      return await ImageService.pickImageFromGallery();
    }
    return null;
  }

  static Future<File?> pickAnyFile() async {
    return await ImageService.pickAnyFile();
  }

  static Future<String?> saveImageToLocal(File file) async {
    return await ImageService.saveImageToLocal(file);
  }

  static void deleteLocalImage(String imagePath) {
    ImageService.deleteLocalImage(imagePath);
  }

  static Future<Uint8List?> generateDailyWorkPadPdf({
    required String day,
    required List<EnhancedEventBlock> lessons,
    required String teacherName,
  }) async {
    return await PdfService.generateDailyWorkPadPdf(
      day: day,
      lessons: lessons,
      teacherName: teacherName,
    );
  }

  static Future<void> printPdf(Uint8List pdfFile) async {
    await PdfService.printPdf(pdfFile);
  }

  static Future<void> sharePdf(Uint8List pdfFile) async {
    await PdfService.sharePdf(pdfFile);
  }

  static EnhancedEventBlock createNewLesson({
    required String day,
    required String subject,
    required String subtitle,
    required String content,
    required int periodIndex,
  }) {
    return EnhancedEventBlock(
      id: UniqueKey().toString(),
      day: day,
      subject: subject.trim(),
      subtitle: subtitle.trim(),
      body: content.trim(),
      color: getColorForPeriod(periodIndex),
      startHour: 8 + periodIndex,
      startMinute: 0,
      finishHour: 9 + periodIndex,
      finishMinute: 0,
      widthFactor: 1.0,
      attachmentIds: [],
      curriculumOutcomeIds: [],
      hyperlinks: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static EnhancedEventBlock updateLessonBody(
    EnhancedEventBlock event,
    String newBody,
  ) {
    return event.copyWith(
      body: newBody,
      updatedAt: DateTime.now(),
    );
  }

  static EnhancedEventBlock updateLessonNotes(
    EnhancedEventBlock event,
    String newNotes,
  ) {
    return event.copyWith(
      notes: newNotes,
      updatedAt: DateTime.now(),
    );
  }

  static EnhancedEventBlock addPictureToLesson(
    EnhancedEventBlock event,
    String imagePath,
  ) {
    return event.copyWith(
      attachmentIds: [...event.attachmentIds, imagePath],
    );
  }

  static EnhancedEventBlock removePictureFromLesson(
    EnhancedEventBlock event,
    String imagePath,
  ) {
    return event.copyWith(
      attachmentIds: event.attachmentIds.where((path) => path != imagePath).toList(),
    );
  }

  static EnhancedEventBlock addHyperlinkToLesson(
    EnhancedEventBlock event,
    String linkTitle,
    String linkUrl,
  ) {
    return event.copyWith(
      hyperlinks: [...event.hyperlinks, '$linkTitle|$linkUrl'],
    );
  }

  static EnhancedEventBlock removeHyperlinkFromLesson(
    EnhancedEventBlock event,
    String linkData,
  ) {
    return event.copyWith(
      hyperlinks: event.hyperlinks.where((link) => link != linkData).toList(),
    );
  }

  static WeeklyPlanData? findWeeklyPlanData(
    List<WeeklyPlanData> weeklyPlanData,
    String lessonId,
    int dayIndex,
  ) {
    final index = weeklyPlanData.indexWhere((data) => 
      data.lessonId == lessonId && data.dayIndex == dayIndex
    );
    return index != -1 ? weeklyPlanData[index] : null;
  }

  static List<WeeklyPlanData> updateWeeklyPlanData(
    List<WeeklyPlanData> weeklyPlanData,
    String lessonId,
    int dayIndex,
    String content,
    String notes,
  ) {
    final index = weeklyPlanData.indexWhere((data) => 
      data.lessonId == lessonId && data.dayIndex == dayIndex
    );
    
    if (index != -1) {
      final updatedData = weeklyPlanData[index].copyWith(
        content: content,
        notes: notes,
      );
      weeklyPlanData[index] = updatedData;
    }
    
    return weeklyPlanData;
  }
} 