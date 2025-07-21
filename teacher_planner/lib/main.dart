import 'package:flutter/material.dart';
import 'pages/month_view.dart';
import 'pages/week_view.dart';
import 'pages/day_view.dart';

void main() => runApp(TeacherPlannerApp());

class TeacherPlannerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Planner',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1;
  final _pages = [MonthView(), WeekView(), DayView()];

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
          BottomNavigationBarItem(icon: Icon(Icons.view_week), label: 'Week'),
          BottomNavigationBarItem(icon: Icon(Icons.view_day), label: 'Day'),
        ],
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
