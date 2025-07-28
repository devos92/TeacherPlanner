import 'package:flutter/material.dart';
import '../models/weekly_plan_data.dart';

class LessonCellWidgets {
  // Day colors for visual distinction
  static const List<Color> _dayColors = [
    Color(0xFFA3A380), // Monday - Solid Light Purple
    Color(0xFFD7CE93), // Tuesday - Solid Light Orange
    Color(0xFFEFEBCE), // Wednesday - Solid Light Green
    Color(0xFFD8A48F), // Thursday - Solid Light Pink
    Color(0xFFBB8588), // Friday - Solid Light Teal
  ];

  // Helper method to get the effective color for a lesson
  static Color getLessonColor(WeeklyPlanData data) {
    if (data.isLesson && data.lessonColor != null) {
      return data.lessonColor!;
    }
    return _dayColors[data.dayIndex];
  }

  static Widget buildEmptyCell({
    required WeeklyPlanData data,
    required ThemeData theme,
    required int dayIndex,
    required VoidCallback onTap,
    required List<WeeklyPlanData> planData,
  }) {
    // Check if there's already a lesson in this cell
    final existingLesson = planData.where((d) => 
      d.dayIndex == data.dayIndex && 
      d.periodIndex == data.periodIndex && 
      d.isLesson
    ).toList();

    final hasExistingLesson = existingLesson.isNotEmpty;
    final buttonText = hasExistingLesson ? 'Add Another Lesson' : 'Add Lesson';
    final icon = hasExistingLesson ? Icons.add : Icons.add_circle_outline;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: _dayColors[dayIndex].withValues(alpha: 0.2),
        highlightColor: _dayColors[dayIndex].withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: _dayColors[dayIndex].withValues(alpha: 0.4),
                ),
                SizedBox(height: 4),
                Text(
                  buttonText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: _dayColors[dayIndex].withValues(alpha: 0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildDraggableLesson({
    required WeeklyPlanData data,
    required ThemeData theme,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final isFullWeekEvent = data.isFullWeekEvent;
    final lessonColor = getLessonColor(data);
    
    return Draggable<WeeklyPlanData>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: lessonColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  data.subject.isNotEmpty ? data.subject : 'Lesson',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                if (data.isFullWeekEvent) ...[
                  SizedBox(height: 4),
                  Text(
                    'Full Week Event',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Center(
          child: Icon(
            Icons.drag_handle,
            color: Colors.grey.shade400,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          splashColor: lessonColor.withValues(alpha: 0.2),
          highlightColor: lessonColor.withValues(alpha: 0.1),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject header - bold and prominent
                if (data.subject.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: lessonColor.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data.subject,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.drag_handle,
                        size: 14,
                        color: lessonColor.withValues(alpha: 0.7),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: onDelete,
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: Colors.red.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                // Content - takes up all remaining space
                if (data.content.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _dayColors[data.dayIndex].withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _dayColors[data.dayIndex].withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        data.content,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: null,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
                // Notes - minimal space at bottom
                if (data.notes.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dayColors[data.dayIndex].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data.notes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                        color: _dayColors[data.dayIndex].withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget buildMultipleLessonsCell({
    required WeeklyPlanData data,
    required ThemeData theme,
    required Function(int dayIndex, int periodIndex, int lessonIndex) onDeleteLesson,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _dayColors[data.dayIndex].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _dayColors[data.dayIndex].withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text(
            'Multiple Lessons (${data.subLessons.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: _dayColors[data.dayIndex].withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: data.subLessons.length,
              itemBuilder: (context, index) {
                final lesson = data.subLessons[index];
                return buildLessonInMultipleCell(
                  lesson: lesson,
                  theme: theme,
                  dayIndex: data.dayIndex,
                  periodIndex: data.periodIndex,
                  lessonIndex: index,
                  onDelete: () => onDeleteLesson(data.dayIndex, data.periodIndex, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static Widget buildLessonInMultipleCell({
    required WeeklyPlanData lesson,
    required ThemeData theme,
    required int dayIndex,
    required int periodIndex,
    required int lessonIndex,
    required VoidCallback onDelete,
  }) {
    final lessonColor = getLessonColor(lesson);
    
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lessonColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: lessonColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.subject.isNotEmpty ? lesson.subject : 'Lesson ${lessonIndex + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: lessonColor.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lesson.content.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    lesson.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }
} 