/// lib/pages/week_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'add_event_page.dart';
import 'lesson_detail_page.dart';
import 'dart:math';

/// Mutable event model to support resizing and width adjustment
class EventBlock {
  String day;
  String subject;
  Color color;
  int startHour;
  int duration; // in hours
  double widthFactor; // fraction of column width (0.0 - 1.0)

  EventBlock({
    required this.day,
    required this.subject,
    required this.color,
    required this.startHour,
    required this.duration,
    this.widthFactor = 1.0,
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
  final int startHour = 6;
  final int endHour = 18;
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
            final aEnd = e.startHour + e.duration;
            final bStart = ev.startHour;
            final bEnd = ev.startHour + ev.duration;
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

  void _deleteEvent(EventBlock ev) {
    setState(() {
      events.remove(ev);
      _computeLayouts();
    });
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
              // Time labels
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
                            SizedBox(
                              height: headerH,
                              child: Center(
                                child: Text(
                                  day,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Stack(
                                children: [
                                  // Grid lines
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
                                  // Event boxes
                                  ...layouts.map((layout) {
                                    final e = layout.event;
                                    final baseW = colW / layout.totalCols;
                                    final barLeft = layout.colIndex * baseW;
                                    final top =
                                        (e.startHour - startHour) * slotH;
                                    final height = e.duration * slotH;
                                    return TransformableBox(
                                      rect: Rect.fromLTWH(
                                        barLeft,
                                        top,
                                        baseW * e.widthFactor,
                                        height,
                                      ),
                                      clampingRect:
                                          Offset.zero &
                                          Size(
                                            constraints.maxWidth,
                                            constraints.maxHeight,
                                          ),
                                      onChanged: (result, _) {
                                        setState(() {
                                          final r = result.rect;
                                          e.startHour =
                                              startHour +
                                              (r.top / slotH).round();
                                          e.duration = (r.height / slotH)
                                              .round();
                                          e.widthFactor = (r.width / baseW)
                                              .clamp(0.1, 1.0);
                                          _computeLayouts();
                                        });
                                      },
                                      contentBuilder: (context, rect, flip) {
                                        return Positioned(
                                          left: rect.left,
                                          top: rect.top,
                                          width: rect.width,
                                          height: rect.height,
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            LessonDetailPage(
                                                              event: e,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    margin:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 2,
                                                          vertical: 1,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: e.color,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            6,
                                                          ),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        e.subject,
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
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
                                        );
                                      },
                                    );
                                  }).toList(),
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
          final newEvent = await Navigator.push<EventBlock>(
            context,
            MaterialPageRoute(builder: (_) => AddEventPage()),
          );
          if (newEvent != null) {
            setState(() {
              events.add(newEvent);
              _computeLayouts();
            });
          }
        },
      ),
    );
  }
}
