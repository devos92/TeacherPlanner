import 'package:flutter/material.dart';
import '../models/weekly_plan_data.dart';

class LessonDialogs {
  
  static const List<Color> _lessonColors = [
    Color(0xFFA36361), 
    Color(0xFF88895B), 
    Color(0xFF558E9B), 
    Color(0xFFA386A9), 
    Color(0xFFC96349),
    Color(0xFF84A48B), 
    Color(0xFF7BB2BA), 
    Color(0xFFE89B88), 
    Color(0xFFF79E70), 
    Color(0xFFAECBB8), 
    Color(0xFFC1D8DF), 
    Color(0xFFF9D0CD),
    Color(0xFFE7C878), 
    Color(0xFFF6D487),
    Color(0xFFC6B3CA), 
    Color(0xFFD1A996),
  
  ];

  // Day colors for visual distinction
  static const List<Color> _dayColors = [
    Color(0xA3A380), // Monday - Light Purple
    Color(0xD7CE93), // Tuesday - Light Orange
    Color(0xEFEBCE), // Wednesday - Light Green
    Color(0xD8A48F), // Thursday - Light Pink
    Color(0xBB8588), // Friday - Light Teal
  ];

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  static Future<WeeklyPlanData?> showAddLessonDialog({
    required BuildContext context,
    required WeeklyPlanData data,
    required DateTime? weekStartDate,
    required String nextLessonId,
  }) async {
    String subject = '';
    String content = '';
    String notes = '';
    Color? selectedColor = data.lessonColor; // Initialize with existing color if any
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<WeeklyPlanData>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Add Lesson to ${_dayNames[data.dayIndex]} - Period ${data.periodIndex + 1}'),
          content: Container(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Subject *',
                      hintText: 'e.g., Mathematics, English, Science',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Subject is required';
                      }
                      if (value.trim().length > 50) {
                        return 'Subject must be 50 characters or less';
                      }
                      return null;
                    },
                    onChanged: (value) => subject = value,
                    autofocus: true,
                    maxLength: 50,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Lesson Content',
                      hintText: 'Describe what will be taught in this lesson...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 500) {
                        return 'Content must be 500 characters or less';
                      }
                      return null;
                    },
                    maxLines: 4,
                    maxLength: 500,
                    onChanged: (value) => content = value,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional notes, resources, or reminders',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 200) {
                        return 'Notes must be 200 characters or less';
                      }
                      return null;
                    },
                    maxLines: 2,
                    maxLength: 200,
                    onChanged: (value) => notes = value,
                  ),
                  SizedBox(height: 16),
                  _buildColorSelectionSection(data, selectedColor, (newColor) {
                    setDialogState(() {
                      selectedColor = newColor;
                    });
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  final newLesson = data.copyWith(
                    subject: subject.trim(),
                    content: content.trim(),
                    notes: notes.trim(),
                    lessonId: nextLessonId,
                    isLesson: true,
                    date: weekStartDate?.add(Duration(days: data.dayIndex)),
                    lessonColor: selectedColor,
                  );
                  Navigator.pop(context, newLesson);
                }
              },
              child: Text('Save Lesson'),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  static Future<WeeklyPlanData?> showEditLessonDialog({
    required BuildContext context,
    required WeeklyPlanData data,
  }) async {
    String subject = data.subject;
    String content = data.content;
    String notes = data.notes;
    Color? selectedColor = data.lessonColor; // Initialize with current lesson color
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<WeeklyPlanData>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit Lesson - ${_dayNames[data.dayIndex]} Period ${data.periodIndex + 1}'),
          content: Container(
            width: 400,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: subject,
                    decoration: InputDecoration(
                      labelText: 'Subject *',
                      hintText: 'e.g., Mathematics, English, Science',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Subject is required';
                      }
                      if (value.trim().length > 50) {
                        return 'Subject must be 50 characters or less';
                      }
                      return null;
                    },
                    onChanged: (value) => subject = value,
                    autofocus: true,
                    maxLength: 50,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: content,
                    decoration: InputDecoration(
                      labelText: 'Lesson Content',
                      hintText: 'Describe what will be taught in this lesson...',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 500) {
                        return 'Content must be 500 characters or less';
                      }
                      return null;
                    },
                    maxLines: 4,
                    maxLength: 500,
                    onChanged: (value) => content = value,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    initialValue: notes,
                    decoration: InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Additional notes, resources, or reminders',
                      border: OutlineInputBorder(),
                      errorMaxLines: 2,
                    ),
                    validator: (value) {
                      if (value != null && value.trim().length > 200) {
                        return 'Notes must be 200 characters or less';
                      }
                      return null;
                    },
                    maxLines: 2,
                    maxLength: 200,
                    onChanged: (value) => notes = value,
                  ),
                  SizedBox(height: 16),
                  _buildColorSelectionSection(data, selectedColor, (newColor) {
                    setDialogState(() {
                      selectedColor = newColor;
                    });
                  }),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  final updatedLesson = data.copyWith(
                    subject: subject.trim(),
                    content: content.trim(),
                    notes: notes.trim(),
                    lessonColor: selectedColor,
                  );
                  Navigator.pop(context, updatedLesson);
                }
              },
              child: Text('Update Lesson'),
            ),
          ],
        ),
      ),
    );

    return result;
  }

  static Widget _buildColorSelectionSection(
    WeeklyPlanData data, 
    Color? selectedColor, 
    Function(Color?) onColorSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lesson Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12),
        // Default day color option
        Row(
          children: [
            GestureDetector(
              onTap: () => onColorSelected(null),
              child: Container(
                width: 40,
                height: 40,
                margin: EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: _dayColors[data.dayIndex],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedColor == null ? Colors.black : Colors.grey[300]!,
                    width: selectedColor == null ? 3 : 1,
                  ),
                ),
                child: selectedColor == null
                    ? Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            ),
            Text(
              'Default (${_dayNames[data.dayIndex]})',
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        SizedBox(height: 12),
        // Custom color options
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _lessonColors.map((color) => GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: selectedColor == color ? Colors.black : Colors.grey[300]!,
                  width: selectedColor == color ? 3 : 1,
                ),
              ),
              child: selectedColor == color
                  ? Icon(Icons.check, color: Colors.white, size: 20)
                  : null,
            ),
          )).toList(),
        ),
      ],
    );
  }
} 