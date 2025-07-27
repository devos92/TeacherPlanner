/// lib/pages/week_view.dart

import 'package:flutter/material.dart';

import '../widgets/period_selection_dialog.dart';
import '../widgets/weekly_plan_widget.dart';
import '../models/event_block.dart'; // Add import for EventBlock
import '../models/weekly_plan_data.dart'; // Updated import path
import 'enhanced_day_detail_page.dart'; // Add import for day detail page

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  // Weekly plan state
  int? _periods;
  bool _isLoadingPeriods = false;
  bool _isVerticalLayout = true; // Default to vertical layout
  DateTime _weekStartDate = DateTime.now(); // Add week start date
  final GlobalKey<WeeklyPlanWidgetState> _weeklyPlanKey = GlobalKey<WeeklyPlanWidgetState>(); // Add key to access widget methods

  @override
  void initState() {
    super.initState();
    _checkPeriodsSetup();
    _calculateWeekStart(); // Calculate the start of the current week
  }

  void _calculateWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekStartDate = DateTime(monday.year, monday.month, monday.day);
  }

  Future<void> _checkPeriodsSetup() async {
    // TODO: Load from storage/preferences
    // For now, we'll always show the dialog on first launch
    setState(() => _isLoadingPeriods = true);
    
    await Future.delayed(Duration(milliseconds: 500));
    
    if (mounted) {
      final result = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PeriodSelectionDialog(),
      );
      
      if (mounted) {
        setState(() {
          _periods = result ?? 5; // Default to 5 periods
          _isLoadingPeriods = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Plan'),
            if (_weekStartDate != null) ...[
              SizedBox(height: 2),
              Text(
                _getWeekRangeString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ],
        ),
        actions: [
          // Week navigation
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => _navigateWeek(-1),
            tooltip: 'Previous Week',
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => _navigateWeek(1),
            tooltip: 'Next Week',
          ),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: () => _goToToday(),
            tooltip: 'Go to Today',
          ),
          // Add full week event button
          IconButton(
            icon: Icon(Icons.event_note),
            onPressed: () => _showAddFullWeekEventDialog(),
            tooltip: 'Add Full Week Event (Lunch, Recess, etc.)',
          ),
          // Layout toggle
          IconButton(
            icon: Icon(_isVerticalLayout ? Icons.view_agenda : Icons.view_column),
            onPressed: () => setState(() {
              _isVerticalLayout = !_isVerticalLayout;
            }),
            tooltip: _isVerticalLayout ? 'Switch to Horizontal Layout' : 'Switch to Vertical Layout',
          ),
          // Settings for weekly plan
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => _showWeeklyPlanSettings(),
            tooltip: 'Weekly Plan Settings',
          ),
        ],
      ),
      body: _buildWeeklyPlanView(),
    );
  }

  Widget _buildWeeklyPlanView() {
    if (_isLoadingPeriods) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Setting up your weekly plan...'),
          ],
        ),
      );
    }

    if (_periods == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Failed to load weekly plan setup'),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkPeriodsSetup,
              child: Text('Retry'),
            ),
          ],
        ),
      );
    }

    return WeeklyPlanWidget(
      periods: _periods!,
      isVerticalLayout: _isVerticalLayout,
      onDayTap: _navigateToDayDetail, // Add navigation callback
      weekStartDate: _weekStartDate, // Pass the week start date
      onAddFullWeekEvent: _addFullWeekEvent, // Add full week event callback
      key: _weeklyPlanKey, // Assign the key
    );
  }

  void _showWeeklyPlanSettings() async {
    final result = await showDialog<int>(
      context: context,
      builder: (context) => PeriodSelectionDialog(
        currentPeriods: _periods,
      ),
    );
    
    if (result != null && result != _periods) {
      setState(() {
        _periods = result;
      });
    }
  }

  void _navigateToDayDetail(int dayIndex) {
    // Convert day index (0-4) to day name
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final dayName = dayNames[dayIndex];
    
    // Get the weekly plan data from the widget
    List<WeeklyPlanData>? weeklyPlanData;
    if (_weeklyPlanKey.currentState != null) {
      // Access the plan data from the WeeklyPlanWidget state using the getter
      weeklyPlanData = _weeklyPlanKey.currentState!.planData;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedDayDetailPage(
          day: dayName,
          events: <EventBlock>[], // Properly typed empty events list
          weeklyPlanData: weeklyPlanData, // Pass the weekly plan data
          dayIndex: dayIndex, // Pass the day index
        ),
      ),
    );
  }

  void _showAddFullWeekEventDialog() {
    // Call the WeeklyPlanWidget's method to add full week events
    if (_weeklyPlanKey.currentState != null) {
      _weeklyPlanKey.currentState!.addFullWeekEvent();
    }
  }

  void _addFullWeekEvent() {
    // This method will be called from the WeeklyPlanWidget
    // It will show the full week event dialog
    _showAddFullWeekEventDialog();
  }

  String _getWeekRangeString() {
    final startDate = _weekStartDate;
    final endDate = _weekStartDate.add(Duration(days: 4)); // Friday (5 days)
    
    final startDay = startDate.day.toString().padLeft(2, '0');
    final startMonth = startDate.month.toString().padLeft(2, '0');
    final endDay = endDate.day.toString().padLeft(2, '0');
    final endMonth = endDate.month.toString().padLeft(2, '0');
    
    return '$startDay/$startMonth - $endDay/$endMonth';
  }

  void _navigateWeek(int weeks) {
    setState(() {
      _weekStartDate = _weekStartDate.add(Duration(days: weeks * 7));
    });
  }

  void _goToToday() {
    setState(() {
      _calculateWeekStart(); // Recalculate the start of the current week
    });
  }
}
