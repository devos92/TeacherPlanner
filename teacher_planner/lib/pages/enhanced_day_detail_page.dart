// lib/pages/enhanced_day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/curriculum_models.dart';
import '../models/event_block.dart';
import '../models/weekly_plan_data.dart'; // Updated import path
import '../services/pdf_service.dart';
import '../services/image_service.dart';
import '../widgets/curriculum_sidebar.dart';
import '../widgets/attachment_manager.dart';
import 'week_view.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';

class EnhancedDayDetailPage extends StatefulWidget {
  final String day;
  final List<EventBlock> events;
  final List<WeeklyPlanData>? weeklyPlanData; // Add weekly plan data
  final int dayIndex; // Add day index for filtering

  const EnhancedDayDetailPage({
    Key? key,
    required this.day,
    required this.events,
    this.weeklyPlanData,
    required this.dayIndex,
  }) : super(key: key);

  @override
  _EnhancedDayDetailPageState createState() => _EnhancedDayDetailPageState();
}

class _EnhancedDayDetailPageState extends State<EnhancedDayDetailPage> {
  // events and selections
  late List<EnhancedEventBlock> _enhancedEvents;
  List<String> _selectedOutcomeCodes = [];
  List<CurriculumOutcome> _selectedOutcomes = [];
  bool _showCurriculumSidebar = true;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _loadLessonsFromWeeklyPlan();
  }

  void _loadLessonsFromWeeklyPlan() {
    List<EnhancedEventBlock> lessons = [];

    // Load lessons from weekly plan data for this specific day
    if (widget.weeklyPlanData != null) {
      // Load regular lessons
      final dayLessons = widget.weeklyPlanData!.where((data) => 
        data.dayIndex == widget.dayIndex && data.isLesson
      ).toList();

      // Sort by period index to maintain proper order
      dayLessons.sort((a, b) => a.periodIndex.compareTo(b.periodIndex));

      for (final lesson in dayLessons) {
        // Convert WeeklyPlanData to EnhancedEventBlock
        lessons.add(EnhancedEventBlock(
          id: lesson.lessonId.isNotEmpty ? lesson.lessonId : UniqueKey().toString(),
          day: widget.day,
          subject: lesson.subject.isNotEmpty ? lesson.subject : 'Lesson ${lesson.periodIndex + 1}',
          subtitle: 'Period ${lesson.periodIndex + 1}',
          body: lesson.content.isNotEmpty ? lesson.content : 'No description available',
          color: lesson.lessonColor ?? _getColorForPeriod(lesson.periodIndex), // Use lesson's custom color if available
          startHour: 8 + lesson.periodIndex, // Default start time based on period
          startMinute: 0,
          finishHour: 9 + lesson.periodIndex, // Default end time based on period
          finishMinute: 0,
          widthFactor: 1.0,
          attachmentIds: [], // Will be populated from lesson data
          curriculumOutcomeIds: [], // Will be populated from lesson data
          hyperlinks: [], // Will be populated from lesson data
          createdAt: lesson.date ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));

        // Add sub-lessons if they exist
        if (lesson.subLessons.isNotEmpty) {
          // Sort sub-lessons by their period index as well
          final sortedSubLessons = lesson.subLessons.toList();
          sortedSubLessons.sort((a, b) => a.periodIndex.compareTo(b.periodIndex));
          
          for (final subLesson in sortedSubLessons) {
            lessons.add(EnhancedEventBlock(
              id: subLesson.lessonId.isNotEmpty ? subLesson.lessonId : UniqueKey().toString(),
              day: widget.day,
              subject: subLesson.subject.isNotEmpty ? subLesson.subject : 'Sub Lesson',
              subtitle: 'Period ${subLesson.periodIndex + 1} - Additional',
              body: subLesson.content.isNotEmpty ? subLesson.content : 'No description available',
              color: subLesson.lessonColor ?? _getColorForPeriod(subLesson.periodIndex), // Use sub lesson's custom color if available
              startHour: 8 + subLesson.periodIndex,
              startMinute: 0,
              finishHour: 9 + subLesson.periodIndex,
              finishMinute: 0,
              widthFactor: 1.0,
              attachmentIds: [],
              curriculumOutcomeIds: [],
              hyperlinks: [],
              createdAt: subLesson.date ?? DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
        }
      }

      // Also load full week events for this day
      final fullWeekEvents = widget.weeklyPlanData!.where((data) => 
        data.dayIndex == widget.dayIndex && data.isFullWeekEvent
      ).toList();

      // Sort full week events by period index too
      fullWeekEvents.sort((a, b) => a.periodIndex.compareTo(b.periodIndex));

      for (final fullWeekEvent in fullWeekEvents) {
        lessons.add(EnhancedEventBlock(
          id: fullWeekEvent.lessonId.isNotEmpty ? fullWeekEvent.lessonId : UniqueKey().toString(),
          day: widget.day,
          subject: fullWeekEvent.subject.isNotEmpty ? fullWeekEvent.subject : 'Event',
          subtitle: '', // No subtitle for full week events - just the event name
          body: fullWeekEvent.notes.isNotEmpty ? fullWeekEvent.notes : '',
          color: Colors.orange.withOpacity(0.3), // Different color for full week events
          startHour: 8 + fullWeekEvent.periodIndex,
          startMinute: 0,
          finishHour: 9 + fullWeekEvent.periodIndex,
          finishMinute: 0,
          widthFactor: 1.0,
          attachmentIds: [], // No attachments for full week events
          curriculumOutcomeIds: [], // No curriculum outcomes for full week events
          hyperlinks: [], // No hyperlinks for full week events
          createdAt: fullWeekEvent.date ?? DateTime.now(),
          updatedAt: DateTime.now(),
          isFullWeekEvent: true, // Mark this as a full week event
        ));
      }
    }

    // Also load from existing EventBlock data if no weekly plan data
    if (lessons.isEmpty && widget.events.isNotEmpty) {
      lessons = widget.events.map((e) {
        return EnhancedEventBlock(
          id: UniqueKey().toString(),
          day: e.day,
          subject: e.subject,
          subtitle: e.subtitle,
          body: e.body,
          color: e.color,
          startHour: e.startHour,
          startMinute: e.startMinute,
          finishHour: e.finishHour,
          finishMinute: e.finishMinute,
          widthFactor: e.widthFactor,
          attachmentIds: [],
          curriculumOutcomeIds: [],
          hyperlinks: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      }).toList();
      
      // Sort lessons by start time for proper order
      lessons.sort((a, b) {
        final aTime = a.startHour * 60 + a.startMinute;
        final bTime = b.startHour * 60 + b.startMinute;
        return aTime.compareTo(bTime);
      });
    }

    setState(() {
      _enhancedEvents = lessons;
    });
  }

  Color _getColorForPeriod(int periodIndex) {
    // Use the same lesson colors as the weekly plan for consistency
    const List<Color> lessonColors = [
      Color(0xFFD9BDAF), Color(0xFFC68484), Color(0xFFAE7A53), 
      Color(0xFF8F8369), Color(0xFF848370), Color(0xFFA1ADA7), 
      Color(0xFFB16B47), Color(0xFFE4D8C8), Color(0xFFD5916A), 
      Color(0xFFD6A48B), Color(0xFF7F6E5D), Color(0xFFC2914C),
      Color(0xFFB07B5C), Color(0xFF9A8C6F),
      Color(0xFFD9C89C), Color(0xFFC4C0B4),
      Color(0xFFBFAC84), Color(0xFFBFAC84),
      Color(0xFFF2DBC9), Color(0xFFD49F78),
      Color(0xFFF8ECD9),
    ];
    
    // Return a lesson color based on period index, cycling through the available colors
    return lessonColors[periodIndex % lessonColors.length];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;
    final isDesktop = screenSize.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day} – Daily Work Pad'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          // Print Button
          IconButton(
            icon: _isGeneratingPdf 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.print),
            onPressed: _isGeneratingPdf ? null : () => _printDailyWorkPad(),
            tooltip: 'Print Daily Work Pad',
          ),
          // Share Button
          IconButton(
            icon: _isGeneratingPdf 
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.share),
            onPressed: _isGeneratingPdf ? null : () => _shareDailyWorkPad(),
            tooltip: 'Share Daily Work Pad',
          ),
          // Only show sidebar toggle on larger screens
          if (!isMobile)
            IconButton(
              icon: Icon(
                  _showCurriculumSidebar ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () => setState(() => _showCurriculumSidebar = !_showCurriculumSidebar),
              tooltip: 'Toggle Curriculum Sidebar',
            ),
        ],
      ),
      body: Row(
        children: [
          // Responsive sidebar - hide on mobile, show on larger screens
          if (_showCurriculumSidebar && !isMobile)
            SizedBox(
              width: isDesktop ? 350 : 300,
              child: CurriculumSidebar(
                width: isDesktop ? 350 : 300,
                onSelectionChanged: (outcomes) {
                  // Convert CurriculumData to CurriculumOutcome and replace selected outcomes
                  final newOutcomes = outcomes.map((outcome) => CurriculumOutcome(
                    id: outcome.id,
                    code: outcome.code ?? '',
                    description: outcome.description ?? '',
                    elaboration: outcome.elaboration ?? '',
                  )).toList();
                  
                  // Replace the selected outcomes (don't add to existing)
                  setState(() {
                    _selectedOutcomes = newOutcomes;
                    _selectedOutcomeCodes = newOutcomes.map((o) => o.code).toList();
                  });
                },
              ),
            ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade50,
                    Colors.grey.shade100,
                  ],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(
                  isMobile ? 16.0 : 
                  isTablet ? 20.0 : 24.0
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isDesktop ? 800 : double.infinity,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day Header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isMobile ? 16 : 20),
                        margin: EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.1),
                              theme.primaryColor.withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.primaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.day,
                              style: (isMobile ? theme.textTheme.headlineSmall : theme.textTheme.headlineMedium)?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Daily Work Pad',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.primaryColor.withOpacity(0.7),
                              ),
                            ),
                            if (_enhancedEvents.isNotEmpty) ...[
                              SizedBox(height: 8),
                              Text(
                                '${_enhancedEvents.length} lesson${_enhancedEvents.length == 1 ? '' : 's'} loaded from weekly plan',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.primaryColor.withOpacity(0.6),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      
                      // Lessons List
                      if (_enhancedEvents.isNotEmpty) ...[
                        ..._enhancedEvents.map((event) => _buildEventItem(event, _enhancedEvents.indexOf(event))).toList(),
                      ] else ...[
                        // Empty State
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isMobile ? 30 : 40),
                          margin: EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.school_outlined,
                                size: isMobile ? 48 : 64,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No Lessons for ${widget.day}',
                                style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Lessons from your weekly plan will appear here.\nGo back to the weekly plan to add lessons for this day.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Add Lesson Button
                      _buildAddLessonButton(theme, isMobile, isTablet, isDesktop),
                      
                      SizedBox(height: 100), // Bottom padding
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(EnhancedEventBlock event, int index) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    
    return Container(
      margin: EdgeInsets.only(
        bottom: isTablet ? 16 : 12,
        left: isTablet ? 20 : 16,
        right: isTablet ? 20 : 16,
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color: event.color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: event.color.withOpacity(0.08),
                blurRadius: 24,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _editEvent(event),
              borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
              child: Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with period and time
                    Row(
                      children: [
                        // Period badge with modern design
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 10,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                            border: Border.all(
                              color: event.color.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            'Period ${event.periodIndex + 1}',
                            style: TextStyle(
                              color: event.color,
                              fontSize: isTablet ? 14 : 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        
                        Spacer(),
                        
                        // Time with improved typography
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 12 : 10,
                            vertical: isTablet ? 8 : 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.schedule,
                                size: isTablet ? 16 : 14,
                                color: Colors.grey[600],
                              ),
                              SizedBox(width: 4),
                              Text(
                                '${event.startTime} - ${event.endTime}',
                                style: TextStyle(
                                  fontSize: isTablet ? 14 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: isTablet ? 16 : 12),
                    
                    // Subject with better typography hierarchy
                    Text(
                      event.subject,
                      style: TextStyle(
                        fontSize: isTablet ? 22 : 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[900],
                        height: 1.2,
                      ),
                    ),
                    
                    if (event.notes.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        event.notes,
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    
                    // Enhanced metadata section
                    if (event.attachments.isNotEmpty || event.hyperlinks.isNotEmpty || event.curriculumOutcomes.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 16 : 12),
                      Container(
                        padding: EdgeInsets.all(isTablet ? 16 : 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                          border: Border.all(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            if (event.attachments.isNotEmpty)
                              _buildMetadataRow(
                                Icons.attach_file,
                                '${event.attachments.length} attachment${event.attachments.length > 1 ? 's' : ''}',
                                Colors.blue[600]!,
                                isTablet,
                              ),
                            
                            if (event.hyperlinks.isNotEmpty) ...[
                              if (event.attachments.isNotEmpty) SizedBox(height: 8),
                              _buildMetadataRow(
                                Icons.link,
                                '${event.hyperlinks.length} link${event.hyperlinks.length > 1 ? 's' : ''}',
                                Colors.green[600]!,
                                isTablet,
                              ),
                            ],
                            
                            if (event.curriculumOutcomes.isNotEmpty) ...[
                              if (event.attachments.isNotEmpty || event.hyperlinks.isNotEmpty) SizedBox(height: 8),
                              _buildMetadataRow(
                                Icons.school,
                                '${event.curriculumOutcomes.length} outcome${event.curriculumOutcomes.length > 1 ? 's' : ''}',
                                Colors.purple[600]!,
                                isTablet,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _editEvent(EnhancedEventBlock event) {
    // TODO: Implement event editing functionality
    // This could navigate to an edit event page or show a dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit functionality coming soon for ${event.subject}'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildMetadataRow(IconData icon, String text, Color color, bool isTablet) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(isTablet ? 8 : 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
          ),
          child: Icon(
            icon,
            size: isTablet ? 18 : 16,
            color: color,
          ),
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(EnhancedEventBlock event, ThemeData theme, bool isMobile, bool isTablet, bool isDesktop) {
    // Show simplified card for full week events
    if (event.isFullWeekEvent) {
      return Container(
        margin: EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.3), // More solid background
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: event.color.withOpacity(0.6), // More solid border
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event,
                color: event.color,
                size: isMobile ? 20 : 24,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.subject,
                      style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: event.color,
                      ),
                    ),
                    if (event.body.isNotEmpty) ...[
                      SizedBox(height: 4),
                      Text(
                        event.body,
                        style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                          color: event.color.withOpacity(0.8), // Less transparent text
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Regular lesson card for normal lessons
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Lesson Header
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.3), // More solid background
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              border: Border.all(
                color: event.color.withOpacity(0.6), // More solid border
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Subject and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.subject,
                        style: (isMobile ? theme.textTheme.titleMedium : theme.textTheme.titleLarge)?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: event.color,
                        ),
                      ),
                      if (event.subtitle.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          event.subtitle,
                          style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.titleMedium)?.copyWith(
                            color: event.color.withOpacity(0.8), // Less transparent text
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Lesson Content Box (Always Open)
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              border: Border.all(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description Section
                if (event.body.isNotEmpty) ...[
                  _buildDescriptionSection(event, theme, isMobile),
                  SizedBox(height: 20),
                ],
                
                // Attachments Section (Smaller)
                _buildAttachmentsSection(event, theme, isMobile, isTablet),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(EnhancedEventBlock event, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.description_outlined,
              color: event.color,
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: 8),
            Text(
              'Lesson Details',
              style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                fontWeight: FontWeight.bold,
                color: event.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
          child: TextFormField(
            initialValue: event.body,
            onChanged: (value) {
              setState(() {
                final updatedEvent = event.copyWith(
                  body: value,
                  updatedAt: DateTime.now(),
                );
                final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
                if (idx != -1) _enhancedEvents[idx] = updatedEvent;
              });
            },
            style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
              height: 1.5,
              color: Colors.black87,
            ),
            maxLines: 6,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter lesson description, activities, notes...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: isMobile ? 12 : 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsSection(EnhancedEventBlock event, ThemeData theme, bool isMobile, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.attach_file_outlined,
              color: event.color,
              size: isMobile ? 16 : 18,
            ),
            SizedBox(width: 8),
            Text(
              'Resources',
              style: (isMobile ? theme.textTheme.bodyMedium : theme.textTheme.titleSmall)?.copyWith(
                fontWeight: FontWeight.bold,
                color: event.color,
              ),
            ),
            Spacer(),
            // Add Buttons - Responsive layout
            if (isMobile)
              PopupMenuButton<String>(
                icon: Icon(Icons.add, color: event.color),
                onSelected: (value) {
                  if (value == 'picture') {
                    _addPicture(event);
                  } else if (value == 'link') {
                    _addHyperlink(event);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'picture',
                    child: Row(
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Picture'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'link',
                    child: Row(
                      children: [
                        Icon(Icons.link_outlined, size: 16),
                        SizedBox(width: 8),
                        Text('Link'),
                      ],
                    ),
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton.icon(
                    onPressed: () => _addPicture(event),
                    icon: Icon(Icons.add_photo_alternate_outlined, size: 16),
                    label: Text('Picture'),
                    style: TextButton.styleFrom(
                      foregroundColor: event.color,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                  ),
                  SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _addHyperlink(event),
                    icon: Icon(Icons.link_outlined, size: 16),
                    label: Text('Link'),
                    style: TextButton.styleFrom(
                      foregroundColor: event.color,
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                    ),
                  ),
                ],
              ),
          ],
        ),
        SizedBox(height: 12),
        
        // Pictures and Links in a responsive layout
        if (isMobile)
          Column(
            children: [
              _buildPicturesSection(event, theme, isMobile),
              SizedBox(height: 12),
              _buildHyperlinksSection(event, theme, isMobile),
            ],
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pictures Column
              Expanded(
                child: _buildPicturesSection(event, theme, isMobile),
              ),
              SizedBox(width: 16),
              // Hyperlinks Column
              Expanded(
                child: _buildHyperlinksSection(event, theme, isMobile),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPicturesSection(EnhancedEventBlock event, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pictures',
          style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        if (event.attachmentIds.isEmpty)
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.image_outlined,
                  color: Colors.grey.shade600,
                  size: isMobile ? 14 : 16,
                ),
                SizedBox(width: 6),
                Text(
                  'No pictures',
                  style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                ),
              ],
            ),
          )
        else
          // Display images in a grid layout for better visual presentation
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: event.attachmentIds.map((imagePath) {
              final file = File(imagePath);
              final fileName = path.basename(imagePath);
              
              return Container(
                width: isMobile ? 120 : 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: event.color.withOpacity(0.3),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image display
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                      child: Container(
                        height: isMobile ? 80 : 100,
                        width: double.infinity,
                        child: file.existsSync()
                            ? Image.file(
                                file,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade200,
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.grey.shade400,
                                      size: isMobile ? 30 : 40,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey.shade400,
                                  size: isMobile ? 30 : 40,
                                ),
                              ),
                      ),
                    ),
                    // Image info and controls
                    Padding(
                      padding: EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: event.color,
                              fontSize: isMobile ? 8 : 9,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!isMobile && file.existsSync()) ...[
                            SizedBox(height: 2),
                            Text(
                              ImageService.getFileSize(file),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey.shade600,
                                fontSize: 7,
                              ),
                            ),
                          ],
                          SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // View button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _viewImage(imagePath),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: event.color.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      'View',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: event.color,
                                        fontSize: isMobile ? 7 : 8,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 4),
                              // Remove button
                              GestureDetector(
                                onTap: () => _removePicture(event, imagePath),
                                child: Container(
                                  padding: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: isMobile ? 8 : 10,
                                    color: Colors.red.shade400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildHyperlinksSection(EnhancedEventBlock event, ThemeData theme, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links',
          style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        if (event.hyperlinks.isEmpty)
          Container(
            padding: EdgeInsets.all(isMobile ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.link_outlined,
                  color: Colors.grey.shade600,
                  size: isMobile ? 14 : 16,
                ),
                SizedBox(width: 6),
                Text(
                  'No links',
                  style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                    color: Colors.grey.shade600,
                    fontSize: isMobile ? 10 : 11,
                  ),
                ),
              ],
            ),
          )
        else
          ...event.hyperlinks.map((linkData) {
            final parts = linkData.split('|');
            final linkTitle = parts.length > 0 ? parts[0] : 'Link';
            final linkUrl = parts.length > 1 ? parts[1] : linkData;
            
            return Container(
              margin: EdgeInsets.only(bottom: 6),
              padding: EdgeInsets.all(isMobile ? 6 : 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        color: event.color,
                        size: isMobile ? 12 : 14,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          linkTitle,
                          style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: event.color,
                            fontSize: isMobile ? 9 : 10,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => _removeHyperlink(event, linkData),
                        icon: Icon(
                          Icons.close,
                          size: isMobile ? 10 : 12,
                          color: Colors.red.shade400,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(
                          minWidth: isMobile ? 14 : 16, 
                          minHeight: isMobile ? 14 : 16
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2),
                  Text(
                    linkUrl,
                    style: (isMobile ? theme.textTheme.bodySmall : theme.textTheme.bodyMedium)?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: isMobile ? 8 : 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildAddLessonButton(ThemeData theme, bool isMobile, bool isTablet, bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        onPressed: () => _addNewLesson(),
        icon: Icon(Icons.add, size: isMobile ? 20 : 24),
        label: Text(
          'Add New Lesson',
          style: (isMobile ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
        ),
      ),
    );
  }

  void _addNewLesson() {
    String subject = '';
    String subtitle = '';
    String content = '';
    final formKey = GlobalKey<FormState>();
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Lesson for ${widget.day}'),
        content: Container(
          width: isMobile ? double.infinity : 500,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Subject *',
                    hintText: 'e.g., Mathematics, English, Science',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject is required';
                    }
                    return null;
                  },
                  onChanged: (value) => subject = value,
                  autofocus: true,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Subtitle',
                    hintText: 'e.g., Period 1, Morning Session',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => subtitle = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Lesson Details',
                    hintText: 'Enter lesson description, activities, notes...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  onChanged: (value) => content = value,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                setState(() {
                  final newLesson = EnhancedEventBlock(
                    id: UniqueKey().toString(),
                    day: widget.day,
                    subject: subject.trim(),
                    subtitle: subtitle.trim(),
                    body: content.trim(),
                    color: _getColorForPeriod(_enhancedEvents.length), // Use lesson count as period
                    startHour: 8 + _enhancedEvents.length,
                    startMinute: 0,
                    finishHour: 9 + _enhancedEvents.length,
                    finishMinute: 0,
                    widthFactor: 1.0,
                    attachmentIds: [],
                    curriculumOutcomeIds: [],
                    hyperlinks: [],
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  _enhancedEvents.add(newLesson);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add Lesson'),
          ),
        ],
      ),
    );
  }

  void _printDailyWorkPad() async {
    setState(() {
      _isGeneratingPdf = true;
    });
    
    try {
      final pdfFile = await PdfService.generateDailyWorkPadPdf(
        day: widget.day,
        lessons: _enhancedEvents,
        teacherName: 'Teacher Name', // TODO: Get from user profile
      );
      
      if (pdfFile != null) {
        await PdfService.printPdf(pdfFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error generating PDF: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  void _shareDailyWorkPad() async {
    setState(() {
      _isGeneratingPdf = true;
    });
    
    try {
      final pdfFile = await PdfService.generateDailyWorkPadPdf(
        day: widget.day,
        lessons: _enhancedEvents,
        teacherName: 'Teacher Name', // TODO: Get from user profile
      );
      
      if (pdfFile != null) {
        await PdfService.sharePdf(pdfFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF shared successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing PDF: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isGeneratingPdf = false;
      });
    }
  }

  void _addPicture(EnhancedEventBlock event) async {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    // Show image source selection
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Picture to ${event.subject}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('Choose File'),
              onTap: () => Navigator.pop(context, null), // Will handle file picker
            ),
          ],
        ),
      ),
    );

    if (source == null) {
      // Handle file picker
      final file = await ImageService.pickAnyFile();
      if (file != null) {
        await _processSelectedFile(event, file);
      }
      return;
    }

    File? imageFile;
    if (source == ImageSource.camera) {
      imageFile = await ImageService.pickImageFromCamera();
    } else if (source == ImageSource.gallery) {
      imageFile = await ImageService.pickImageFromGallery();
    }

    if (imageFile != null) {
      await _processSelectedFile(event, imageFile);
    }
  }

  Future<void> _processSelectedFile(EnhancedEventBlock event, File file) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Processing file...'),
            ],
          ),
        ),
      );

      // Save file to local storage
      final savedPath = await ImageService.saveImageToLocal(file);
      
      if (savedPath != null) {
        setState(() {
          final updatedEvent = event.copyWith(
            attachmentIds: [...event.attachmentIds, savedPath],
          );
          final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
          if (idx != -1) _enhancedEvents[idx] = updatedEvent;
        });
        
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save file'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error processing file: $e'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _addHyperlink(EnhancedEventBlock event) {
    String linkUrl = '';
    String linkTitle = '';
    final formKey = GlobalKey<FormState>();
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Link to ${event.subject}'),
        content: Container(
          width: isMobile ? double.infinity : 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Link Title',
                    hintText: 'e.g., Online Worksheet, Video Tutorial',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Link title is required';
                    }
                    if (value.trim().length > 50) {
                      return 'Title must be 50 characters or less';
                    }
                    return null;
                  },
                  onChanged: (value) => linkTitle = value,
                  autofocus: true,
                  maxLength: 50,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Link URL',
                    hintText: 'https://example.com/resource',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Link URL is required';
                    }
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                  onChanged: (value) => linkUrl = value,
                  maxLength: 500,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                setState(() {
                  // Add the link to the event's hyperlinks
                  final updatedEvent = event.copyWith(
                    hyperlinks: [...event.hyperlinks, '$linkTitle|$linkUrl'],
                  );
                  final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
                  if (idx != -1) _enhancedEvents[idx] = updatedEvent;
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add Link'),
          ),
        ],
      ),
    );
  }

  void _removePicture(EnhancedEventBlock event, String imagePath) {
    setState(() {
      final updatedEvent = event.copyWith(
        attachmentIds: event.attachmentIds.where((path) => path != imagePath).toList(),
      );
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
    });
    
    // Delete the file from local storage
    ImageService.deleteLocalImage(imagePath);
  }

  void _removeHyperlink(EnhancedEventBlock event, String linkData) {
    setState(() {
      final updatedEvent = event.copyWith(
        hyperlinks: event.hyperlinks.where((link) => link != linkData).toList(),
      );
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
    });
  }

  void _viewImage(String imagePath) {
    final file = File(imagePath);
    if (file.existsSync()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('View Image'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: () {
                    // TODO: Implement image sharing
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Image sharing not yet implemented')),
                    );
                  },
                ),
              ],
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Unable to load image',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Image not found: ${path.basename(imagePath)}'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}
