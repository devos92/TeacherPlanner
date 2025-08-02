// lib/pages/week_view.dart

import 'package:flutter/material.dart';
import '../models/weekly_plan_data.dart';
import '../widgets/period_selection_dialog.dart';
import '../widgets/weekly_plan_widget.dart';

import '../services/lesson_database_service.dart';
import '../services/auto_save_service.dart';
import '../services/auth_service.dart';
import '../services/planner_service.dart';
import '../widgets/save_indicator.dart';
import 'enhanced_day_detail_page.dart';

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  int? _periods;
  bool _isLoadingPeriods = false;
  bool _isVerticalLayout = true;
  DateTime _weekStartDate = DateTime.now();
  final GlobalKey<WeeklyPlanWidgetState> _weeklyPlanKey = GlobalKey<WeeklyPlanWidgetState>();

  @override
  void initState() {
    super.initState();
    _loadPlannerSettings();
    _calculateWeekStart();
  }

  Future<void> _loadPlannerSettings() async {
    try {
      final currentUser = await AuthService.instance.getCurrentUser();
      if (currentUser == null) {
        _checkPeriodsSetup();
        return;
      }

      final settings = await PlannerService.instance.loadPlannerSettings(currentUser.id);
      if (settings != null && settings['periods'] != null) {
        setState(() {
          _periods = settings['periods'] as int;
          _isLoadingPeriods = false;
        });
                 debugPrint('✅ Loaded planner settings: ${settings['periods']} periods');
      } else {
        _checkPeriodsSetup();
      }
    } catch (e) {
             debugPrint('Error loading planner settings: $e');
    _checkPeriodsSetup();
    }
  }

  Future<void> _saveLessonsToDatabase() async {
    if (_weeklyPlanKey.currentState == null) {
      debugPrint('❌ Weekly plan widget not available');
      return;
    }

    final userId = await _getCurrentUserId();
    if (userId.isEmpty) {
      debugPrint('❌ User not authenticated');
      return;
    }

    final planData = _weeklyPlanKey.currentState!.planData;

    final success = await LessonDatabaseService.saveCompleteWeeklyPlan(
      planData,
      _weekStartDate,
      _periods ?? 5,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Weekly plan saved!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Failed to save weekly plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _calculateWeekStart() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    _weekStartDate = DateTime(monday.year, monday.month, monday.day);
  }

  Future<void> _checkPeriodsSetup() async {
    setState(() => _isLoadingPeriods = true);
    await Future.delayed(Duration(milliseconds: 500));
    if (mounted) {
      final result = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (context) => PeriodSelectionDialog(),
      );
      if (mounted) {
        final selectedPeriods = result ?? 5;
        setState(() {
          _periods = selectedPeriods;
          _isLoadingPeriods = false;
        });
        try {
          final currentUser = await AuthService.instance.getCurrentUser();
          if (currentUser != null) {
            await PlannerService.instance.updatePlannerSettings(
              currentUser.id,
              {
                'periods': selectedPeriods,
                'last_updated': DateTime.now().toIso8601String(),
              },
            );
                         debugPrint('✅ Saved period settings: $selectedPeriods periods');
          }
        } catch (e) {
          debugPrint('Error saving period settings: $e');
        }
      }
    }
  }

  Future<String> _getCurrentUserId() async {
    try {
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

  void _navigateWeek(int weeks) {
    setState(() {
      _weekStartDate = _weekStartDate.add(Duration(days: weeks * 7));
    });
    _autoSaveWeeklyPlan();
  }

  void _goToToday() {
    setState(() {
      _calculateWeekStart();
    });
    _autoSaveWeeklyPlan();
  }

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

  Map<String, dynamic> _getWeeklyPlanData() {
    return {
             'title': 'Weekly Plan - ${_weekStartDate.toIso8601String().split('T')[0]}',
      'week_start_date': _weekStartDate.toIso8601String().split('T')[0],
      'periods': _periods,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weekly Plan'),
            SizedBox(height: 4),
              Text(
                _getWeekRangeString(),
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveLessonsToDatabase,
            tooltip: 'Save Weekly Plan',
          ),
          IconButton(
            icon: Icon(Icons.chevron_left),
            onPressed: () => _navigateWeek(-1),
            tooltip: 'Previous Week',
          ),
          IconButton(
            icon: Icon(Icons.today),
            onPressed: _goToToday,
            tooltip: 'This Week',
          ),
          IconButton(
            icon: Icon(Icons.chevron_right),
            onPressed: () => _navigateWeek(1),
            tooltip: 'Next Week',
          ),
        ],
      ),
      body: _isLoadingPeriods || _periods == null
          ? Center(child: CircularProgressIndicator())
          : WeeklyPlanWidget(
              key: _weeklyPlanKey,
              periods: _periods!,
              isVerticalLayout: _isVerticalLayout,
              weekStartDate: _weekStartDate,
              onLayoutChanged: (v) => setState(() => _isVerticalLayout = v),
              onPreviousWeek: () => _navigateWeek(-1),
              onNextWeek: () => _navigateWeek(1),
              onDayTap: _navigateToDayDetail,
              onPlanChanged: (_) => setState(() {}),
        ),
      );
    }

  String _getWeekRangeString() {
    final start = _weekStartDate;
    final end = _weekStartDate.add(Duration(days: 4));
         return '${start.day}/${start.month} - ${end.day}/${end.month}';
  }

  void _navigateToDayDetail(int dayIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnhancedDayDetailPage(
          day: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'][dayIndex],
          dayIndex: dayIndex,
          weeklyPlanData: _weeklyPlanKey.currentState?.planData.where((e) => e.dayIndex == dayIndex).toList() ?? [],
          events: [],
          onPlanDataChanged: (updatedData) {
            if (_weeklyPlanKey.currentState != null) {
              final current = List.of(_weeklyPlanKey.currentState!.planData);
              current.removeWhere((e) => e.dayIndex == dayIndex);
              current.addAll(updatedData);
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}
