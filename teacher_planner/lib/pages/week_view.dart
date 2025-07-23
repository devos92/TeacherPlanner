/// lib/pages/week_view.dart

import 'package:flutter/material.dart';

import 'add_event_page.dart';
import 'lesson_detail_page.dart';
import 'day_detail_page.dart';
import 'enhanced_day_detail_page.dart';
import 'multi_select_event_page.dart';

/// Mutable event model to support resizing and width adjustment
class EventBlock {
  String day;
  String subject; // Title
  String subtitle; // Sub‑header
  String body; // our editable text
  Color color;
  int startHour;
  int startMinute; // Add minute support
  int finishHour; // Finish hour instead of duration
  int finishMinute; // Finish minute instead of duration
  double widthFactor;

  EventBlock({
    required this.day,
    required this.subject,
    this.subtitle = '',
    this.body = '',
    required this.color,
    required this.startHour,
    this.startMinute = 0, // Default to 0 minutes
    required this.finishHour,
    this.finishMinute = 0, // Default to 0 minutes
    this.widthFactor = 1.0,
  });

  // Helper getter for duration in minutes (for calculations)
  int get durationMinutes {
    final duration = (finishHour * 60 + finishMinute) - (startHour * 60 + startMinute);
    return duration > 0 ? duration : 15; // Minimum 15 minutes if invalid
  }

  // Helper getter for duration in hours (for display)
  double get durationHours {
    return durationMinutes / 60.0;
  }

  // Setter to validate finish time
  void setFinishTime(int hour, int minute) {
    final startMinutes = startHour * 60 + startMinute;
    final finishMinutes = hour * 60 + minute;
    
    if (finishMinutes > startMinutes) {
      finishHour = hour;
      finishMinute = minute;
    } else {
      // If finish time is before start time, set it to start time + 1 hour
      final newFinishMinutes = startMinutes + 60;
      finishHour = newFinishMinutes ~/ 60;
      finishMinute = newFinishMinutes % 60;
    }
  }
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
        ..sort((a, b) => (a.startHour * 60 + a.startMinute).compareTo(b.startHour * 60 + b.startMinute));
      List<List<EventBlock>> columns = [];

