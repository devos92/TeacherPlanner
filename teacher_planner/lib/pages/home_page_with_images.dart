// lib/pages/home_page_with_images.dart
// Example of how to add images to your home page

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/app_images.dart';
import 'week_view.dart';
import 'term_planner_page.dart';
import 'day_view.dart';
import 'long_term_planning_page.dart';
import 'settings_page.dart';
import 'user_profile_page.dart';
import '../services/auth_service.dart';

class HomePageWithImages extends StatefulWidget {
  @override
  _HomePageWithImagesState createState() => _HomePageWithImagesState();
}

class _HomePageWithImagesState extends State<HomePageWithImages> with TickerProviderStateMixin {
  int _currentIndex = 1;
  late PageController _pageController;
  
  late final List<Widget> _pages = [
    TermPlannerPage(),
    WeekView(),
    DayView(),
    LongTermPlanningPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChanged(int index) {
    if (_currentIndex == 1 && index != 1) {
      _autoSaveWeekData();
    }
    setState(() => _currentIndex = index);
    HapticFeedback.lightImpact();
  }

  void _autoSaveWeekData() {
    debugPrint('💾 Auto-saving week data on tab change...');
  }

  String _getPageTitle() {
    switch (_currentIndex) {
      case 0: return 'Term Planner';
      case 1: return 'Weekly Plan';
      case 2: return 'Day View';
      case 3: return 'Long-term Planning';
      default: return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Scaffold(
      // Example: Add a background image to the entire app
      body: AppImages.decorativeBackground(
        imagePath: 'assets/images/background_pattern.png', // Your background image
        child: Scaffold(
          appBar: AppBar(
            title: Text(_getPageTitle()),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(Icons.add_task),
                onPressed: _showPlannerOptions,
                tooltip: 'Planner Options',
              ),
              IconButton(
                icon: Icon(Icons.storage),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DatabaseTestPage()),
                ),
                tooltip: 'Database Test',
              ),
              IconButton(
                icon: Icon(Icons.person),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserProfilePage()),
                ),
                tooltip: 'User Profile',
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                ),
                tooltip: 'Settings',
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: _buildBottomNavigationBar(isTablet),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isTablet) {
    if (isTablet) {
      // Tablet: Side navigation with images
      return NavigationRail(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        labelType: NavigationRailLabelType.all,
        destinations: [
          NavigationRailDestination(
            icon: Icon(Icons.calendar_today),
            selectedIcon: Icon(Icons.calendar_today, color: Colors.blue),
            label: Text('Term'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.view_week),
            selectedIcon: Icon(Icons.view_week, color: Colors.blue),
            label: Text('Week'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.view_day),
            selectedIcon: Icon(Icons.view_day, color: Colors.blue),
            label: Text('Day'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.timeline),
            selectedIcon: Icon(Icons.timeline, color: Colors.blue),
            label: Text('Long-term'),
          ),
        ],
      );
    } else {
      // Phone: Bottom navigation with images
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Term',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_week),
            label: 'Week',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_day),
            label: 'Day',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Long-term',
          ),
        ],
      );
    }
  }

  void _showPlannerOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Planner Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Example: Add a banner image to the dialog
            AppImages.bannerImage(
              imagePath: 'assets/images/planner_banner.png', // Your banner image
              height: 120,
              borderRadius: BorderRadius.circular(8),
            ),
            SizedBox(height: 16),
            Text('Choose your planner options:'),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create New Planner'),
              onTap: () {
                Navigator.pop(context);
                // Handle new planner creation
              },
            ),
            ListTile(
              leading: Icon(Icons.folder_open),
              title: Text('Load Existing Planner'),
              onTap: () {
                Navigator.pop(context);
                // Handle loading existing planner
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}

// Example: How to add a hero image to your welcome screen
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero image at the top
            AppImages.heroImage(
              imagePath: 'assets/images/welcome_hero.png', // Your hero image
              title: 'Welcome to Teacher Planner',
              subtitle: 'Organize your lessons with ease',
              onTap: () {
                // Navigate to main app
              },
            ),
            
            SizedBox(height: 24),
            
            // Banner images for different sections
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  AppImages.bannerImage(
                    imagePath: 'assets/images/weekly_planner_banner.png',
                    height: 150,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  SizedBox(height: 16),
                  AppImages.bannerImage(
                    imagePath: 'assets/images/term_planner_banner.png',
                    height: 150,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Profile image example
            Center(
              child: AppImages.profileImage(
                imagePath: 'assets/images/teacher_profile.png',
                size: 120,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 