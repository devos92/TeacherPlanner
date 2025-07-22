// lib/pages/day_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'week_view.dart';

class DayDetailPage extends StatelessWidget {
  final String day;
  final List<EventBlock> events;
  const DayDetailPage({Key? key, required this.day, required this.events})
    : super(key: key);

  static const int startHour = 6, endHour = 18;
  static const double hourHeight = 80.0, padding = 12.0;

  // Measure the rendered height of a Quill document
  double _measureHeight(quill.Delta delta, double maxWidth, TextStyle style) {
    final doc = quill.Document.fromDelta(delta);
    final tp = TextPainter(
      text: TextSpan(
        children: [
          for (var op in doc.toDelta()) TextSpan(text: op.value, style: style),
        ],
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout(maxWidth: maxWidth);
    return tp.size.height;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSlots = endHour - startHour;

    return Scaffold(
      appBar: AppBar(title: Text(day)),
      body: LayoutBuilder(
        builder: (ctx, cons) {
          // 1) base timeline height
          double timelineH = totalSlots * hourHeight;
          final contentW = cons.maxWidth * 0.8 - padding * 2;
          final style = theme.textTheme.bodyLarge!;

          // 2) bump timeline height to fit each event’s full content
          for (var ev in events) {
            final delta = ev.detailsDelta ?? quill.Delta()
              ..insert(ev.subject + '\n');
            final h = _measureHeight(delta, contentW, style) + padding * 2;
            final bottom = (ev.startHour - startHour) * hourHeight + h;
            if (bottom > timelineH) timelineH = bottom;
          }

          return SingleChildScrollView(
            child: SizedBox(
              height: timelineH,
              child: Row(
                children: [
                  // curriculum (20%)
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                      ),
                      child: Center(child: Text('AUS curriculum')),
                    ),
                  ),

                  // time labels
                  SizedBox(
                    width: 60,
                    child: Column(
                      children: List.generate(totalSlots, (i) {
                        return SizedBox(
                          height: hourHeight,
                          child: Center(
                            child: Text(
                              '${startHour + i}:00',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  // event timeline (80%)
                  Expanded(
                    flex: 3,
                    child: Stack(
                      children: [
                        // hour lines
                        for (var i = 0; i <= totalSlots; i++)
                          Positioned(
                            top: i * hourHeight,
                            left: 0,
                            right: 0,
                            child: Divider(color: Colors.grey.shade300),
                          ),

                        // each event
                        for (var ev in events)
                          Positioned(
                            top: (ev.startHour - startHour) * hourHeight,
                            left: 8,
                            right: 8,
                            height:
                                _measureHeight(
                                  ev.detailsDelta ?? quill.Delta()
                                    ..insert(ev.subject + '\n'),
                                  contentW,
                                  style,
                                ) +
                                padding * 2,
                            child: Container(
                              padding: EdgeInsets.all(padding),
                              decoration: BoxDecoration(
                                color: ev.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: quill.QuillEditor(
                                controller: quill.QuillController(
                                  document: quill.Document.fromDelta(
                                    ev.detailsDelta ?? quill.Delta()
                                      ..insert(ev.subject + '\n'),
                                  ),
                                  selection: TextSelection.collapsed(offset: 0),
                                ),
                                readOnly: true,
                                scrollable: false,
                                focusNode: FocusNode(),
                                autoFocus: false,
                                expands: false,
                                padding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