      for (var ev in dayEvents) {
        bool placed = false;
        for (var col in columns) {
          bool overlap = col.any((e) {
            final aStart = e.startHour * 60 + e.startMinute;
            final aEnd = e.finishHour * 60 + e.finishMinute;
            final bStart = ev.startHour * 60 + ev.startMinute;
            final bEnd = ev.finishHour * 60 + ev.finishMinute;
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
              Text('Time: ${event.startHour.toString().padLeft(2, '0')}:${event.startMinute.toString().padLeft(2, '0')} - ${(event.finishHour).toString().padLeft(2, '0')}:${event.finishMinute.toString().padLeft(2, '0')}'),
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
              _showEventEditor(event);
            },
            child: Text('Edit'),
          ),
        ],
      ),
    );
  }

  void _showEventEditor(EventBlock event) {
    // Create controllers for the form fields
    final subjectController = TextEditingController(text: event.subject);
    final subtitleController = TextEditingController(text: event.subtitle);
    final bodyController = TextEditingController(text: event.body);
    
    // Store original values for validation
    int originalStartHour = event.startHour;
    int originalStartMinute = event.startMinute;
    int originalFinishHour = event.finishHour;
    int originalFinishMinute = event.finishMinute;
    Color originalColor = event.color;
    
    // Current values for the form
    int currentStartHour = event.startHour;
    int currentStartMinute = event.startMinute;
    int currentFinishHour = event.finishHour;
    int currentFinishMinute = event.finishMinute;
    Color currentColor = event.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit Event'),
            content: Container(
              width: 500,
              height: 600,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Event Info Section
                    Text('Event Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: subtitleController,
                      decoration: InputDecoration(
                        labelText: 'Subtitle (Optional)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 24),
                    
                    // Time Section
                    Text('Time', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: currentStartHour.toString(),
                            decoration: InputDecoration(
                              labelText: 'Start Hour (0-23)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final hour = int.tryParse(value);
                              if (hour != null && hour >= 0 && hour <= 23) {
                                currentStartHour = hour;
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: currentStartMinute.toString(),
                            decoration: InputDecoration(
                              labelText: 'Start Minute (0-59)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final minute = int.tryParse(value);
                              if (minute != null && minute >= 0 && minute <= 59) {
                                currentStartMinute = minute;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: currentFinishHour.toString(),
                            decoration: InputDecoration(
                              labelText: 'Finish Hour (0-23)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final hour = int.tryParse(value);
                              if (hour != null && hour >= 0 && hour <= 23) {
                                currentFinishHour = hour;
                              }
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: currentFinishMinute.toString(),
                            decoration: InputDecoration(
                              labelText: 'Finish Minute (0-59)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              final minute = int.tryParse(value);
                              if (minute != null && minute >= 0 && minute <= 59) {
                                currentFinishMinute = minute;
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    
                    // Color Section
                    Text('Color', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Colors.blue,
                        Colors.red,
                        Colors.green,
                        Colors.orange,
                        Colors.purple,
                        Colors.teal,
                        Colors.pink,
                        Colors.indigo,
                        Colors.amber,
                        Colors.cyan,
                      ].map((color) {
                        final isSelected = color == currentColor;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              currentColor = color;
                            });
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: color,
                              border: Border.all(
                                color: isSelected ? Colors.black : Colors.white,
                                width: isSelected ? 3 : 1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: Colors.white, size: 16)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 24),
                    
                    // Details Section
                    Text('Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Container(
                      height: 150,
                      child: TextFormField(
                        controller: bodyController,
                        decoration: InputDecoration(
                          labelText: 'Event Details',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                      ),
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
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Event'),
                      content: Text('Are you sure you want to delete "${event.subject}"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // Close confirmation dialog
                            Navigator.pop(context); // Close edit dialog
                            _deleteEvent(event);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text('Delete'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (subjectController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Title is required')),
                    );
                    return;
                  }

                  // Validate finish time is after start time
                  final startMinutes = currentStartHour * 60 + currentStartMinute;
                  final finishMinutes = currentFinishHour * 60 + currentFinishMinute;
                  
                  if (finishMinutes <= startMinutes) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Finish time must be after start time')),
                    );
                    return;
                  }

                  // Validate minimum duration of 15 minutes
                  final duration = finishMinutes - startMinutes;
                  if (duration < 15) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Events must be at least 15 minutes long')),
                    );
                    return;
                  }

                  // Update the event
                  setState(() {
                    event.subject = subjectController.text.trim();
                    event.subtitle = subtitleController.text.trim();
                    event.body = bodyController.text.trim();
                    event.startHour = currentStartHour;
                    event.startMinute = currentStartMinute;
                    event.finishHour = currentFinishHour;
                    event.finishMinute = currentFinishMinute;
                    event.color = currentColor;
                    _computeLayouts();
                  });

                  Navigator.pop(context);
                  
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Event updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: Text('Save Changes'),
              ),
            ],
          );
        },
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
                                      builder: (_) => EnhancedDayDetailPage(
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
                                  // Grid background lines - more precise grid
                                  Column(
                                    children: List.generate(
                                      totalH * 6, // 10-minute intervals (6 per hour)
                                      (index) => Container(
                                        height: slotH / 6, // 10-minute slots
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: index % 6 == 0 
                                                  ? Colors.grey.shade300 
                                                  : Colors.grey.shade100,
                                              width: index % 6 == 0 ? 1 : 0.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Drop zones for each time slot
                                  ...List.generate(
                                    totalH * 6, // 10-minute intervals
                                    (index) {
                                      final hour = startHour + (index ~/ 6);
                                      final minute = (index % 6) * 10;
                                      final slotTop = index * (slotH / 6);
                                      
                                      return Positioned(
                                        top: slotTop,
                                        left: 0,
                                        right: 0,
                                        child: DragTarget<EventBlock>(
                                          onWillAccept: (data) {
                                            // Check if the drop would be valid
                                            if (data == null) return false;
                                            
                                            // Check if the new time would be valid while keeping the same duration
                                            final newStartMinutes = hour * 60 + minute;
                                            final originalDuration = data.durationMinutes;
                                            final newFinishMinutes = newStartMinutes + originalDuration;
                                            
                                            return newStartMinutes >= startHour * 60 && 
                                                   newFinishMinutes <= endHour * 60 &&
                                                   originalDuration <= 480;
                                          },
                                          onAccept: (data) {
                                            // Update the event's day and time while keeping the same duration
                                            setState(() {
                                              final newStartMinutes = hour * 60 + minute;
                                              final originalDuration = data.durationMinutes;
                                              
                                              data.day = day;
                                              data.startHour = hour;
                                              data.startMinute = minute;
                                              
                                              // Calculate new finish time to maintain the same duration
                                              final newFinishMinutes = newStartMinutes + originalDuration;
                                              final newFinishHour = newFinishMinutes ~/ 60;
                                              final newFinishMinute = newFinishMinutes % 60;
                                              
                                              // Use the validated setter
                                              data.setFinishTime(newFinishHour, newFinishMinute);
                                              
                                              _computeLayouts();
                                            });
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            return Container(
                                              height: slotH / 6,
                                              decoration: BoxDecoration(
                                                color: candidateData.isNotEmpty 
                                                    ? Colors.blue.withOpacity(0.2)
                                                    : Colors.transparent,
                                                border: candidateData.isNotEmpty
                                                    ? Border.all(color: Colors.blue, width: 2)
                                                    : null,
                                              ),
                                              child: candidateData.isNotEmpty
                                                  ? Center(
                                                      child: Text(
                                                        '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}',
                                                        style: TextStyle(
                                                          color: Colors.blue.shade800,
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 10,
                                                        ),
                                                      ),
                                                    )
                                                  : null,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),

                                  // Draggable event boxes
                                  ...layouts.map((layout) {
                                    final e = layout.event;
                                    final baseW = colW / layout.totalCols;
                                    final left = layout.colIndex * baseW;
                                    
                                    // Calculate precise position based on start time
                                    final startMinutes = e.startHour * 60 + e.startMinute;
                                    final startSlotMinutes = startHour * 60;
                                    final top = ((startMinutes - startSlotMinutes) / 60.0) * slotH;
                                    
                                    // Calculate precise height based on duration with validation
                                    final durationMinutes = e.durationMinutes;
                                    final height = durationMinutes > 0 
                                        ? (durationMinutes / 60.0) * slotH 
                                        : slotH / 4; // Default to 15-minute height if invalid

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
                                            child: Padding(
                                              padding: EdgeInsets.all(4),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    e.subject,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    '${e.durationHours.toStringAsFixed(1)}h',
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        childWhenDragging: Container(
                                          width: baseW * e.widthFactor,
                                          height: height,
                                          decoration: BoxDecoration(
                                            color: e.color.withOpacity(0.3),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(
                                              color: e.color,
                                              style: BorderStyle.solid,
                                              width: 2,
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              e.subject,
                                              style: TextStyle(
                                                color: e.color,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        child: Container(
                                          width: baseW * e.widthFactor,
                                          height: height,
                                          margin: EdgeInsets.all(1),
                                          child: Stack(
                                            children: [
                                              // Box background + text
                                              height < 20 
                                                  ? Container(
                                                      // Simple dot for very small events
                                                      child: Center(
                                                        child: Container(
                                                          width: 4,
                                                          height: 4,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            shape: BoxShape.circle,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : Container(
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
                                                          Row(
                                                            children: [
                                                              Expanded(
                                                                child: Text(
                                                                  e.subject,
                                                                  style: Theme.of(context)
                                                                      .textTheme
                                                                      .bodyMedium!
                                                                      .copyWith(
                                                                        color: Colors.white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize: height < 30 ? 10 : 14, // Smaller font for small events
                                                                      ),
                                                                  overflow:
                                                                      TextOverflow.ellipsis,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          if (e.subtitle.isNotEmpty && height >= 40) ...[ // Only show subtitle if enough height
                                                            SizedBox(height: 2),
                                                            Text(
                                                              e.subtitle,
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    color:
                                                                        Colors.white70,
                                                                    fontSize: height < 50 ? 8 : 12, // Smaller font for small events
                                                                  ),
                                                              overflow:
                                                                  TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                          if (height >= 30) ...[ // Only show time if enough height
                                                            SizedBox(height: 2),
                                                            Text(
                                                              '${e.startHour.toString().padLeft(2, '0')}:${e.startMinute.toString().padLeft(2, '0')} - ${e.finishHour.toString().padLeft(2, '0')}:${e.finishMinute.toString().padLeft(2, '0')}',
                                                              style: Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    color:
                                                                        Colors.white70,
                                                                    fontSize: height < 50 ? 8 : 12, // Smaller font for small events
                                                                  ),
                                                            ),
                                                          ],
                                                          if (e.body.isNotEmpty && height >= 50) ...[ // Only show details if enough height
                                                            SizedBox(height: 2),
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                  Icons.description,
                                                                  size: height < 60 ? 8 : 10,
                                                                  color: Colors.white60,
                                                                ),
                                                                SizedBox(width: 2),
                                                                Expanded(
                                                                  child: Text(
                                                                    'Has details',
                                                                    style: Theme.of(context)
                                                                        .textTheme
                                                                        .bodySmall!
                                                                        .copyWith(
                                                                          color:
                                                                              Colors.white60,
                                                                          fontSize: height < 60 ? 6 : 10,
                                                                        ),
                                                                    overflow:
                                                                        TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ],
                                                      ),
                                                    ),
                                              // Main event area for editing and preview
                                              Positioned.fill(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    _showEventEditor(e);
                                                  },
                                                  onLongPress: () {
                                                    _showEventPreview(e);
                                                  },
                                                  onSecondaryTap: () {
                                                    _showEventPreview(e);
                                                  },
                                                  child: Container(
                                                    color: Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
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
