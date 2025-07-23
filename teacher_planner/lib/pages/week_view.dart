/// lib/pages/week_view.dart

import 'package:flutter/material.dart';

import 'add_event_page.dart';
import 'lesson_detail_page.dart';
import 'day_detail_page.dart';
import 'event_detail_editor.dart';
import 'multi_select_event_page.dart';

/// Mutable event model to support resizing and width adjustment
class EventBlock {
  String day;
  String subject; // Title
  String subtitle; // Sub‑header
  String body; // our editable text
  Color color;
  int startHour;
  double widthFactor;
  int duration; // in hours

  EventBlock({
    required this.day,
    required this.subject,
    this.subtitle = '',
    this.body = '',
    required this.color,
    required this.startHour,
    this.widthFactor = 1.0,
    this.duration = 1,
  });
}

/// Layout info for overlapping events
class _EventLayout {
  final EventBlock event;
  final int colIndex;
  final int totalCols;

  _EventLayout({
    required this.event,
    required this.colIndex,
    required this.totalCols,
  });
}

class WeekView extends StatefulWidget {
  @override
  _WeekViewState createState() => _WeekViewState();
}

class _WeekViewState extends State<WeekView> {
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final int startHour = 6; // Floor time
  final int endHour = 18; // Ceiling time
  List<EventBlock> events = [];
  late Map<String, List<_EventLayout>> layoutsByDay;

  @override
  void initState() {
    super.initState();
    _computeLayouts();
  }

  void _computeLayouts() {
    layoutsByDay = {};
    for (var day in days) {
      final dayEvents = events.where((e) => e.day == day).toList()
        ..sort((a, b) => a.startHour.compareTo(b.startHour));
      List<List<EventBlock>> columns = [];

      for (var ev in dayEvents) {
        bool placed = false;
        for (var col in columns) {
          bool overlap = col.any((e) {
            final aStart = e.startHour;
            final aEnd = aStart + e.duration;
            final bStart = ev.startHour;
            final bEnd = bStart + ev.duration;
            return !(bEnd <= aStart || bStart >= aEnd);
          });
          if (!overlap) {
            col.add(ev);
            placed = true;
            break;
          }
        }
        if (!placed) columns.add([ev]);
      }

      final layouts = <_EventLayout>[];
      for (int i = 0; i < columns.length; i++) {
        for (var ev in columns[i]) {
          layouts.add(
            _EventLayout(event: ev, colIndex: i, totalCols: columns.length),
          );
        }
      }
      layoutsByDay[day] = layouts;
    }
  }

  void _deleteEvent(EventBlock event) {
    setState(() {
      events.remove(event);
      _computeLayouts();
    });
  }

