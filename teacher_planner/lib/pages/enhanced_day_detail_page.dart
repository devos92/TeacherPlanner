// lib/pages/enhanced_day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/curriculum_models.dart';
import '../models/event_block.dart';
import '../models/weekly_plan_data.dart';
import '../services/pdf_service.dart';
import '../services/image_service.dart';
import '../widgets/curriculum_sidebar.dart';
import '../widgets/lesson_card_widget.dart';
import '../widgets/lesson_details_section.dart';
import '../widgets/teacher_notes_section.dart';
import '../widgets/resource_image_item.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import '../config/app_fonts.dart';

class EnhancedDayDetailPage extends StatefulWidget {
  final String day;
  final List<EventBlock> events;
  final List<WeeklyPlanData>? weeklyPlanData;
  final int dayIndex;
  final Function(List<WeeklyPlanData>)? onPlanDataChanged;

  const EnhancedDayDetailPage({
    Key? key,
    required this.day,
    required this.events,
    this.weeklyPlanData,
    required this.dayIndex,
    this.onPlanDataChanged,
  }) : super(key: key);

  @override
  _EnhancedDayDetailPageState createState() => _EnhancedDayDetailPageState();
}

class _EnhancedDayDetailPageState extends State<EnhancedDayDetailPage> {
  late List<EnhancedEventBlock> _enhancedEvents;
  late List<WeeklyPlanData> _localWeeklyPlanData;
  List<String> _selectedOutcomeCodes = [];
  List<CurriculumOutcome> _selectedOutcomes = [];
  bool _showCurriculumSidebar = true;
  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _localWeeklyPlanData = widget.weeklyPlanData != null 
        ? List.from(widget.weeklyPlanData!) 
        : [];
    _loadLessonsFromWeeklyPlan();
  }

  void _loadLessonsFromWeeklyPlan() {
    List<EnhancedEventBlock> lessons = [];

    if (_localWeeklyPlanData.isNotEmpty) {
      final dayLessons = _localWeeklyPlanData.where((data) => 
        data.dayIndex == widget.dayIndex && data.isLesson
      ).toList();

      dayLessons.sort((a, b) => a.periodIndex.compareTo(b.periodIndex));

      for (final lesson in dayLessons) {
        lessons.add(EnhancedEventBlock(
          id: lesson.lessonId.isNotEmpty ? lesson.lessonId : UniqueKey().toString(),
          day: widget.day,
          subject: lesson.subject.isNotEmpty ? lesson.subject : 'Lesson ${lesson.periodIndex + 1}',
          subtitle: 'Period ${lesson.periodIndex + 1}',
          body: lesson.content.isNotEmpty ? lesson.content : 'No description available',
          notes: lesson.notes,
          color: lesson.lessonColor ?? _getColorForPeriod(lesson.periodIndex),
          startHour: 8 + lesson.periodIndex,
          startMinute: 0,
          finishHour: 9 + lesson.periodIndex,
          finishMinute: 0,
          periodIndex: lesson.periodIndex,
          widthFactor: 1.0,
          attachmentIds: [],
          curriculumOutcomeIds: [],
          hyperlinks: [],
          createdAt: lesson.date ?? DateTime.now(),
          updatedAt: DateTime.now(),
        ));
      }
    }

    if (lessons.isEmpty && widget.events.isNotEmpty) {
      lessons = widget.events.map((e) => EnhancedEventBlock(
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
      )).toList();
    }

    setState(() {
      _enhancedEvents = lessons;
    });
  }

  void _saveChangesToWeeklyPlan() {
    if (widget.onPlanDataChanged != null) {
      widget.onPlanDataChanged!(_localWeeklyPlanData);
    }
  }

  Color _getColorForPeriod(int periodIndex) {
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
            onPressed: _isGeneratingPdf ? null : _printDailyWorkPad,
            tooltip: 'Print Daily Work Pad',
          ),
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
            onPressed: _isGeneratingPdf ? null : _shareDailyWorkPad,
            tooltip: 'Share Daily Work Pad',
          ),
          if (!isMobile)
            IconButton(
              icon: Icon(_showCurriculumSidebar ? Icons.chevron_left : Icons.chevron_right),
              onPressed: () => setState(() => _showCurriculumSidebar = !_showCurriculumSidebar),
              tooltip: 'Toggle Curriculum Sidebar',
            ),
        ],
      ),
      body: Row(
        children: [
          if (_showCurriculumSidebar && !isMobile)
            SizedBox(
              width: isDesktop ? 350 : 300,
              child: CurriculumSidebar(
                width: isDesktop ? 350 : 300,
                onSelectionChanged: (outcomes) {
                  final newOutcomes = outcomes.map((outcome) => CurriculumOutcome(
                    id: outcome.id,
                    code: outcome.code ?? '',
                    description: outcome.description ?? '',
                    elaboration: outcome.elaboration ?? '',
                  )).toList();
                  
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
                  colors: [Colors.grey.shade50, Colors.grey.shade100],
                ),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 16.0 : isTablet ? 20.0 : 24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDayHeader(theme, isMobile),
                      if (_enhancedEvents.isNotEmpty) ...[
                        ..._enhancedEvents.map((event) => _buildLessonCard(event, isTablet)).toList(),
                      ] else ...[
                        _buildEmptyState(theme, isMobile),
                      ],
                      _buildAddLessonButton(theme, isMobile, isTablet, isDesktop),
                      SizedBox(height: 100),
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

  Widget _buildDayHeader(ThemeData theme, bool isMobile) {
    return Container(
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
    );
  }

  Widget _buildLessonCard(EnhancedEventBlock event, bool isTablet) {
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
            border: Border.all(color: event.color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: Offset(0, 4)),
              BoxShadow(color: event.color.withOpacity(0.08), blurRadius: 24, offset: Offset(0, 8)),
            ],
          ),
          child: Column(
            children: [
              _buildLessonHeader(event, isTablet),
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LessonDetailsSection(
                      event: event,
                      onChanged: (value) => _updateLessonBody(event, value),
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20),
                    TeacherNotesSection(
                      event: event,
                      onChanged: (value) => _updateLessonNotes(event, value),
                      isTablet: isTablet,
                    ),
                    SizedBox(height: 20),
                    _buildResourcesSection(event, isTablet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonHeader(EnhancedEventBlock event, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 16 : 12),
          topRight: Radius.circular(isTablet ? 16 : 12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              border: Border.all(color: event.color.withOpacity(0.3), width: 1),
            ),
            child: Text(
              'Period ${event.periodIndex + 1}',
              style: AppFonts.labelMedium.copyWith(
                color: event.color,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              event.headerText?.isNotEmpty == true ? event.headerText! : event.subject,
              style: AppFonts.lessonTitle.copyWith(
                fontSize: isTablet ? 22 : 18,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesSection(EnhancedEventBlock event, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file_outlined, color: event.color, size: 20),
            SizedBox(width: 8),
            Text(
              'Resources',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: event.color,
              ),
            ),
            Spacer(),
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
        SizedBox(height: 12),
        if (event.attachmentIds.isNotEmpty || event.hyperlinks.isNotEmpty) ...[
          if (event.attachmentIds.isNotEmpty) ...[
            Text('Pictures', style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.attachmentIds.map((imagePath) => ResourceImageItem(
                imagePath: imagePath,
                event: event,
                onView: _viewImage,
                onRemove: (path) => _removePicture(event, path),
                isTablet: isTablet,
              )).toList(),
            ),
            SizedBox(height: 16),
          ],
          if (event.hyperlinks.isNotEmpty) ...[
            Text('Links', style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8),
            ...event.hyperlinks.map((linkData) => _buildLinkItem(linkData, event, isTablet)).toList(),
          ],
        ] else ...[
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey.shade600, size: isTablet ? 16 : 14),
                SizedBox(width: 6),
                Text(
                  'No resources added yet. Click "Picture" or "Link" to add.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: isTablet ? 11 : 10),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLinkItem(String linkData, EnhancedEventBlock event, bool isTablet) {
    final parts = linkData.split('|');
    final linkTitle = parts.length > 0 ? parts[0] : 'Link';
    final linkUrl = parts.length > 1 ? parts[1] : linkData;
    
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(isTablet ? 8 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: event.color, size: isTablet ? 14 : 12),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  linkTitle,
                  style: TextStyle(fontWeight: FontWeight.w600, color: event.color, fontSize: isTablet ? 10 : 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => _removeHyperlink(event, linkData),
                icon: Icon(Icons.close, size: isTablet ? 12 : 10, color: Colors.red.shade400),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: isTablet ? 16 : 14, minHeight: isTablet ? 16 : 14),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            linkUrl,
            style: TextStyle(color: Colors.grey.shade600, fontSize: isTablet ? 9 : 8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 30 : 40),
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(Icons.school_outlined, size: isMobile ? 48 : 64, color: Colors.grey.shade400),
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
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAddLessonButton(ThemeData theme, bool isMobile, bool isTablet, bool isDesktop) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton.icon(
        onPressed: _addNewLesson,
        icon: Icon(Icons.add, size: isMobile ? 20 : 24),
        label: Text(
          'Add New Lesson',
          style: (isMobile ? theme.textTheme.titleSmall : theme.textTheme.titleMedium)?.copyWith(fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 4,
        ),
      ),
    );
  }

  // Event handlers
  void _updateLessonBody(EnhancedEventBlock event, String value) {
    setState(() {
      final updatedEvent = event.copyWith(body: value, updatedAt: DateTime.now());
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
      
      final planIdx = _localWeeklyPlanData.indexWhere((data) => 
        data.lessonId == event.id && data.dayIndex == widget.dayIndex
      );
      if (planIdx != -1) {
        _localWeeklyPlanData[planIdx] = _localWeeklyPlanData[planIdx].copyWith(content: value);
        _saveChangesToWeeklyPlan();
      }
    });
  }

  void _updateLessonNotes(EnhancedEventBlock event, String value) {
    setState(() {
      final updatedEvent = event.copyWith(notes: value, updatedAt: DateTime.now());
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
      
      final planIdx = _localWeeklyPlanData.indexWhere((data) => 
        data.lessonId == event.id && data.dayIndex == widget.dayIndex
      );
      if (planIdx != -1) {
        _localWeeklyPlanData[planIdx] = _localWeeklyPlanData[planIdx].copyWith(notes: value);
        _saveChangesToWeeklyPlan();
      }
    });
  }

  void _addPicture(EnhancedEventBlock event) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Picture to ${event.subject}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(leading: Icon(Icons.camera_alt), title: Text('Take Photo'), onTap: () => Navigator.pop(context, ImageSource.camera)),
            ListTile(leading: Icon(Icons.photo_library), title: Text('Choose from Gallery'), onTap: () => Navigator.pop(context, ImageSource.gallery)),
            ListTile(leading: Icon(Icons.folder), title: Text('Choose File'), onTap: () => Navigator.pop(context, null)),
          ],
        ),
      ),
    );

    if (source == null) {
      final file = await ImageService.pickAnyFile();
      if (file != null) await _processSelectedFile(event, file);
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
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Processing file...')],
          ),
        ),
      );

      final savedPath = await ImageService.saveImageToLocal(file);
      
      if (savedPath != null) {
        setState(() {
          final updatedEvent = event.copyWith(attachmentIds: [...event.attachmentIds, savedPath]);
          final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
          if (idx != -1) _enhancedEvents[idx] = updatedEvent;
        });
        
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('File added successfully!')));
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save file')));
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error processing file: $e')));
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
                  decoration: InputDecoration(labelText: 'Link Title', hintText: 'e.g., Online Worksheet, Video Tutorial', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Link title is required';
                    if (value.trim().length > 50) return 'Title must be 50 characters or less';
                    return null;
                  },
                  onChanged: (value) => linkTitle = value,
                  autofocus: true,
                  maxLength: 50,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Link URL', hintText: 'https://example.com/resource', border: OutlineInputBorder()),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Link URL is required';
                    final uri = Uri.tryParse(value.trim());
                    if (uri == null || !uri.hasAbsolutePath) return 'Please enter a valid URL';
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState?.validate() == true) {
                setState(() {
                  final updatedEvent = event.copyWith(hyperlinks: [...event.hyperlinks, '$linkTitle|$linkUrl']);
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
      final updatedEvent = event.copyWith(attachmentIds: event.attachmentIds.where((path) => path != imagePath).toList());
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
    });
    ImageService.deleteLocalImage(imagePath);
  }

  void _removeHyperlink(EnhancedEventBlock event, String linkData) {
    setState(() {
      final updatedEvent = event.copyWith(hyperlinks: event.hyperlinks.where((link) => link != linkData).toList());
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
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image sharing not yet implemented'))),
                ),
              ],
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.file(
                  file,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 64, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text('Unable to load image', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image not found: ${path.basename(imagePath)}')));
    }
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
                  decoration: InputDecoration(labelText: 'Subject *', hintText: 'e.g., Mathematics, English, Science', border: OutlineInputBorder()),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Subject is required' : null,
                  onChanged: (value) => subject = value,
                  autofocus: true,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Subtitle', hintText: 'e.g., Period 1, Morning Session', border: OutlineInputBorder()),
                  onChanged: (value) => subtitle = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Lesson Details', hintText: 'Enter lesson description, activities, notes...', border: OutlineInputBorder(), alignLabelWithHint: true),
                  onChanged: (value) => content = value,
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
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
                    color: _getColorForPeriod(_enhancedEvents.length),
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
    setState(() => _isGeneratingPdf = true);
    
    try {
      final pdfFile = await PdfService.generateDailyWorkPadPdf(
        day: widget.day,
        lessons: _enhancedEvents,
        teacherName: 'Teacher Name',
      );
      
      if (pdfFile != null) {
        await PdfService.printPdf(pdfFile);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF generated successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating PDF: $e')));
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }

  void _shareDailyWorkPad() async {
    setState(() => _isGeneratingPdf = true);
    
    try {
      final pdfFile = await PdfService.generateDailyWorkPadPdf(
        day: widget.day,
        lessons: _enhancedEvents,
        teacherName: 'Teacher Name',
      );
      
      if (pdfFile != null) {
        await PdfService.sharePdf(pdfFile);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF shared successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to generate PDF')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error sharing PDF: $e')));
    } finally {
      setState(() => _isGeneratingPdf = false);
    }
  }
}
