// lib/pages/enhanced_day_detail_page.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/curriculum_service.dart';
import '../services/storage_service.dart';
import '../widgets/curriculum_sidebar.dart';
import '../widgets/attachment_manager.dart';
import '../widgets/enhanced_event_editor.dart';
import 'week_view.dart';

class EnhancedDayDetailPage extends StatefulWidget {
  final String day;
  final List<EventBlock> events;
  
  const EnhancedDayDetailPage({
    Key? key, 
    required this.day, 
    required this.events,
  }) : super(key: key);

  @override
  _EnhancedDayDetailPageState createState() => _EnhancedDayDetailPageState();
}

class _EnhancedDayDetailPageState extends State<EnhancedDayDetailPage> {
  static const int startHour = 6, endHour = 18;
  static const double hourHeight = 80.0, padding = 12.0;
  
  // State variables
  List<EnhancedEventBlock> _enhancedEvents = [];
  List<String> _selectedOutcomeIds = [];
  String _reflectionContent = '';
  List<Attachment> _reflectionAttachments = [];
  bool _showCurriculumSidebar = true;
  final CurriculumService _curriculumService = CurriculumService();
  final StorageService _storageService = StorageServiceFactory.create(StorageProvider.supabase);

  @override
  void initState() {
    super.initState();
    _initializeEnhancedEvents();
    _loadReflectionData();
  }

  void _initializeEnhancedEvents() {
    _enhancedEvents = widget.events.map((event) => EnhancedEventBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      day: event.day,
      subject: event.subject,
      subtitle: event.subtitle,
      body: event.body,
      color: event.color,
      startHour: event.startHour,
      startMinute: event.startMinute,
      finishHour: event.finishHour,
      finishMinute: event.finishMinute,
      widthFactor: event.widthFactor,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();
  }

  Future<void> _loadReflectionData() async {
    // TODO: Load reflection data from database
    // For now, using mock data
    setState(() {
      _reflectionContent = '';
      _reflectionAttachments = [];
    });
  }

  Future<void> _saveReflectionData() async {
    // TODO: Save reflection data to database
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reflection saved successfully')),
    );
  }

