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

  List<EnhancedEventBlock> _enhancedEvents = [];
  List<String> _selectedOutcomeIds = [];
  bool _showCurriculumSidebar = true;
  final StorageService _storageService =
      StorageServiceFactory.create(StorageProvider.supabase);

  @override
  void initState() {
    super.initState();
    _enhancedEvents = widget.events.map((e) => EnhancedEventBlock(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSlots = endHour - startHour;
    final contentW = MediaQuery.of(context).size.width * 0.6 - padding * 2;
    final styleTitle = theme.textTheme.titleMedium!;
    final styleSubtitle = theme.textTheme.bodyMedium!;
    final styleBody = theme.textTheme.bodySmall!;

    double timelineH = totalSlots * hourHeight;
    for (var ev in _enhancedEvents) {
      final h = _calculateEventHeight(ev, contentW, styleTitle, styleSubtitle, styleBody);
      final bottom = (ev.startHour - startHour) * hourHeight + h;
      if (bottom > timelineH) timelineH = bottom;
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
              selectedOutcomeIds: _selectedOutcomeIds,
              onOutcomesChanged: (ids) => setState(() => _selectedOutcomeIds = ids),
              width: 400,
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
                        // Hours column
                        Container(
                          width: 60,
                          child: Column(
                            children: [
                              for (int i = startHour; i <= endHour; i++)
                                Container(
                                  height: hourHeight,
                                  alignment: Alignment.topCenter,
                                  child: Text(
                                    '${i.toString().padLeft(2,'0')}:00',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        // Events stack
                        Expanded(
                          child: Stack(
                            children: [
                              // grid lines
                              for (int i = 0; i <= totalSlots; i++)
                                Positioned(
                                  top: i * hourHeight,
                                  left: 0,
                                  right: 0,
                                  child: Divider(color: Colors.grey.shade300),
                                ),
                              // event cards
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
                  // (Reflection and attachments go here…)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedEventCard(EnhancedEventBlock ev, ThemeData theme) {
    // Your card UI, e.g.:
    return Card(
      color: ev.color,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ev.subject, style: theme.textTheme.titleMedium?.copyWith(color: Colors.white)),
            if (ev.subtitle.isNotEmpty)
              Text(ev.subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Future<void> _editEvent(EnhancedEventBlock event) async {
    // 1) load the raw data
    final data = await CurriculumService.getOutcomesByIds(_selectedOutcomeIds);

    // 2) convert to your model
    final availableOutcomes = data.map((d) => CurriculumOutcome(
      id: d.id,
      code: d.code ?? '',
      description: d.description ?? '',
      elaboration: d.elaboration ?? '',
    )).toList();

    // 3) show editor
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

  double _calculateEventHeight(
    EnhancedEventBlock ev,
    double contentW,
    TextStyle st, TextStyle ss, TextStyle sb,
  ) {
    // identical to before…
    double h = padding * 2;
    h += _measureTextHeight(ev.subject, contentW, st);
    h += _measureTextHeight(ev.subtitle, contentW, ss);
    for (var line in ev.body.split('\n')) {
      h += _measureTextHeight(line, contentW, sb);
    }
    return h + 20;
  }

  double _measureTextHeight(String text, double maxWidth, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: null,
    )..layout(maxWidth: maxWidth);
    return tp.height;
  }
}
