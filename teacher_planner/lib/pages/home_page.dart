// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'week_view.dart';
import 'term_planner_page.dart';
import 'day_view.dart';
import 'enhanced_day_detail_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 1; // Default to week view
  final _pages = [
    TermPlannerPage(),
    WeekView(),
    DayView(),
  ];

  @override
  Widget build(BuildContext context) {
    // Get screen information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isTablet = screenWidth > 768;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return Scaffold(
      // Use SafeArea to handle notches and status bars
      body: SafeArea(
        child: _pages[_currentIndex],
      ),
      
      bottomNavigationBar: _buildBottomNavigation(isTablet),
      
      floatingActionButton: _buildFloatingActionButton(context, isTablet),
      
      // Position FAB for better thumb reach on mobile
      floatingActionButtonLocation: isTablet 
        ? FloatingActionButtonLocation.endFloat
        : FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildBottomNavigation(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        
        // Adaptive sizing
        iconSize: isTablet ? 28 : 24,
        selectedFontSize: isTablet ? 14 : 12,
        unselectedFontSize: isTablet ? 12 : 10,
        
        // Enhanced visual feedback
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        
        // Better spacing for touch targets
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.calendar_today),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
            ),
            label: 'Term Planner',
            tooltip: 'View and manage term calendar',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.view_week),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.view_week, color: Theme.of(context).primaryColor),
            ),
            label: 'Week',
            tooltip: 'Weekly lesson planner',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.view_day),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.view_day, color: Theme.of(context).primaryColor),
            ),
            label: 'Day',
            tooltip: 'Daily planner view',
          ),
        ],
        
        onTap: (index) {
          setState(() => _currentIndex = index);
          
          // Haptic feedback for better mobile experience
          if (Theme.of(context).platform == TargetPlatform.iOS ||
              Theme.of(context).platform == TargetPlatform.android) {
            // Light haptic feedback on tab change
            HapticFeedback.lightImpact();
          }
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, bool isTablet) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToEnhancedDetail(context),
      
      // Adaptive sizing
      icon: Icon(
        Icons.edit_note,
        size: isTablet ? 24 : 20,
      ),
      
      label: Text(
        'Quick Edit',
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      tooltip: 'Quick access to enhanced day detail editor',
      heroTag: 'enhanced_day_detail',
      
      // Better elevation for mobile
      elevation: 6,
      highlightElevation: 8,
    );
  }

  void _navigateToEnhancedDetail(BuildContext context) {
    // Add haptic feedback
    HapticFeedback.mediumImpact();
    
    // Get current day name
    final now = DateTime.now();
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final currentDayName = dayNames[now.weekday - 1];
    final dayIndex = now.weekday <= 5 ? now.weekday - 1 : 0; // Default to Monday for weekends
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EnhancedDayDetailPage(
          day: currentDayName,
          events: [], // Add empty events list
          dayIndex: dayIndex, // Add required dayIndex parameter
        ),
        
        // Custom transition for better mobile experience
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        
        transitionDuration: Duration(milliseconds: 300),
      ),
    );
  }
} 