  double _measureTextHeight(String text, double maxWidth, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    return tp.height;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSlots = endHour - startHour;
    final contentW = MediaQuery.of(context).size.width * 0.6 - padding * 2;
    final styleTitle = theme.textTheme.titleMedium!;
    final styleSubtitle = theme.textTheme.bodyMedium!;
    final styleBody = theme.textTheme.bodySmall!;

    // Calculate timeline height
    double timelineH = totalSlots * hourHeight;
    for (var ev in _enhancedEvents) {
      double h = padding * 2;
      h += _measureTextHeight(ev.subject, contentW, styleTitle);
      h += _measureTextHeight(ev.subtitle, contentW, styleSubtitle);
      for (var line in ev.body.split('\n')) {
        h += _measureTextHeight(line, contentW, styleBody);
      }
      h += (ev.body.split('\n').length + 1) * 4;
      
      // Add space for attachments and curriculum outcomes
      if (ev.attachmentIds.isNotEmpty) h += 40;
      if (ev.curriculumOutcomeIds.isNotEmpty) h += 30;

      final bottom = (ev.startHour - startHour) * hourHeight + h;
      if (bottom > timelineH) timelineH = bottom;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day} - Daily Detail'),
        actions: [
          IconButton(
            icon: Icon(_showCurriculumSidebar ? Icons.chevron_left : Icons.chevron_right),
            onPressed: () {
              setState(() {
                _showCurriculumSidebar = !_showCurriculumSidebar;
              });
            },
            tooltip: _showCurriculumSidebar ? 'Hide Curriculum' : 'Show Curriculum',
          ),
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveReflectionData,
            tooltip: 'Save Reflection',
          ),
        ],
      ),
      body: Row(
        children: [
          // Curriculum Sidebar
          if (_showCurriculumSidebar)
            CurriculumSidebar(
              selectedOutcomeIds: _selectedOutcomeIds,
              onOutcomesChanged: (outcomeIds) {
                setState(() {
                  _selectedOutcomeIds = outcomeIds;
                });
              },
              width: 300,
            ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Timeline Section
                  Container(
                    height: timelineH,
                    child: Row(
                      children: [
                        // Time Labels
                        Container(
                          width: 60,
                          child: Column(
                            children: [
                              for (var i = startHour; i <= endHour; i++)
                                Container(
                                  height: hourHeight,
                                  alignment: Alignment.topCenter,
                                  child: Padding(
                                    padding: EdgeInsets.only(top: 8),
                                    child: Text(
                                      '${i.toString().padLeft(2, '0')}:00',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // Events Timeline
                        Expanded(
                          child: Stack(
                            children: [
                              // Grid lines
                              for (var i = 0; i <= totalSlots; i++)
                                Positioned(
                                  top: i * hourHeight,
                                  left: 0,
                                  right: 0,
                                  child: Divider(color: Colors.grey.shade300),
                                ),

                              // Events
                              for (var ev in _enhancedEvents)
                                Positioned(
                                  top: (ev.startHour - startHour) * hourHeight,
                                  left: 8,
                                  right: 8,
                                  height: _calculateEventHeight(ev, contentW, styleTitle, styleSubtitle, styleBody),
                                  child: _buildEnhancedEventCard(ev, theme),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Reflection Section
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: 300,
                    ),
                    margin: EdgeInsets.all(8),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.edit_note, color: theme.primaryColor),
                                SizedBox(width: 8),
                                Text(
                                  'Daily Reflection',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: _reflectionContent),
                                onChanged: (value) {
                                  setState(() {
                                    _reflectionContent = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Write your daily reflection here...',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                maxLines: null,
                                expands: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Reflection Attachments
                  Container(
                    constraints: BoxConstraints(
                      minHeight: 120,
                      maxHeight: 200,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Reflection Attachments',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Expanded(
                              child: AttachmentManager(
                                attachments: _reflectionAttachments,
                                onAttachmentsChanged: (attachments) {
                                  setState(() {
                                    _reflectionAttachments = attachments;
                                  });
                                },
                                folder: 'reflections/${widget.day}',
                                showUploadButton: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom padding for floating action button
                  SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        child: Icon(Icons.add),
        tooltip: 'Add New Event',
      ),
    );
  }

  Widget _buildEnhancedEventCard(EnhancedEventBlock ev, ThemeData theme) {
    return GestureDetector(
      onTap: () => _editEvent(ev),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: ev.color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time display
            Row(
              children: [
                Icon(Icons.schedule, size: 12, color: Colors.white70),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${ev.startHour.toString().padLeft(2, '0')}:${ev.startMinute.toString().padLeft(2, '0')} - ${ev.finishHour.toString().padLeft(2, '0')}:${ev.finishMinute.toString().padLeft(2, '0')}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (ev.attachmentIds.isNotEmpty)
                  Icon(Icons.attach_file, size: 12, color: Colors.white70),
                if (ev.curriculumOutcomeIds.isNotEmpty)
                  Icon(Icons.school, size: 12, color: Colors.white70),
                if (ev.hyperlinks.isNotEmpty)
                  Icon(Icons.link, size: 12, color: Colors.white70),
              ],
            ),
            SizedBox(height: 4),
            
            // Title
            Text(
              ev.subject,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Subtitle
            if (ev.subtitle.isNotEmpty) ...[
              SizedBox(height: 2),
              Text(
                ev.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Body
            if (ev.body.isNotEmpty) ...[
              SizedBox(height: 4),
              Text(
                ev.body,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            
            // Indicators
            if (ev.attachmentIds.isNotEmpty || ev.curriculumOutcomeIds.isNotEmpty || ev.hyperlinks.isNotEmpty) ...[
              SizedBox(height: 8),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  if (ev.attachmentIds.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${ev.attachmentIds.length} files',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  if (ev.curriculumOutcomeIds.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${ev.curriculumOutcomeIds.length} outcomes',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  if (ev.hyperlinks.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${ev.hyperlinks.length} links',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _calculateEventHeight(EnhancedEventBlock ev, double contentW, TextStyle styleTitle, TextStyle styleSubtitle, TextStyle styleBody) {
    double h = padding * 2;
    h += _measureTextHeight(ev.subject, contentW, styleTitle);
    h += _measureTextHeight(ev.subtitle, contentW, styleSubtitle);
    for (var line in ev.body.split('\n')) {
      h += _measureTextHeight(line, contentW, styleBody);
    }
    h += (ev.body.split('\n').length + 1) * 4;
    
    // Add space for indicators
    if (ev.attachmentIds.isNotEmpty || ev.curriculumOutcomeIds.isNotEmpty || ev.hyperlinks.isNotEmpty) {
      h += 20;
    }
    
    return h;
  }

  void _editEvent(EnhancedEventBlock event) {
    final availableOutcomes = _curriculumService.getSelectedOutcomes(_selectedOutcomeIds);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EnhancedEventEditor(
        event: event,
        onEventUpdated: (updatedEvent) {
          setState(() {
            final index = _enhancedEvents.indexWhere((e) => e.id == updatedEvent.id);
            if (index != -1) {
              _enhancedEvents[index] = updatedEvent;
            }
          });
        },
        availableOutcomes: availableOutcomes,
      ),
    );
  }

  void _addNewEvent() {
    // TODO: Implement add new event functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add new event functionality will be implemented')),
    );
  }
} 