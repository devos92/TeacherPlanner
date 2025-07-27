// lib/examples/enhanced_features_example.dart

import 'package:flutter/material.dart';
import '../pages/enhanced_day_detail_page.dart';
import '../models/curriculum_models.dart';
import '../services/curriculum_service.dart';
import '../services/database_service.dart';
import 'week_view.dart';

/// Example demonstrating how to use the enhanced day detail page features
class EnhancedFeaturesExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enhanced Features Example'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enhanced Day Detail Page Features',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: 16),
            
            // Feature descriptions
            _buildFeatureCard(
              context,
              'Australian Curriculum Integration',
              'Access and select curriculum outcomes for lesson planning',
              Icons.school,
              Colors.blue,
            ),
            
            _buildFeatureCard(
              context,
              'Enhanced Event Management',
              'Rich event editing with attachments, hyperlinks, and curriculum links',
              Icons.event,
              Colors.green,
            ),
            
            _buildFeatureCard(
              context,
              'File Management',
              'Upload and manage attachments for events and reflections',
              Icons.attach_file,
              Colors.orange,
            ),
            
            _buildFeatureCard(
              context,
              'Daily Reflection System',
              'Write and save daily reflections with attachments',
              Icons.edit_note,
              Colors.purple,
            ),
            
            _buildFeatureCard(
              context,
              'Database Integration',
              'Persistent storage with MongoDB or Supabase support',
              Icons.storage,
              Colors.teal,
            ),
            
            SizedBox(height: 24),
            
            // Demo button
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showEnhancedDayDetail(context),
                icon: Icon(Icons.open_in_new),
                label: Text('Open Enhanced Day Detail Demo'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Configuration examples
            Text(
              'Configuration Examples',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            
            _buildCodeExample(
              context,
              'Storage Service Setup',
              '''
// Configure storage service
final storageService = StorageServiceFactory.create(StorageProvider.supabase);

// For AWS S3
final storageService = StorageServiceFactory.create(StorageProvider.awsS3);

// For development (mock)
final storageService = StorageServiceFactory.create(StorageProvider.supabase);
              ''',
            ),
            
            _buildCodeExample(
              context,
              'Database Service Setup',
              '''
// Configure database service
final databaseService = DatabaseServiceFactory.create(DatabaseProvider.mongodb);

// For Supabase
final databaseService = DatabaseServiceFactory.create(DatabaseProvider.supabase);

// For development (mock)
final databaseService = DatabaseServiceFactory.create(DatabaseProvider.mongodb);
              ''',
            ),
            
            _buildCodeExample(
              context,
              'Curriculum Service Usage',
              '''
// Get curriculum years
final curriculumService = CurriculumService();
final years = curriculumService.getCurriculumYears();

// Get specific year
final foundationYear = curriculumService.getYearById('foundation');

// Get selected outcomes
final outcomes = curriculumService.getSelectedOutcomes(['acela1426', 'acela1427']);
              ''',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildCodeExample(
    BuildContext context,
    String title,
    String code,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                code,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnhancedDayDetail(BuildContext context) {
    // Create sample events for demonstration
    final sampleEvents = [
      EventBlock(
        day: 'Mon',
        subject: 'Mathematics - Number Patterns',
        subtitle: 'Foundation Year',
        body: 'Students will explore number patterns through hands-on activities and games.',
        color: Colors.blue,
        startHour: 9,
        startMinute: 0,
        finishHour: 10,
        finishMinute: 30,
      ),
      EventBlock(
        day: 'Mon',
        subject: 'English - Reading Comprehension',
        subtitle: 'Year 1',
        body: 'Reading and discussing the story "The Very Hungry Caterpillar" with focus on sequencing events.',
        color: Colors.green,
        startHour: 11,
        startMinute: 0,
        finishHour: 12,
        finishMinute: 0,
      ),
      EventBlock(
        day: 'Mon',
        subject: 'Science - Living Things',
        subtitle: 'Foundation Year',
        body: 'Observing and documenting different types of living things in the school garden.',
        color: Colors.orange,
        startHour: 14,
        startMinute: 0,
        finishHour: 15,
        finishMinute: 0,
      ),
    ];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnhancedDayDetailPage(
          day: 'Monday',
          events: sampleEvents,
        ),
      ),
    );
  }
}

/// Example of how to create enhanced events programmatically
class EnhancedEventExample {
  static EnhancedEventBlock createSampleEvent() {
    return EnhancedEventBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      day: 'Mon',
      subject: 'Mathematics - Addition',
      subtitle: 'Foundation Year',
      body: 'Students will learn basic addition through manipulatives and visual aids.',
      color: Colors.blue,
      startHour: 9,
      startMinute: 0,
      finishHour: 10,
      finishMinute: 0,
      attachmentIds: ['attachment1', 'attachment2'],
      curriculumOutcomeIds: ['acmna001', 'acmna002'],
      hyperlinks: ['link1', 'link2'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static DailyReflection createSampleReflection() {
    return DailyReflection(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      day: 'Mon',
      content: 'Today\'s mathematics lesson went well. Students were engaged with the manipulatives and showed good understanding of basic addition concepts.',
      attachmentIds: ['reflection_attachment1'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static Attachment createSampleAttachment() {
    return Attachment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'lesson_plan.pdf',
      url: 'https://example.com/lesson_plan.pdf',
      type: AttachmentType.document,
      uploadedAt: DateTime.now(),
      size: 1024000, // 1MB
    );
  }
}

/// Example of how to integrate with the curriculum service
class CurriculumIntegrationExample {
  static void demonstrateCurriculumUsage() {
    final curriculumService = CurriculumService();
    
    // Get all curriculum years
    final years = curriculumService.getCurriculumYears();
    print('Available years: ${years.map((y) => y.name).join(', ')}');
    
    // Get Foundation Year subjects
    final foundationYear = curriculumService.getYearById('foundation');
    print('Foundation subjects: ${foundationYear.subjects.map((s) => s.name).join(', ')}');
    
    // Get English outcomes for Foundation Year
    final englishSubject = foundationYear.subjects.firstWhere((s) => s.name == 'English');
    final languageStrand = englishSubject.strands.firstWhere((s) => s.name == 'Language');
    print('Language outcomes: ${languageStrand.outcomes.map((o) => o.code).join(', ')}');
  }
}

/// Example of how to use the storage service
class StorageIntegrationExample {
  static Future<void> demonstrateStorageUsage() async {
    final storageService = StorageServiceFactory.create(StorageProvider.supabase);
    
    // Example file upload (would need actual file)
    // final url = await storageService.uploadFile(file, 'events/event123');
    
    // Example file listing
    // final attachments = await storageService.listAttachments('events/event123');
    
    print('Storage service configured successfully');
  }
}

/// Example of how to use the database service
class DatabaseIntegrationExample {
  static Future<void> demonstrateDatabaseUsage() async {
    final databaseService = DatabaseServiceFactory.create(DatabaseProvider.mongodb);
    
    // Example event operations
    final event = EnhancedEventExample.createSampleEvent();
    // await databaseService.saveEvent(event);
    
    // Example reflection operations
    final reflection = EnhancedEventExample.createSampleReflection();
    // await databaseService.saveReflection(reflection);
    
    print('Database service configured successfully');
  }
} 