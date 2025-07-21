import 'package:flutter/material.dart';
import 'week_view.dart';

class LessonDetailPage extends StatelessWidget {
  final EventBlock event;
  LessonDetailPage({required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(event.subject)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Day: ${event.day}'),
            Text('Start: ${event.startHour}:00'),
            Text('Duration: ${event.duration} hour(s)'),
            SizedBox(height: 16),
            Text(
              'Lesson Plan Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: TextField(
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter detailed lesson plan here...',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
