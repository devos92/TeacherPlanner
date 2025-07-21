import 'package:flutter/material.dart';

class DayView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Planner')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // e.g. dropdown for font
            Row(
              children: [
                Text('Font:'),
                SizedBox(width: 8),
                DropdownButton<String>(
                  items: ['Sans', 'Serif', 'Mono']
                      .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                      .toList(),
                  onChanged: (_) {},
                  hint: Text('Select'),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Editable detail area
            Expanded(
              child: TextField(
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Enter detailed lesson plan...',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
