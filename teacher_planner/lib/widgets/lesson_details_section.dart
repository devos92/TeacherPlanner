// lib/widgets/lesson_details_section.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../config/app_fonts.dart';

class LessonDetailsSection extends StatelessWidget {
  final EnhancedEventBlock event;
  final Function(String) onChanged;
  final bool isTablet;

  const LessonDetailsSection({
    Key? key,
    required this.event,
    required this.onChanged,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: 12),
        _buildTextField(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Icon(Icons.description_outlined, color: event.color, size: 20),
        SizedBox(width: 8),
        Text(
          'Lesson Details',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: event.color,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField() {
    return TextFormField(
      initialValue: event.body,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: isTablet ? 16 : 14,
        height: 1.5,
        fontFamily: 'Roboto',
      ),
      maxLines: 6,
      decoration: InputDecoration(
        labelText: 'Lesson Details',
        hintText: 'Enter detailed lesson description, activities, objectives...',
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: isTablet ? 14 : 12,
          fontFamily: 'Roboto',
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: event.color.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: event.color, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
} 