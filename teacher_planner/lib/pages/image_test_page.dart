// lib/pages/image_test_page.dart
// Test page to preview your images

import 'package:flutter/material.dart';
import '../widgets/app_images.dart';

class ImageTestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Test Page'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Image Test Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            
            // Test Hero Image
            Text('Hero Image:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            AppImages.heroImage(
              imagePath: 'assets/images/welcome_hero.png',
              title: 'Welcome to Teacher Planner',
              subtitle: 'Organize your lessons with ease',
              onTap: () => print('Hero image tapped!'),
            ),
            SizedBox(height: 30),
            
            // Test Banner Images
            Text('Banner Images:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            AppImages.bannerImage(
              imagePath: 'assets/images/planner_banner.png',
              height: 150,
              borderRadius: BorderRadius.circular(12),
            ),
            SizedBox(height: 16),
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
            SizedBox(height: 30),
            
            // Test Profile Image
            Text('Profile Image:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Center(
              child: AppImages.profileImage(
                imagePath: 'assets/images/teacher_profile.png',
                size: 120,
              ),
            ),
            SizedBox(height: 30),
            
            // Test Background Pattern
            Text('Background Pattern Test:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12),
              ),
              child: AppImages.decorativeBackground(
                imagePath: 'assets/images/background_pattern.png',
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Content over background pattern',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            
            // Error handling test
            Text('Error Handling Test:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('This should show a placeholder if image is missing:'),
            SizedBox(height: 8),
            AppImages.bannerImage(
              imagePath: 'assets/images/missing_image.png',
              height: 100,
            ),
            SizedBox(height: 30),
            
            // Instructions
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Instructions:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• If you see placeholder icons, the image file is missing'),
                  Text('• Add your images to: assets/images/'),
                  Text('• Supported formats: PNG, JPG'),
                  Text('• Recommended sizes: 800x300px for banners'),
                  Text('• Test this page after adding your images'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 