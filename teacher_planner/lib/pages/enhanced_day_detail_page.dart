// lib/pages/enhanced_day_detail_page.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../models/event_block.dart';
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

  // events and selections
  late List<EnhancedEventBlock> _enhancedEvents;
  List<String> _selectedOutcomeCodes = [];
  List<CurriculumOutcome> _selectedOutcomes = [];
  bool _showCurriculumSidebar = true;

  final StorageService _storageService =
      StorageServiceFactory.create(StorageProvider.supabase);

  @override
  void initState() {
    super.initState();
    // Initialize enhanced events from raw EventBlock data
    _enhancedEvents = widget.events.map((e) {
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
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSlots = endHour - startHour;
    final contentW = MediaQuery.of(context).size.width * 0.6 - padding * 2;
    final styleTitle = theme.textTheme.titleMedium!;
    final styleSubtitle = theme.textTheme.bodyMedium!;
    final styleBody = theme.textTheme.bodySmall!;

    // compute timeline height
    double timelineH = totalSlots * hourHeight;
    for (var ev in _enhancedEvents) {
      timelineH = _max(timelineH, (ev.startHour - startHour) * hourHeight +
          _calculateEventHeight(ev, contentW, styleTitle, styleSubtitle, styleBody));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.day} – Daily Detail'),
        actions: [
          IconButton(
            icon: Icon(
                _showCurriculumSidebar ? Icons.chevron_left : Icons.chevron_right),
            onPressed: () => setState(() => _showCurriculumSidebar = !_showCurriculumSidebar),
          ),
        ],
      ),
      body: Row(
        children: [
          if (_showCurriculumSidebar)
            CurriculumSidebar(
              width: 300,
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Timeline
                  Container(
                    height: timelineH,
                    child: Row(
                      children: [
                        // Hour labels
                        Column(
                          children: [
                            for (int i = startHour; i <= endHour; i++)
                              Container(
                                height: hourHeight,
                                alignment: Alignment.topCenter,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    '${i.toString().padLeft(2,'0')}:00',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        // Events
                        Expanded(
                          child: Stack(
                            children: [
                              // Grid lines
                              for (int i = 0; i <= totalSlots; i++)
                                Positioned(
                                  top: i * hourHeight,
                                  left: 0,
                                  right: 0,
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              // Event cards
                              for (var ev in _enhancedEvents)
                                Positioned(
                                  top: (ev.startHour - startHour) * hourHeight,
                                  left: 8,
                                  right: 8,
                                  height: _calculateEventHeight(
                                      ev, contentW, styleTitle, styleSubtitle, styleBody),
                                  child: GestureDetector(
                                    onTap: () => _editEvent(ev),
                                    child: _buildEnhancedEventCard(ev, theme),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // (Reflection and attachments would go here)
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }

  double _max(double a, double b) => a > b ? a : b;

  double _calculateEventHeight(
    EnhancedEventBlock ev,
    double width,
    TextStyle st, TextStyle ss, TextStyle sb,
  ) {
    double h = padding * 2;
    h += _measureTextHeight(ev.subject, width, st);
   h += _measureTextHeight(ev.subtitle, width, ss);
    for (var line in ev.body.split('\n')) {
      h += _measureTextHeight(line, width, sb);
    }
    return h + 20;
  }

  double _measureTextHeight(String text, double maxWidth, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    return tp.height;
  }

  Widget _buildEnhancedEventCard(EnhancedEventBlock ev, ThemeData theme) {
    return Container(
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
        ],
      ),
    );
  }

  Future<void> _editEvent(EnhancedEventBlock event) async {
    final data = await CurriculumService.getOutcomesByIds(_selectedOutcomeCodes);
    // 2) convert to your model
    final availableOutcomes = data.map((d) => CurriculumOutcome(
      id: d.id,
      code: d.code ?? '',
      description: d.description ?? '',
      elaboration: d.elaboration ?? '',
    )).toList();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => EnhancedEventEditor(
        event: event,
        availableOutcomes: availableOutcomes,
        onEventUpdated: (u) {
          setState(() {
            final idx = _enhancedEvents.indexWhere((e) => e.id == u.id);
            if (idx != -1) _enhancedEvents[idx] = u;
          });
        },
      ),
    );
  }
}
