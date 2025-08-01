// lib/widgets/lesson_header_widget.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../config/app_fonts.dart';

class LessonHeaderWidget extends StatelessWidget {
  final EnhancedEventBlock event;
  final bool isTablet;

  const LessonHeaderWidget({
    Key? key,
    required this.event,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 16 : 12),
          topRight: Radius.circular(isTablet ? 16 : 12),
        ),
      ),
      child: Row(
        children: [
          _buildPeriodBadge(),
          SizedBox(width: 12),
          _buildSubjectText(),
        ],
      ),
    );
  }

  Widget _buildPeriodBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 12 : 10,
        vertical: isTablet ? 8 : 6,
      ),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
        border: Border.all(color: event.color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        'Period ${event.periodIndex + 1}',
        style: TextStyle(
          color: event.color,
          fontSize: isTablet ? 14 : 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Roboto',
        ),
      ),
    );
  }

  Widget _buildSubjectText() {
    return Expanded(
      child: Text(
        event.headerText?.isNotEmpty == true ? event.headerText! : event.subject,
        style: TextStyle(
          fontSize: isTablet ? 22 : 18,
          color: Colors.grey[900],
          fontFamily: 'Roboto',
        ),
      ),
    );
  }
} 