  void _showEventPreview(EventBlock event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event.subject),
        content: Container(
          width: 400,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Day: ${event.day}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Time: ${event.startHour}:00 - ${event.startHour + event.duration}:00'),
              SizedBox(height: 16),
              Text(
                'Event Details:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.grey.shade50,
                  ),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      event.body.isNotEmpty ? event.body : 'No details available',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventDetailEditor(event: event),
                ),
              ).then((_) {
                setState(() {
                  _computeLayouts();
                });
              });
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hours = List.generate(endHour - startHour + 1, (i) => startHour + i);

    return Scaffold(
      appBar: AppBar(title: Text('Weekly Planner')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final timeLabelW = 60.0;
          final headerH = 40.0;
          final totalH = hours.length;
          final totalD = days.length;
          final slotH = (constraints.maxHeight - headerH) / totalH;
          final colW = (constraints.maxWidth - timeLabelW) / totalD;

          return Row(
            children: [
              // Time labels (non-scrollable)
              SizedBox(
                width: timeLabelW,
                height: constraints.maxHeight,
                child: ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: totalH,
                  itemBuilder: (_, idx) => SizedBox(
                    height: slotH,
                    child: Center(
                      child: Text(
                        '${hours[idx]}:00',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ),
              ),

              // Day columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: days.map((day) {
                      final layouts = layoutsByDay[day] ?? [];

                      return SizedBox(
                        width: colW,
                        child: Column(
                          children: [
                            // Day header, tappable to open DayDetailPage
                            SizedBox(
                              height: headerH,
                              child: InkWell(
                                onTap: () async {
                                  final todayEvents = events
                                      .where((e) => e.day == day)
                                      .toList();
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DayDetailPage(
                                        day: day,
                                        events: todayEvents,
                                      ),
                                    ),
                                  );
                                  setState(() {
                                    _computeLayouts();
                                  });
                                },
                                child: Center(
                                  child: Text(
                                    day,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // Events grid
                            Expanded(
                              child: Stack(
                                children: [
                                  // Grid background lines
                                  Column(
                                    children: List.generate(
                                      totalH,
                                      (_) => Container(
                                        height: slotH,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Draggable event boxes
                                  ...layouts.map((layout) {
                                    final e = layout.event;
                                    final baseW = colW / layout.totalCols;
                                    final left = layout.colIndex * baseW;
                                    final top =
                                        (e.startHour - startHour) * slotH;
                                    final height = e.duration * slotH;

                                    return Positioned(
                                      left: left,
                                      top: top,
                                      child: Draggable<EventBlock>(
                                        data: e,
                                        feedback: Material(
                                          elevation: 8,
                                          child: Container(
                                            width: baseW * e.widthFactor,
                                            height: height,
                                            decoration: BoxDecoration(
                                              color: e.color,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Center(
                                              child: Text(
                                                e.subject,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Container(
                                          width: baseW * e.widthFactor,
                                          height: height,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade300,
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                                          ),
                                          child: Center(
                                            child: Text(
                                              e.subject,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: GestureDetector(
                                          onTap: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => EventDetailEditor(event: e),
                                              ),
                                            );
                                            setState(() {
                                              _computeLayouts();
                                            });
                                          },
                                          onLongPress: () {
                                            _showEventPreview(e);
                                          },
                                          child: Container(
                                            width: baseW * e.widthFactor,
                                            height: height,
                                            margin: EdgeInsets.all(1),
                                            child: Stack(
                                              children: [
                                                // Box background + text
                                                Container(
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  padding: EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: e.color,
                                                    borderRadius:
                                                        BorderRadius.circular(6),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black.withOpacity(0.1),
                                                        blurRadius: 2,
                                                        offset: Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        e.subject,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium!
                                                            .copyWith(
                                                              color: Colors.white,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                      if (e.subtitle.isNotEmpty) ...[
                                                        SizedBox(height: 2),
                                                        Text(
                                                          e.subtitle,
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .copyWith(
                                                                color:
                                                                    Colors.white70,
                                                              ),
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                        ),
                                                      ],
                                                      SizedBox(height: 2),
                                                      Text(
                                                        '${e.startHour}:00 - ${e.startHour + e.duration}:00',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall!
                                                            .copyWith(
                                                              color:
                                                                  Colors.white70,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Delete button
                                                Positioned(
                                                  top: 2,
                                                  right: 2,
                                                  child: GestureDetector(
                                                    onTap: () => _deleteEvent(e),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Colors.white70,
                                                        shape: BoxShape.circle,
                                                      ),
                                                      child: Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),

                                  // Drop zones for each time slot
                                  ...List.generate(totalH, (hourIndex) {
                                    final hour = startHour + hourIndex;
                                    return Positioned(
                                      left: 0,
                                      top: hourIndex * slotH,
                                      child: DragTarget<EventBlock>(
                                        onWillAccept: (data) => true,
                                        onAccept: (event) {
                                          setState(() {
                                            // Update event time and day
                                            event.startHour = hour;
                                            event.day = day;
                                            _computeLayouts();
                                          });
                                        },
                                        builder: (context, candidateData, rejectedData) {
                                          return Container(
                                            width: colW,
                                            height: slotH,
                                            color: candidateData.isNotEmpty 
                                                ? Colors.blue.withOpacity(0.1)
                                                : Colors.transparent,
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          // Show choice between creation modes
          final choice = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Create Event'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.schedule),
                    title: Text('Same Time (Multi-Day)'),
                    subtitle: Text('Create events with same time across multiple days'),
                    onTap: () => Navigator.pop(context, 'multi_day'),
                  ),
                  ListTile(
                    leading: Icon(Icons.schedule_send),
                    title: Text('Different Times'),
                    subtitle: Text('Create events with different times for each day'),
                    onTap: () => Navigator.pop(context, 'multi_select'),
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

          if (choice == null) return;

          dynamic result;
          if (choice == 'multi_day') {
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddEventPage()),
            );
          } else if (choice == 'multi_select') {
            result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MultiSelectEventPage()),
            );
          }

          if (result != null) {
            setState(() {
              // Handle both single event and multiple events
              if (result is List<EventBlock>) {
                // Multiple events created
                events.addAll(result);
              } else if (result is EventBlock) {
                // Single event created
                events.add(result);
              }
              _computeLayouts();
            });
          }
        },
      ),
    );
  }
}
