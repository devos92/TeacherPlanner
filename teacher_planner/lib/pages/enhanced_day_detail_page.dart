// lib/pages/enhanced_day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_block.dart';
import '../models/weekly_plan_data.dart';
import '../services/day_detail_service.dart';
import '../widgets/curriculum_sidebar.dart';
import '../widgets/day_header_widget.dart';
import '../widgets/lesson_header_widget.dart';
import '../widgets/lesson_details_section.dart';
import '../widgets/teacher_notes_section.dart';
import '../widgets/resources_section_widget.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

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
    List<EnhancedEventBlock> lessons = DayDetailService.loadLessonsFromWeeklyPlan(
      _localWeeklyPlanData,
      widget.day,
      widget.dayIndex,
    );

    if (lessons.isEmpty && widget.events.isNotEmpty) {
      lessons = DayDetailService.convertEventsToLessons(widget.events, widget.day);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;
    final isDesktop = screenSize.width >= 900;

    return Scaffold(
      appBar: _buildAppBar(theme, isMobile),
      body: Row(
        children: [
          if (_showCurriculumSidebar && !isMobile)
            SizedBox(
              width: isDesktop ? 350 : 300,
              child: CurriculumSidebar(
                width: isDesktop ? 350 : 300,
                onSelectionChanged: _handleCurriculumSelection,
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
                      DayHeaderWidget(
                        day: widget.day,
                        lessonCount: _enhancedEvents.length,
                        isMobile: isMobile,
                      ),
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

  AppBar _buildAppBar(ThemeData theme, bool isMobile) {
    return AppBar(
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
              LessonHeaderWidget(event: event, isTablet: isTablet),
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
                    ResourcesSectionWidget(
                      event: event,
                      isTablet: isTablet,
                      onAddPicture: _addPicture,
                      onAddHyperlink: _addHyperlink,
                      onViewImage: _viewImage,
                      onRemovePicture: _removePicture,
                      onRemoveHyperlink: _removeHyperlink,
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
  void _handleCurriculumSelection(List<CurriculumData> outcomes) {
    // Process curriculum selection if needed in the future
    // For now, just handle the selection without storing the data
  }

  void _updateLessonBody(EnhancedEventBlock event, String value) {
    setState(() {
      final updatedEvent = DayDetailService.updateLessonBody(event, value);
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
      
      final planData = DayDetailService.findWeeklyPlanData(_localWeeklyPlanData, event.id, widget.dayIndex);
      if (planData != null) {
        _localWeeklyPlanData = DayDetailService.updateWeeklyPlanData(
          _localWeeklyPlanData,
          event.id,
          widget.dayIndex,
          value,
          planData.notes,
        );
        _saveChangesToWeeklyPlan();
      }
    });
  }

  void _updateLessonNotes(EnhancedEventBlock event, String value) {
    setState(() {
      final updatedEvent = DayDetailService.updateLessonNotes(event, value);
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
      
      final planData = DayDetailService.findWeeklyPlanData(_localWeeklyPlanData, event.id, widget.dayIndex);
      if (planData != null) {
        _localWeeklyPlanData = DayDetailService.updateWeeklyPlanData(
          _localWeeklyPlanData,
          event.id,
          widget.dayIndex,
          planData.content,
          value,
        );
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
      final imageFile = await DayDetailService.pickAnyFile();
      if (imageFile != null) await _processSelectedFile(event, imageFile);
      return;
    }

    final imageFile = await DayDetailService.pickImage(source);
    if (imageFile != null) {
      await _processSelectedFile(event, imageFile);
    }
  }

  Future<void> _processSelectedFile(EnhancedEventBlock event, XFile imageFile) async {
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

      final savedPath = await DayDetailService.saveImageToLocal(imageFile);
      
      if (savedPath != null) {
        setState(() {
          final updatedEvent = DayDetailService.addPictureToLesson(event, savedPath);
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
                  final updatedEvent = DayDetailService.addHyperlinkToLesson(event, linkTitle, linkUrl);
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

  void _removePicture(EnhancedEventBlock event, String imagePath) async {
    setState(() {
      final updatedEvent = DayDetailService.removePictureFromLesson(event, imagePath);
      final idx = _enhancedEvents.indexWhere((e) => e.id == event.id);
      if (idx != -1) _enhancedEvents[idx] = updatedEvent;
    });
    await DayDetailService.deleteLocalImage(imagePath);
  }

  void _removeHyperlink(EnhancedEventBlock event, String linkData) {
    setState(() {
      final updatedEvent = DayDetailService.removeHyperlinkFromLesson(event, linkData);
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
                  final newLesson = DayDetailService.createNewLesson(
                    day: widget.day,
                    subject: subject,
                    subtitle: subtitle,
                    content: content,
                    periodIndex: _enhancedEvents.length,
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
      final pdfFile = await DayDetailService.generateDailyWorkPadPdf(
        day: widget.day,
        lessons: _enhancedEvents,
        teacherName: 'Teacher Name',
      );
      
      if (pdfFile != null) {
        await DayDetailService.printPdf(pdfFile);
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
      final pdfFile = await DayDetailService.generateDailyWorkPadPdf(
        day: widget.day,
        lessons: _enhancedEvents,
        teacherName: 'Teacher Name',
      );
      
      if (pdfFile != null) {
        await DayDetailService.sharePdf(pdfFile);
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