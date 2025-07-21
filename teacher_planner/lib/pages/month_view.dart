import 'package:flutter/material.dart';

class MonthView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // You could use table_calendar package here, but stub for now:
    return Scaffold(
      appBar: AppBar(title: Text('Monthly Planner')),
      body: Center(child: Text('Month grid goes here')),
    );
  }
}
