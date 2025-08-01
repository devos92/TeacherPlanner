// lib/widgets/teacher_notes_section.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../config/app_fonts.dart';

class TeacherNotesSection extends StatelessWidget {
  final EnhancedEventBlock event;
  final Function(String) onChanged;
  final bool isTablet;

  const TeacherNotesSection({
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
        Icon(Icons.note_outlined, color: event.color, size: 20),
        SizedBox(width: 8),
        Text(
          'Teacher Notes',
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
      initialValue: event.notes,
      onChanged: onChanged,
                      style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  height: 1.5,
                  fontFamily: 'Roboto',
                ),
      maxLines: 4,
      decoration: InputDecoration(
        labelText: 'Teacher Notes',
        hintText: 'Add your notes, reminders, or additional details...',
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