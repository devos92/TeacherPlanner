// lib/pages/day_detail_page.dart

import 'package:flutter/material.dart';
import 'week_view.dart';

class DayDetailPage extends StatelessWidget {
  final String day;
  final List<EventBlock> events;
  const DayDetailPage({Key? key, required this.day, required this.events})
    : super(key: key);

  static const int startHour = 6, endHour = 18;
  static const double hourHeight = 80.0, padding = 12.0;

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

    // base timeline height
    double timelineH = totalSlots * hourHeight;
    final contentW = MediaQuery.of(context).size.width * 0.8 - padding * 2;
    final styleTitle = theme.textTheme.titleMedium!;
    final styleSubtitle = theme.textTheme.bodyMedium!;
    final styleBody = theme.textTheme.bodySmall!;

    // expand for each event’s content
    for (var ev in events) {
      double h = padding * 2;
      h += _measureTextHeight(ev.subject, contentW, styleTitle);
      h += _measureTextHeight(ev.subtitle, contentW, styleSubtitle);
      for (var line in ev.body.split('\n')) {
        h += _measureTextHeight(line, contentW, styleBody);
      }
      h += (ev.body.split('\n').length + 1) * 4; // line spacing

      final bottom = (ev.startHour - startHour) * hourHeight + h;
      if (bottom > timelineH) timelineH = bottom;
    }

    return Scaffold(
      appBar: AppBar(title: Text(day)),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SizedBox(
                height: timelineH,
                child: Row(
                  children: [
                    // your curriculum & time labels…

                    // event timeline
                    Expanded(
                      flex: 3,
                      child: Stack(
                        children: [
                          // grid lines…
                          for (var i = 0; i <= totalSlots; i++)
                            Positioned(
                              top: i * hourHeight,
                              left: 0,
                              right: 0,
                              child: Divider(color: Colors.grey.shade300),
                            ),

                          // events
                          for (var ev in events)
                            Positioned(
                              top: (ev.startHour - startHour) * hourHeight,
                              left: 8,
                              right: 8,
                              height: () {
                                double hh = padding * 2;
                                hh += _measureTextHeight(
                                  ev.subject,
                                  contentW,
                                  styleTitle,
                                );
                                hh += _measureTextHeight(
                                  ev.subtitle,
                                  contentW,
                                  styleSubtitle,
                                );
                                for (var l in ev.body.split('\n')) {
                                  hh += _measureTextHeight(
                                    l,
                                    contentW,
                                    styleBody,
                                  );
                                }
                                hh += (ev.body.split('\n').length + 1) * 4;
                                return hh;
                              }(),
                              child: Container(
                                padding: EdgeInsets.all(padding),
                                decoration: BoxDecoration(
                                  color: ev.color,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ev.subject, style: styleTitle),
                                    SizedBox(height: 4),
                                    Text(ev.subtitle, style: styleSubtitle),
                                    SizedBox(height: 4),
                                    ...ev.body
                                        .split('\n')
                                        .map((l) => Text(l, style: styleBody)),
                                  ],
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

          // Reflection
          Container(
            height: 100,
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
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
