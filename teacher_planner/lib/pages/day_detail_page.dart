import 'package:flutter/material.dart';
import 'week_view.dart'; // for EventBlock

class DayDetailPage extends StatelessWidget {
  final String day;
  final List<EventBlock> events;

  const DayDetailPage({Key? key, required this.day, required this.events})
    : super(key: key);

  static const int startHour = 6;
  static const int endHour = 18;
  // one “hour slot” per hour gap (6→7, 7→8, …, 17→18)
  static const double hourHeight = 80.0;

  @override
  Widget build(BuildContext context) {
    final totalSlots = endHour - startHour; // = 12
    final dayHeight = totalSlots * hourHeight; // = 960

    return Scaffold(
      appBar: AppBar(title: Text(day)),
      body: Column(
        children: [
          // 1) Scrollable timeline area
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: dayHeight,
                child: Row(
                  children: [
                    // — Curriculum panel
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: const Center(child: Text('AUS curriculum')),
                      ),
                    ),

                    // — Time‐labels column (exactly `totalSlots` children)
                    SizedBox(
                      width: 60,
                      child: Column(
                        children: List.generate(totalSlots, (i) {
                          final hour = startHour + i;
                          return SizedBox(
                            height: hourHeight,
                            child: Center(
                              child: Text(
                                '$hour:00',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // — Event timeline with grid + boxes
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          // horizontal grid lines
                          for (var i = 0; i <= totalSlots; i++)
                            Positioned(
                              top: i * hourHeight,
                              left: 0,
                              right: 0,
                              child: Divider(color: Colors.grey.shade300),
                            ),

                          // event boxes
                          for (var ev in events)
                            Positioned(
                              top: (ev.startHour - startHour) * hourHeight,
                              left: 4,
                              right: 4,
                              height: ev.duration * hourHeight,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                decoration: BoxDecoration(
                                  color: ev.color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Center(
                                  child: Text(
                                    ev.subject,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2) Reflection box
          Container(
            height: 100,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const TextField(
              decoration: InputDecoration.collapsed(hintText: 'Reflection'),
              expands: true,
              maxLines: null,
            ),
          ),
        ],
      ),
    );
  }
}
