import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/weekly_plan_data.dart';
import '../models/curriculum_models.dart';


class LessonDetailPage extends StatelessWidget {
  final EnhancedEventBlock event;

  const LessonDetailPage({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(event.subject),
        backgroundColor: event.color,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event header
            Card(
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.subject,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (event.subtitle.isNotEmpty) ...[
                      SizedBox(height: 8),
                      Text(
                        event.subtitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.schedule, color: event.color),
                        SizedBox(width: 8),
                        Text(
                          '${event.startHour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')} - ${event.finishHour.toString().padLeft(2, '0')}:${event.finishMinute.toString().padLeft(2, '0')}',
                          style: TextStyle(fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${event.durationHours.toStringAsFixed(1)} hour${event.durationHours > 1 ? 's' : ''}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Lesson content
            Text(
              'Lesson Plan',
              style: theme.textTheme.titleLarge,
            ),
            SizedBox(height: 12),
            
            if (event.body.isNotEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: SelectableText(
                  event.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No lesson plan details available.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
