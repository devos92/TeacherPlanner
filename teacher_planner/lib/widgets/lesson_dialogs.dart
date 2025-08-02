import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/weekly_plan_data.dart';
import '../models/curriculum_models.dart';

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
    Color(0xFFA3A380), // Monday - Solid Light Purple
    Color(0xFFD7CE93), // Tuesday - Solid Light Orange
    Color(0xFFEFEBCE), // Wednesday - Solid Light Green
    Color(0xFFD8A48F), // Thursday - Solid Light Pink
    Color(0xFFBB8588), // Friday - Solid Light Teal
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
    // Get screen information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 768;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    String subject = '';
    String content = '';
    String notes = '';
    Color? selectedColor = data.lessonColor; // Initialize with existing color if any
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<WeeklyPlanData>(
      context: context,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add Lesson to ${_dayNames[data.dayIndex]} - Period ${data.periodIndex + 1}',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          content: Container(
            width: isTablet ? 500 : screenWidth * 0.9,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.8,
              maxWidth: isTablet ? 500 : screenWidth * 0.9,
            ),
            
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subject field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Subject *',
                        hintText: 'e.g., Mathematics, English, Science',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isTablet ? 16 : 12,
                        ),
                        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        errorMaxLines: 2,
                      ),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
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
                      autofocus: !isTablet, // Less aggressive autofocus on tablets
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // Content field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Lesson Content',
                        hintText: 'Describe what will be taught in this lesson...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isTablet ? 16 : 12,
                        ),
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        errorMaxLines: 2,
                      ),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      validator: (value) {
                        if (value != null && value.trim().length > 500) {
                          return 'Content must be 500 characters or less';
                        }
                        return null;
                      },
                      onChanged: (value) => content = value,
                      maxLines: isTablet ? 4 : 3,
                      maxLength: 500,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // Notes field
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Additional notes, resources, or reminders',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isTablet ? 16 : 12,
                        ),
                        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        errorMaxLines: 2,
                      ),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      validator: (value) {
                        if (value != null && value.trim().length > 200) {
                          return 'Notes must be 200 characters or less';
                        }
                        return null;
                      },
                      onChanged: (value) => notes = value,
                      maxLines: isTablet ? 3 : 2,
                      maxLength: 200,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    
                    SizedBox(height: isTablet ? 20 : 16),
                    
                    // Color selection section
                    _buildColorSelectionSection(data, selectedColor, (newColor) {
                      setDialogState(() {
                        selectedColor = newColor;
                      });
                    }, isTablet),
                  ],
                ),
              ),
            ),
          ),
          
          actions: [
            // Cancel button
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                minimumSize: Size(isTablet ? 100 : 80, isTablet ? 48 : 44),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            
            // Add button
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  HapticFeedback.mediumImpact();
                  
                  final updatedData = data.copyWith(
                    isLesson: true,
                    subject: subject.trim(),
                    content: content.trim(),
                    notes: notes.trim(),
                    lessonId: nextLessonId,
                    lessonColor: selectedColor,
                  );
                  Navigator.of(context).pop(updatedData);
                } else {
                  HapticFeedback.lightImpact();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                minimumSize: Size(isTablet ? 120 : 100, isTablet ? 48 : 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Add Lesson',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          // Enhanced dialog styling
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          actionsPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 16 : 12,
          ),
        ),
      ),
    );

    return result;
  }

  static Future<WeeklyPlanData?> showEditLessonDialog({
    required BuildContext context,
    required WeeklyPlanData data,
  }) async {
    // Get screen information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 768;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    String subject = data.subject;
    String content = data.content;
    String notes = data.notes;
    Color? selectedColor = data.lessonColor; // Initialize with current lesson color
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<WeeklyPlanData>(
      context: context,
      useSafeArea: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Edit Lesson - ${_dayNames[data.dayIndex]} Period ${data.periodIndex + 1}',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Container(
            width: isTablet ? 500 : screenWidth * 0.9,
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.8,
              maxWidth: isTablet ? 500 : screenWidth * 0.9,
            ),
            child: SingleChildScrollView(
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
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isTablet ? 16 : 12,
                        ),
                        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        errorMaxLines: 2,
                      ),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
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
                      autofocus: !isTablet,
                      maxLength: 50,
                      textCapitalization: TextCapitalization.words,
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    TextFormField(
                      initialValue: content,
                      decoration: InputDecoration(
                        labelText: 'Lesson Content',
                        hintText: 'Describe what will be taught in this lesson...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isTablet ? 16 : 12,
                        ),
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        errorMaxLines: 2,
                      ),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      validator: (value) {
                        if (value != null && value.trim().length > 500) {
                          return 'Content must be 500 characters or less';
                        }
                        return null;
                      },
                      maxLines: isTablet ? 4 : 3,
                      maxLength: 500,
                      onChanged: (value) => content = value,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    TextFormField(
                      initialValue: notes,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Additional notes, resources, or reminders',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: isTablet ? 16 : 12,
                        ),
                        labelStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        hintStyle: TextStyle(fontSize: isTablet ? 16 : 14),
                        errorMaxLines: 2,
                      ),
                      style: TextStyle(fontSize: isTablet ? 16 : 14),
                      validator: (value) {
                        if (value != null && value.trim().length > 200) {
                          return 'Notes must be 200 characters or less';
                        }
                        return null;
                      },
                      maxLines: isTablet ? 3 : 2,
                      maxLength: 200,
                      onChanged: (value) => notes = value,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    SizedBox(height: isTablet ? 20 : 16),
                    _buildColorSelectionSection(data, selectedColor, (newColor) {
                      setDialogState(() {
                        selectedColor = newColor;
                      });
                    }, isTablet),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                minimumSize: Size(isTablet ? 100 : 80, isTablet ? 48 : 44),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState?.validate() == true) {
                  HapticFeedback.mediumImpact();
                  
                  final updatedLesson = data.copyWith(
                    subject: subject.trim(),
                    content: content.trim(),
                    notes: notes.trim(),
                    lessonColor: selectedColor,
                  );
                  Navigator.pop(context, updatedLesson);
                } else {
                  HapticFeedback.lightImpact();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 24 : 16,
                  vertical: isTablet ? 12 : 8,
                ),
                minimumSize: Size(isTablet ? 120 : 100, isTablet ? 48 : 44),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Update Lesson',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          
          // Enhanced dialog styling
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          actionsPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 16 : 12,
          ),
        ),
      ),
    );

    return result;
  }

  static Widget _buildColorSelectionSection(
    WeeklyPlanData data, 
    Color? selectedColor, 
    Function(Color?) onColorSelected,
    bool isTablet,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lesson Color',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        
        // Enhanced color grid with better touch targets
        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: _lessonColors.map((color) {
            final isSelected = selectedColor == color;
            
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                onColorSelected(color);
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                width: isTablet ? 48 : 40,
                height: isTablet ? 48 : 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                  border: Border.all(
                    color: isSelected ? Colors.black87 : Colors.grey[300]!,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ] : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: isTablet ? 24 : 20,
                      )
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
} 