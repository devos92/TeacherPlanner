// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'week_view.dart';
import 'month_view.dart';
import 'day_view.dart';
import 'enhanced_day_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // Default to week view
  final _pages = [
    MonthView(),
    WeekView(),
    DayView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_view_month),
            label: 'Month',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_day),
            label: 'Day',
          ),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to enhanced day detail page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EnhancedDayDetailPage(
                day: 'Mon',
                events: [], // Add empty events list
              ),
            ),
          );
        },
        child: Icon(Icons.edit),
        tooltip: 'Day Detail',
        heroTag: 'day_detail',
      ),
    );
  }
} 