// lib/pages/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'week_view.dart';
import 'term_planner_page.dart';
import 'day_view.dart';
import 'enhanced_day_detail_page.dart';
import 'long_term_planning_page.dart';

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
    LongTermPlanningPage(), // Add the new long-term planning page
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavigation(isTablet),
      floatingActionButton: _buildSmartFAB(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        type: BottomNavigationBarType.fixed, // Changed to fixed to accommodate 4 tabs
        
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
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.description),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Icon(Icons.description, color: Theme.of(context).primaryColor),
            ),
            label: 'Planning',
            tooltip: 'Long-term planning documents',
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

  Widget _buildSmartFAB() {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: FloatingActionButton.extended(
        onPressed: _showQuickActionsSheet,
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 8,
        extendedPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 24 : 20,
        ),
        icon: Icon(
          Icons.add,
          size: isTablet ? 28 : 24,
        ),
        label: Text(
          'Quick Add',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  void _showQuickActionsSheet() {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    HapticFeedback.lightImpact();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isTablet ? 24 : 20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              Padding(
                padding: EdgeInsets.all(isTablet ? 24 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                      ),
                    ),
                    
                    SizedBox(height: isTablet ? 24 : 20),
                    
                    // Quick action buttons
                    GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 2,
                      crossAxisSpacing: isTablet ? 16 : 12,
                      mainAxisSpacing: isTablet ? 16 : 12,
                      childAspectRatio: 2.5,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildQuickActionButton(
                          'Add Lesson',
                          Icons.school,
                          Colors.blue[600]!,
                          () {
                            Navigator.pop(context);
                            _navigateToEnhancedDetail();
                          },
                          isTablet,
                        ),
                        _buildQuickActionButton(
                          'Plan Week',
                          Icons.calendar_view_week,
                          Colors.green[600]!,
                          () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 1);
                          },
                          isTablet,
                        ),
                        _buildQuickActionButton(
                          'Term Events',
                          Icons.event,
                          Colors.orange[600]!,
                          () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 2);
                          },
                          isTablet,
                        ),
                        _buildQuickActionButton(
                          'Long-term Plan',
                          Icons.description,
                          Colors.purple[600]!,
                          () {
                            Navigator.pop(context);
                            setState(() => _currentIndex = 3);
                          },
                          isTablet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isTablet,
  ) {
    return Material(
      elevation: 0,
      borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: color,
                size: isTablet ? 24 : 20,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToEnhancedDetail() {
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