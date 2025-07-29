// lib/widgets/day_header_widget.dart

import 'package:flutter/material.dart';

class DayHeaderWidget extends StatelessWidget {
  final String day;
  final int lessonCount;
  final bool isMobile;

  const DayHeaderWidget({
    Key? key,
    required this.day,
    required this.lessonCount,
    required this.isMobile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 20),
      margin: EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primaryColor.withOpacity(0.1),
            theme.primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: (isMobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Daily Work Pad',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.primaryColor.withOpacity(0.7),
            ),
          ),
          if (lessonCount > 0) ...[
            SizedBox(height: 8),
            Text(
              '$lessonCount lesson${lessonCount == 1 ? '' : 's'} loaded from weekly plan',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.primaryColor.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
} 