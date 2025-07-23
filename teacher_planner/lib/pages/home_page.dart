// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/curriculum_service.dart';
import 'week_view.dart';
import 'month_view.dart';
import 'day_view.dart';
import 'enhanced_day_detail_page.dart';
import 'mrac_upload_page.dart';
import 'curriculum_browser_page.dart';

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
  void initState() {
    super.initState();
    // Initialize the curriculum service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurriculumService>().initialize();
    });
  }

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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              // Navigate to curriculum browser
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CurriculumBrowserPage(),
                ),
              );
            },
            child: Icon(Icons.school),
            tooltip: 'Curriculum Browser',
            heroTag: 'curriculum',
            mini: true,
          ),
          SizedBox(height: 8),
          FloatingActionButton(
            onPressed: () {
              // Navigate to MRAC upload page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MRACUploadPage(),
                ),
              );
            },
            child: Icon(Icons.cloud_upload),
            tooltip: 'Upload MRAC Data',
            heroTag: 'upload',
            mini: true,
          ),
          SizedBox(height: 8),
          FloatingActionButton(
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
            child: Icon(Icons.add),
            tooltip: 'Add Event',
            heroTag: 'add',
          ),
        ],
      ),
    );
  }
} 