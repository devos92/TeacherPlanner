/// lib/pages/week_view.dart

import 'package:flutter/material.dart';

import '../widgets/period_selection_dialog.dart';
import '../widgets/weekly_plan_widget.dart';
import '../models/event_block.dart'; // Add import for EventBlock
import '../models/weekly_plan_data.dart'; // Updated import path
import '../services/auto_save_service.dart'; // Add auto-save service
import '../services/auth_service.dart'; // Add auth service
import '../widgets/save_indicator.dart'; // Add save indicator
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
  final GlobalKey<WeeklyPlanWidgetState> _weeklyPlanKey = GlobalKey<WeeklyPlanWidgetState>(); 

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
          // Save button
          FutureBuilder<String>(
            future: _getCurrentUserId(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              
              final userId = snapshot.data ?? '';
              
              // If no user ID, show login prompt instead of save button
              if (userId.isEmpty) {
                return IconButton(
                  icon: Icon(Icons.login),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please login to save your weekly plan'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  },
                  tooltip: 'Login to Save',
                );
              }
              
              return SaveIndicator(
                saveKey: 'weekly_plan_${_weekStartDate.millisecondsSinceEpoch}',
                data: _getWeeklyPlanData(),
                userId: userId,
                tableName: 'weekly_plans',
                onSaveSuccess: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('✅ Weekly plan saved!')),
                  );
                },
                onSaveError: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('❌ Failed to save weekly plan'),
                      backgroundColor: Colors.red,
                    ),
                  );
                },
              );
            },
          ),
          SizedBox(width: 8),
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
      key: _weeklyPlanKey, // Use the key to access data
      periods: _periods!,
      isVerticalLayout: _isVerticalLayout,
      onDayTap: _navigateToDayDetail, // Add navigation callback
      weekStartDate: _weekStartDate, // Pass the week start date
      onAddFullWeekEvent: _addFullWeekEvent, // Add full week event callback
      onPlanChanged: (planData) {
        // Handle plan changes here
        setState(() {
          // Update any local state if needed
        });
      },
      onPreviousWeek: () => _navigateWeek(-1), // Previous week callback
      onNextWeek: () => _navigateWeek(1), // Next week callback
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
    
    // Get the actual weekly plan data from the WeeklyPlanWidget
    List<WeeklyPlanData> weeklyPlanData = [];
    
    // Access the real data from the weekly plan widget
    if (_weeklyPlanKey.currentState != null) {
      final allPlanData = _weeklyPlanKey.currentState!.planData;
      
      // Filter data for the specific day
      weeklyPlanData = allPlanData.where((data) => 
        data.dayIndex == dayIndex && (data.isLesson || data.isFullWeekEvent)
      ).toList();
      
      debugPrint('Found ${weeklyPlanData.length} lessons/events for ${dayName}');
    } else {
      debugPrint('WeeklyPlanWidget state not available yet');
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedDayDetailPage(
          day: dayName,
          events: <EventBlock>[], // Keep empty for now
          weeklyPlanData: weeklyPlanData, // Pass the real weekly plan data
          dayIndex: dayIndex, // Pass the day index
          onPlanDataChanged: (updatedPlanData) {
            // Handle when lesson details are updated in the day detail page
            // Update the weekly plan widget with the changed data
            if (_weeklyPlanKey.currentState != null) {
              // Merge the updated data back into the full plan
              final currentPlanData = List<WeeklyPlanData>.from(_weeklyPlanKey.currentState!.planData);
              
              // Remove old data for this day
              currentPlanData.removeWhere((data) => data.dayIndex == dayIndex);
              
              // Add the updated data
              currentPlanData.addAll(updatedPlanData);
              
              // Notify the weekly plan widget of changes
              setState(() {
                debugPrint('Plan data updated for ${dayName}: ${updatedPlanData.length} lessons');
              });
            }
          },
        ),
      ),
    );
  }

  void _showAddFullWeekEventDialog() {
    // Use the GlobalKey to access the WeeklyPlanWidget state
    if (_weeklyPlanKey.currentState != null) {
      _weeklyPlanKey.currentState!.addFullWeekEvent();
    } else {
      // Fallback: show a simple dialog if the state is not available yet
      _showSimpleFullWeekEventDialog();
    }
  }

  void _showSimpleFullWeekEventDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Full Week Event'),
        content: Text('Full week event functionality will be available when the weekly plan is loaded.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
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
    // Auto-save when week changes
    _autoSaveWeeklyPlan();
  }

  void _goToToday() {
    setState(() {
      _calculateWeekStart(); // Recalculate the start of the current week
    });
    // Auto-save when going to today
    _autoSaveWeeklyPlan();
  }

  /// Get current user ID for save operations
  Future<String> _getCurrentUserId() async {
    try {
      // Ensure user is authenticated
      final isAuthenticated = await AuthService.instance.ensureAuthenticated();
      if (!isAuthenticated) {
        debugPrint('❌ User not authenticated');
        return '';
      }

      final currentUser = await AuthService.instance.getCurrentUser();
      if (currentUser != null) {
        debugPrint('✅ User authenticated: ${currentUser.email}');
        return currentUser.id;
      }
      
      debugPrint('❌ No current user found');
      return '';
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return '';
    }
  }

  /// Get weekly plan data for saving
  Map<String, dynamic> _getWeeklyPlanData() {
    return {
      'week_start_date': _weekStartDate.toIso8601String(),
      'periods': _periods,
      'is_vertical_layout': _isVerticalLayout,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Auto-save weekly plan data
  Future<void> _autoSaveWeeklyPlan() async {
    try {
      await AutoSaveService.instance.saveWeeklyPlan(
        planData: _getWeeklyPlanData(),
        userId: await _getCurrentUserId(),
      );
    } catch (e) {
      debugPrint('Auto-save error: $e');
    }
  }
}
