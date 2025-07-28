// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // Theme Settings Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appearance',
                        style: GoogleFonts.shadowsIntoLightTwo(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // Dark Mode Toggle
                      ListTile(
                        leading: Icon(
                          themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'Dark Mode',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          themeProvider.isDarkMode 
                            ? 'Dark theme is enabled' 
                            : 'Light theme is enabled',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        trailing: Switch(
                          value: themeProvider.isDarkMode,
                          onChanged: (value) {
                            themeProvider.toggleTheme();
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      
                      SizedBox(height: 8),
                      
                      // Theme Mode Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => themeProvider.setThemeMode(ThemeMode.light),
                              icon: Icon(Icons.light_mode),
                              label: Text('Light'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.themeMode == ThemeMode.light 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[300],
                                foregroundColor: themeProvider.themeMode == ThemeMode.light 
                                  ? Colors.white 
                                  : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => themeProvider.setThemeMode(ThemeMode.dark),
                              icon: Icon(Icons.dark_mode),
                              label: Text('Dark'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.themeMode == ThemeMode.dark 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[300],
                                foregroundColor: themeProvider.themeMode == ThemeMode.dark 
                                  ? Colors.white 
                                  : Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => themeProvider.setThemeMode(ThemeMode.system),
                              icon: Icon(Icons.settings_system_daydream),
                              label: Text('System'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: themeProvider.themeMode == ThemeMode.system 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey[300],
                                foregroundColor: themeProvider.themeMode == ThemeMode.system 
                                  ? Colors.white 
                                  : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16),
              
              // Other Settings Section
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'General',
                        style: GoogleFonts.shadowsIntoLightTwo(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 16),
                      
                      // App Version
                      ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'App Version',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          '1.0.0',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                      
                      // About
                      ListTile(
                        leading: Icon(
                          Icons.help_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        title: Text(
                          'About',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        subtitle: Text(
                          'Teacher Planner App',
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'Roboto',
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        onTap: () {
                          _showAboutDialog(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'About Teacher Planner',
          style: GoogleFonts.shadowsIntoLightTwo(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        content: Text(
          'A comprehensive planning app designed specifically for teachers. '
          'Organize your weekly lessons, term planning, and long-term curriculum '
          'with an intuitive interface.',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Roboto',
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
} 