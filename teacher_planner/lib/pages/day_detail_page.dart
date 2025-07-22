/// lib/pages/day_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'week_view.dart'; // for EventBlock

class DayDetailPage extends StatefulWidget {
  final String day;
  final List<EventBlock> events;

  const DayDetailPage({Key? key, required this.day, required this.events})
    : super(key: key);

  @override
  _DayDetailPageState createState() => _DayDetailPageState();
}

class _DayDetailPageState extends State<DayDetailPage>
    with SingleTickerProviderStateMixin {
  static const int startHour = 6;
  static const int endHour = 18;
  static const double hourHeight = 80.0;

  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalSlots = endHour - startHour;
    final dayHeight = totalSlots * hourHeight;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: FadeTransition(
          opacity: _fadeIn,
          child: Text(widget.day, style: theme.textTheme.titleLarge),
        ),
        elevation: 2,
      ),
      body: Column(
        children: [
          // 1) Animated timeline area
          Expanded(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                child: SizedBox(
                  height: dayHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Curriculum panel
                      Expanded(
                        flex: 2,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(-0.3, 0),
                            end: Offset.zero,
                          ).animate(_fadeIn),
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'AUS curriculum',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Time labels column
                      SizedBox(
                        width: 60,
                        height: dayHeight,
                        child: Column(
                          children: List.generate(totalSlots, (i) {
                            final hour = startHour + i;
                            return SizedBox(
                              height: hourHeight,
                              child: Center(
                                child: Text(
                                  '$hour:00',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            );
                          }),
                        ),
                      ),

                      // Timeline panel with draggable/resizable events
                      Expanded(
                        flex: 3,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.3, 0),
                            end: Offset.zero,
                          ).animate(_fadeIn),
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 25),
                              child: LayoutBuilder(
                                builder: (ctx, cons) {
                                  final timelineW = cons.maxWidth;
                                  return Stack(
                                    children: [
                                      // Grid lines
                                      for (var i = 0; i <= totalSlots; i++)
                                        Positioned(
                                          top: i * hourHeight,
                                          left: 0,
                                          right: 0,
                                          child: Divider(
                                            color: theme.dividerColor,
                                          ),
                                        ),

                                      // Transformable event blocks
                                      for (var ev in widget.events)
                                        TransformableBox(
                                          rect: Rect.fromLTWH(
                                            0,
                                            (ev.startHour - startHour) *
                                                hourHeight,
                                            timelineW,
                                            ev.duration * hourHeight,
                                          ),
                                          clampingRect:
                                              Offset.zero &
                                              Size(timelineW, dayHeight),
                                          enabledHandles: {
                                            HandlePosition.top,
                                            HandlePosition.bottom,
                                          },
                                          visibleHandles: {
                                            HandlePosition.top,
                                            HandlePosition.bottom,
                                          },
                                          allowFlippingWhileResizing: false,
                                          onChanged: (res, _) {
                                            setState(() {
                                              final r = res.rect;
                                              ev.startHour =
                                                  startHour +
                                                  (r.top / hourHeight).round();
                                              ev.duration =
                                                  (r.height / hourHeight)
                                                      .round();
                                            });
                                          },
                                          contentBuilder:
                                              (context, rect, flip) {
                                                return Container(
                                                  width: rect.width,
                                                  height: rect.height,
                                                  decoration: BoxDecoration(
                                                    color: ev.color,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      ev.subject,
                                                      style: theme
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                );
                                              },
                                        ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Reflection panel
          FadeTransition(
            opacity: _fadeIn,
            child: SizedBox(
              height: 100,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: InputDecoration.collapsed(
                        hintText: 'Reflection',
                        hintStyle: theme.textTheme.bodySmall,
                      ),
                      style: theme.textTheme.bodyMedium,
                      maxLines: null,
                      expands: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
