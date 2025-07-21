// lib/pages/day_detail_page.dart

import 'package:flutter/material.dart';
import 'week_view.dart'; // for EventBlock

class DayDetailPage extends StatelessWidget {
  final String day;
  final List<EventBlock> events;
  const DayDetailPage({Key? key, required this.day, required this.events})
    : super(key: key);

  // keep these in sync with your WeekView
  static const int startHour = 6;
  static const int endHour = 18;

  @override
  Widget build(BuildContext context) {
    final totalHours = endHour - startHour;
    return Scaffold(
      appBar: AppBar(title: Text(day)),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // 1) Curriculum column
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Center(child: Text('AUS curriculum')),
                  ),
                ),

                // 2) TIME label
                Container(
                  width: 40,
                  child: Center(
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        'TIME',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ),
                ),

                // 3) Timeline with events
                Expanded(
                  flex: 3,
                  child: LayoutBuilder(
                    builder: (ctx, cons) {
                      final slotH = cons.maxHeight / totalHours;
                      return Stack(
                        children: [
                          // hour‐lines
                          for (var i = 0; i <= totalHours; i++)
                            Positioned(
                              top: i * slotH,
                              left: 0,
                              right: 0,
                              child: Divider(
                                color: Colors.grey.shade300,
                                height: 1,
                              ),
                            ),

                          // events
                          for (var ev in events)
                            Positioned(
                              top: (ev.startHour - startHour) * slotH,
                              left: 0,
                              width: cons.maxWidth,
                              height: ev.duration * slotH,
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: ev.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    ev.subject,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // 4) Reflection box
          Container(
            height: 100,
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration.collapsed(hintText: 'Reflection'),
            ),
          ),
        ],
      ),
    );
  }
}
