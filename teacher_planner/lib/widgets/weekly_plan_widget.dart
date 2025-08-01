import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/weekly_plan_data.dart';
import '../widgets/lesson_dialogs.dart';
import '../widgets/lesson_cell_widgets.dart';
import '../config/app_fonts.dart';
import '../services/lesson_database_service.dart';

class WeeklyPlanWidget extends StatefulWidget {
  final int periods;
  final List<WeeklyPlanData>? initialData;
  final bool isVerticalLayout;
  final Function(int dayIndex)? onDayTap;
  final DateTime? weekStartDate;
  final VoidCallback? onAddFullWeekEvent;
  final Function(List<WeeklyPlanData>) onPlanChanged;
  final VoidCallback? onPreviousWeek;
  final VoidCallback? onNextWeek;
  final Function(bool isVertical)? onLayoutChanged;

  const WeeklyPlanWidget({
    Key? key,
    required this.periods,
    this.initialData,
    required this.isVerticalLayout,
    this.onDayTap, 
    this.weekStartDate,
    this.onAddFullWeekEvent,
    required this.onPlanChanged,
    this.onPreviousWeek,
    this.onNextWeek,
    this.onLayoutChanged,
  }) : super(key: key);

  @override
  WeeklyPlanWidgetState createState() => WeeklyPlanWidgetState();
}

class WeeklyPlanWidgetState extends State<WeeklyPlanWidget> {
  List<WeeklyPlanData> _planData = [];
  DateTime _currentWeek = DateTime.now();
  int _nextLessonId = 1;

  List<WeeklyPlanData> get planData => _planData;

  // Day colors for visual distinction
  static const List<Color> _dayColors = [
    Color(0xFFA3A380), // Monday - Solid Light Purple
    Color(0xFFD7CE93), // Tuesday - Solid Light Orange
    Color(0xFFEFEBCE), // Wednesday - Solid Light Green
    Color(0xFFD8A48F), // Thursday - Solid Light Pink
    Color(0xFFBB8588), // Friday - Solid Light Teal
  ];

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  // Helper method to get the effective color for a lesson
  Color _getLessonColor(WeeklyPlanData data) {
    if (data.isLesson && data.lessonColor != null) {
      return data.lessonColor!;
    }
    return _dayColors[data.dayIndex];
  }

  @override
  void initState() {
    super.initState();
    _initializeEmptyCells();
    _loadWeekData();
  }

  @override
  void didUpdateWidget(WeeklyPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Rebuild when weekStartDate changes
    if (oldWidget.weekStartDate != widget.weekStartDate) {
      setState(() {
        // Update all plan data with new dates
        if (widget.weekStartDate != null) {
          for (int i = 0; i < _planData.length; i++) {
            final data = _planData[i];
            _planData[i] = data.copyWith(
              date: widget.weekStartDate!.add(Duration(days: data.dayIndex)),
            );
          }
        }
      });
    }
  }

  void _initializeEmptyCells() {
    for (int dayIndex = 0; dayIndex < 5; dayIndex++) {
      for (int periodIndex = 0; periodIndex < widget.periods; periodIndex++) {
        final existingData = _planData.where((d) => 
          d.dayIndex == dayIndex && d.periodIndex == periodIndex
        ).toList();
        
        if (existingData.isEmpty) {
          _planData.add(WeeklyPlanData(
            dayIndex: dayIndex,
            periodIndex: periodIndex,
            date: widget.weekStartDate?.add(Duration(days: dayIndex)),
          ));
        } else {
          final existing = existingData.first;
          if (existing.date == null && widget.weekStartDate != null) {
            _planData.remove(existing);
            _planData.add(existing.copyWith(
              date: widget.weekStartDate!.add(Duration(days: dayIndex)),
            ));
          }
        }
      }
    }
  }

  void _loadWeekData() async {
    try {
      debugPrint('Loading week data for week starting: ${widget.weekStartDate}');
      
      if (widget.weekStartDate != null) {
        final loadedData = await LessonDatabaseService.loadCompleteWeeklyPlan(widget.weekStartDate!);
        
        if (loadedData.isNotEmpty) {
          setState(() {
            _planData = loadedData;
          });
          debugPrint('Successfully loaded ${loadedData.length} plan items');
        } else {
          // Initialize with empty data if no data found
          if (widget.initialData != null) {
            _planData = List.from(widget.initialData!);
          } else {
            _initializeEmptyCells();
          }
        }
      } else {
        // Initialize with initialData if provided
        if (widget.initialData != null) {
          _planData = List.from(widget.initialData!);
        } else {
          _initializeEmptyCells();
        }
      }
    } catch (e) {
      debugPrint('Error loading week data: $e');
      // Fallback to initialData or empty cells
      if (widget.initialData != null) {
        _planData = List.from(widget.initialData!);
      } else {
        _initializeEmptyCells();
      }
    }
  }

  void _saveWeekData() async {
    try {
      debugPrint('Saving week data for week starting: ${widget.weekStartDate}');
      debugPrint('Total lessons: ${_planData.where((d) => d.isLesson).length}');
      
      if (widget.weekStartDate != null) {
        final success = await LessonDatabaseService.saveCompleteWeeklyPlan(
          _planData,
          widget.weekStartDate!,
          widget.periods,
        );
        
        if (success) {
          debugPrint('Successfully saved weekly plan data');
        } else {
          debugPrint('Failed to save weekly plan data');
        }
      }
    } catch (e) {
      debugPrint('Error saving week data: $e');
    }
  }

  // Lesson management methods
  void _addLesson(WeeklyPlanData data) async {
    final newLesson = await LessonDialogs.showAddLessonDialog(
      context: context,
      data: data,
      weekStartDate: widget.weekStartDate,
      nextLessonId: _nextLessonId.toString(),
    );

    if (newLesson != null) {
      setState(() {
        final existingLesson = _planData.where((d) => 
          d.dayIndex == data.dayIndex && 
          d.periodIndex == data.periodIndex && 
          d.isLesson
        ).toList();

        if (existingLesson.isNotEmpty) {
          final existing = existingLesson.first;
          final updatedSubLessons = List<WeeklyPlanData>.from(existing.subLessons);
          updatedSubLessons.add(newLesson);
          
          _planData.remove(existing);
          _planData.add(existing.copyWith(subLessons: updatedSubLessons));
        } else {
          _planData.remove(data);
          _planData.add(newLesson);
        }
        _nextLessonId++;
      });
      _saveWeekData();
    }
  }

  void _editPlanCell(WeeklyPlanData data) async {
    if (!data.isLesson) return;
    
    final updatedLesson = await LessonDialogs.showEditLessonDialog(
      context: context,
      data: data,
    );

    if (updatedLesson != null) {
      setState(() {
        _planData.remove(data);
        _planData.add(updatedLesson);
      });
      _saveWeekData();
    }
  }

  void _deleteLesson(WeeklyPlanData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Lesson'),
        content: Text('Are you sure you want to delete this lesson? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _planData.remove(data);
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteLessonFromMultipleCell(int dayIndex, int periodIndex, int lessonIndex) {
    setState(() {
      final cellData = _planData.where((d) => 
        d.dayIndex == dayIndex && 
        d.periodIndex == periodIndex && 
        d.subLessons.isNotEmpty
      ).toList();

      if (cellData.isNotEmpty) {
        final cell = cellData.first;
        final updatedSubLessons = List<WeeklyPlanData>.from(cell.subLessons);
        
        if (lessonIndex < updatedSubLessons.length) {
          updatedSubLessons.removeAt(lessonIndex);
        }

        _planData.remove(cell);
        
        if (updatedSubLessons.isEmpty) {
          _planData.add(WeeklyPlanData(
            dayIndex: dayIndex,
            periodIndex: periodIndex,
            date: widget.weekStartDate?.add(Duration(days: dayIndex)),
          ));
        } else if (updatedSubLessons.length == 1) {
          _planData.add(updatedSubLessons.first);
        } else {
          _planData.add(cell.copyWith(subLessons: updatedSubLessons));
        }
      }
    });
    _saveWeekData();
  }

  Widget _buildCellContent(WeeklyPlanData data, ThemeData theme, int dayIndex) {
    if (data.isFullWeekEvent) {
      return LessonCellWidgets.buildDraggableLesson(
        data: data,
        theme: theme,
        onEdit: () => _editPlanCell(data),
        onDelete: () => _deleteLesson(data),
      );
    }
    
    if (data.isLesson) {
      return LessonCellWidgets.buildDraggableLesson(
        data: data,
        theme: theme,
        onEdit: () => _editPlanCell(data),
        onDelete: () => _deleteLesson(data),
      );
    } else if (data.subLessons.isNotEmpty) {
      return LessonCellWidgets.buildMultipleLessonsCell(
        data: data,
        theme: theme,
        onDeleteLesson: _deleteLessonFromMultipleCell,
      );
    } else {
      return LessonCellWidgets.buildEmptyCell(
        data: data,
        theme: theme,
        dayIndex: dayIndex,
        onTap: () => _addLesson(data),
        planData: _planData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 768;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    return Scaffold(
      body: Column(
        children: [
          // Improved header with better spacing and typography
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 16 : 12,
            ),
      decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey[200]!,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Week navigation with better touch targets
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: _previousWeek,
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.chevron_left,
                      size: isTablet ? 28 : 24,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
                
                Expanded(
                  child: GestureDetector(
                    onTap: _showWeekPicker,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 12 : 8,
                        horizontal: 16,
                      ),
                      child: Text(
                        _getWeekText(),
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.all(isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: _nextWeek,
                    borderRadius: BorderRadius.circular(8),
                    child: Icon(
                      Icons.chevron_right,
                      size: isTablet ? 28 : 24,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
          ],
        ),
      ),
          
          // Enhanced view toggle with Material You design
          Container(
            margin: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 16 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onLayoutChanged?.call(true),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: widget.isVerticalLayout ? Colors.blue[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_agenda,
                            color: !_isHorizontalView ? Colors.white : Colors.grey[600],
                            size: isTablet ? 22 : 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Vertical',
                            style: TextStyle(
                              color: !_isHorizontalView ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onLayoutChanged?.call(false),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: !widget.isVerticalLayout ? Colors.blue[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.view_day,
                            color: _isHorizontalView ? Colors.white : Colors.grey[600],
                            size: isTablet ? 22 : 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Horizontal',
                            style: TextStyle(
                              color: _isHorizontalView ? Colors.white : Colors.grey[600],
                              fontWeight: FontWeight.w600,
                              fontSize: isTablet ? 16 : 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Main content with gesture detection
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                // Swipe navigation between weeks (inspired by modern apps)
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! > 0) {
                    _previousWeek(); // Swipe right = previous week
                    HapticFeedback.lightImpact();
                  } else if (details.primaryVelocity! < 0) {
                    _nextWeek(); // Swipe left = next week
                    HapticFeedback.lightImpact();
                  }
                }
              },
              child: widget.isVerticalLayout ? _buildVerticalView() : _buildHorizontalView(),
            ),
          ),
        ],
      ),
    );
  }

  // Keep all the existing layout methods but reference the separated components
  Widget _buildVerticalLayout(ThemeData theme, bool isTablet, Size screenSize) {
    final headerHeight = isTablet ? 80.0 : 60.0;
    final availableHeight = screenSize.height - headerHeight - 120;
    final cellHeight = availableHeight / widget.periods;
    final periodLabelWidth = isTablet ? 120.0 : 100.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final smallFontSize = isTablet ? 14.0 : 12.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
      child: Column(
        children: [
          _buildDayHeaders(headerHeight, periodLabelWidth, fontSize, smallFontSize, theme),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: widget.periods * 2 - 1,
              itemBuilder: (context, index) {
                final isGap = index % 2 == 1;
                final periodIndex = index ~/ 2;
                
                if (isGap) {
                  return _buildFullWeekEventGap(periodIndex, theme, isTablet, periodLabelWidth, smallFontSize);
                } else {
                  return _buildPeriodRow(periodIndex, theme, isTablet, cellHeight, periodLabelWidth, smallFontSize);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // Add other essential methods here...
  String _getDateString(int dayIndex) {
    if (widget.weekStartDate == null) return '';
    final date = widget.weekStartDate!.add(Duration(days: dayIndex));
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  Widget _buildDayHeaders(double headerHeight, double periodLabelWidth, double fontSize, double smallFontSize, ThemeData theme) {
    return Container(
            height: headerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
        // Removed boxShadow here - this was causing shadows between day headers!
            ),
            child: Row(
              children: [
                Container(
                  width: periodLabelWidth,
                  height: headerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor.withOpacity(0.2),
                        theme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                                     child: Text(
                     'Period',
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: fontSize,
                       color: theme.primaryColor.withOpacity(0.8),
                       fontFamily: 'Roboto',
                     ),
                   ),
                ),
                ...List.generate(5, (dayIndex) => Expanded(
            child: _buildDayHeader(dayIndex, headerHeight, fontSize, smallFontSize, theme),
          )),
        ],
      ),
    );
  }

  Widget _buildDayHeader(int dayIndex, double headerHeight, double fontSize, double smallFontSize, ThemeData theme) {
    return GestureDetector(
                    onTap: () => widget.onDayTap?.call(dayIndex),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        height: headerHeight,
                        margin: EdgeInsets.only(left: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              _dayColors[dayIndex],
                              _dayColors[dayIndex].withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
            // Removed boxShadow here - this was causing shadows between day headers!
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dayNames[dayIndex],
                                style: AppFonts.weekDayHeader.copyWith(
                                  fontSize: fontSize,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.2),
                                      offset: Offset(0, 1),
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                              if (widget.weekStartDate != null) ...[
                                SizedBox(height: 2),
                                Text(
                                  _getDateString(dayIndex),
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: smallFontSize - 2,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.2),
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              SizedBox(height: 2),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withOpacity(0.7),
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }


  Widget _buildHorizontalLayout(ThemeData theme, bool isTablet, Size screenSize) {
    final headerHeight = isTablet ? 80.0 : 60.0;
    final availableHeight = screenSize.height - headerHeight - 120;
    final cellHeight = availableHeight / 5; // 5 days
    final dayLabelWidth = isTablet ? 140.0 : 120.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final smallFontSize = isTablet ? 14.0 : 12.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
      child: Column(
        children: [
          _buildPeriodHeaders(headerHeight, dayLabelWidth, fontSize, theme),
          SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 5, // 5 days
              itemBuilder: (context, dayIndex) {
                return _buildDayRowWithPeriodGaps(dayIndex, theme, isTablet, cellHeight, dayLabelWidth, smallFontSize);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodHeaders(double headerHeight, double dayLabelWidth, double fontSize, ThemeData theme) {
    return Container(
            height: headerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
        // Removed boxShadow here
            ),
            child: Row(
              children: [
                Container(
                  width: dayLabelWidth,
                  height: headerHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.primaryColor.withOpacity(0.2),
                        theme.primaryColor.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                                     child: Text(
                     'Day',
                     style: TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: fontSize,
                       color: theme.primaryColor.withOpacity(0.8),
                       fontFamily: 'Roboto',
                     ),
                   ),
                ),
                ...List.generate(widget.periods * 2 - 1, (index) {
            final isGap = index % 2 == 1;
            final periodIndex = index ~/ 2;
                  
                  if (isGap) {
                    // Gap between periods for full week events (no text)
                    return Container(
                      width: 40, // Width for full week event gap
                      height: headerHeight,
                      margin: EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orange.withOpacity(0.1),
                            Colors.orange.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  } else {
                    // Regular period column
                    return Expanded(
                      child: Container(
                        height: headerHeight,
                        margin: EdgeInsets.only(left: 2),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              theme.primaryColor.withOpacity(0.3),
                              theme.primaryColor.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(periodIndex == widget.periods - 1 ? 16 : 8),
                    // Removed boxShadow here
                        ),
                        child: Center(
                                                   child: Text(
                           'P${periodIndex + 1}',
                           style: TextStyle(
                             fontWeight: FontWeight.bold,
                             color: theme.primaryColor.withOpacity(0.8),
                             fontSize: fontSize - 2,
                             fontFamily: 'Roboto',
                           ),
                         ),
                        ),
                      ),
                    );
                  }
                }),
              ],
            ),
    );
  }

  Widget _buildPeriodRow(int periodIndex, ThemeData theme, bool isTablet, double cellHeight, double periodLabelWidth, double smallFontSize) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Removed boxShadow here - this was causing the shadows between periods!
      ),
      child: Row(
        children: [
          // Period number
          Container(
            width: periodLabelWidth,
            height: cellHeight,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withOpacity(0.15),
                  theme.primaryColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              border: Border.all(
                color: theme.primaryColor.withOpacity(0.2),
                width: 1,
              ),
            ),
                         child: Text(
               '${periodIndex + 1}',
               style: TextStyle(
                 color: theme.primaryColor.withOpacity(0.8),
                 fontSize: smallFontSize + 8,
                 fontWeight: FontWeight.w600,
                 fontFamily: 'Roboto',
               ),
             ),
          ),
          
          // Day cells with color strips and drag/drop functionality
          ...List.generate(5, (dayIndex) => Expanded(
            child: Container(
              height: cellHeight,
              margin: EdgeInsets.only(left: 4, right: 4),
              child: _buildDraggableCell(dayIndex, periodIndex, theme, cellHeight),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDayRowWithPeriodGaps(int dayIndex, ThemeData theme, bool isTablet, double cellHeight, double dayLabelWidth, double smallFontSize) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        // Removed boxShadow here - this was causing shadows in horizontal gaps!
      ),
      child: Row(
        children: [
          // Day name - clickable for navigation
          GestureDetector(
            onTap: () => widget.onDayTap?.call(dayIndex),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                width: dayLabelWidth,
                height: cellHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _dayColors[dayIndex],
                      _dayColors[dayIndex].withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  // Removed boxShadow here
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayNames[dayIndex],
                      style: AppFonts.weekDayHeader.copyWith(
                        fontSize: smallFontSize + 2,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.2),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (widget.weekStartDate != null) ...[
                      SizedBox(height: 2),
                      Text(
                        _getDateString(dayIndex),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: smallFontSize - 2,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.2),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          
          // Period cells with gaps for full week events
          ...List.generate(widget.periods * 2 - 1, (index) {
            final isGap = index % 2 == 1;
            final periodIndex = index ~/ 2;
            
            if (isGap) {
              // Gap between periods for full week events
              return Container(
                width: 40,
                height: cellHeight,
                margin: EdgeInsets.only(left: 2, right: 2),
                child: _buildFullWeekEventGapCell(dayIndex, periodIndex, theme, cellHeight),
              );
            } else {
              // Regular period cell
              return Expanded(
                child: Container(
                  height: cellHeight,
                  margin: EdgeInsets.only(left: 2, right: 2),
                  child: _buildDraggableCell(dayIndex, periodIndex, theme, cellHeight),
                ),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildDraggableCell(int dayIndex, int periodIndex, ThemeData theme, double cellHeight) {
    final data = _planData.firstWhere(
      (d) => d.dayIndex == dayIndex && d.periodIndex == periodIndex,
      orElse: () => WeeklyPlanData(
        dayIndex: dayIndex,
        periodIndex: periodIndex,
        date: widget.weekStartDate?.add(Duration(days: dayIndex)),
      ),
    );

    return DragTarget<WeeklyPlanData>(
      onWillAcceptWithDetails: (details) {
        final draggedData = details.data;
        if (draggedData.dayIndex == dayIndex && draggedData.periodIndex == periodIndex) {
          return false;
        }
        if (draggedData.isFullWeekEvent) {
          return false;
        }
        return true;
      },
      onAcceptWithDetails: (details) {
        final draggedData = details.data;
        _moveLesson(draggedData, dayIndex, periodIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingFullWeekEvent = candidateData.isNotEmpty && 
          candidateData.first?.isFullWeekEvent == true;
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty 
                ? (isDraggingFullWeekEvent 
                    ? Colors.red.withValues(alpha: 0.3)
                    : (candidateData.isNotEmpty && candidateData.first != null
                        ? _getLessonColor(candidateData.first!).withValues(alpha: 0.5)
                        : _dayColors[dayIndex].withValues(alpha: 0.5)))
                : Colors.grey.shade200,
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
            // Removed boxShadow here - this was causing shadows in cells!
          ),
          child: Column(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: _dayColors[dayIndex],
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
              ),
              Expanded(
                child: _buildCellContent(data, theme, dayIndex),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFullWeekEventGapCell(int dayIndex, int periodIndex, ThemeData theme, double cellHeight) {
    return DragTarget<WeeklyPlanData>(
      onWillAcceptWithDetails: (details) {
        final draggedData = details.data;
        return draggedData.isFullWeekEvent;
      },
      onAcceptWithDetails: (details) {
        // Handle full week event movement
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
            border: candidateData.isNotEmpty 
              ? Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1)
              : null,
          ),
        );
      },
    );
  }

  void _moveLesson(WeeklyPlanData data, int newDayIndex, int newPeriodIndex) {
    try {
      setState(() {
        if (data.isFullWeekEvent) {
          if (data.dayIndex == newDayIndex) {
            // Handle full week event movement logic here
          }
          return;
        }

        _planData.removeWhere((d) => d.lessonId == data.lessonId);

        final oldPositionExists = _planData.any((d) => 
          d.dayIndex == data.dayIndex && d.periodIndex == data.periodIndex
        );
        if (!oldPositionExists) {
          _planData.add(WeeklyPlanData(
            dayIndex: data.dayIndex,
            periodIndex: data.periodIndex,
            date: widget.weekStartDate?.add(Duration(days: data.dayIndex)),
          ));
        }

        _planData.removeWhere((d) => 
          d.dayIndex == newDayIndex && d.periodIndex == newPeriodIndex
        );

        _planData.add(data.copyWith(
          dayIndex: newDayIndex,
          periodIndex: newPeriodIndex,
          lessonId: _nextLessonId.toString(),
          isLesson: true,
          date: widget.weekStartDate?.add(Duration(days: newDayIndex)),
        ));
        _nextLessonId++;
      });
      
      _saveWeekData();
    } catch (e) {
      debugPrint('Error moving lesson: $e');
    }
  }

  Widget _buildFullWeekEventGap(int periodIndex, ThemeData theme, bool isTablet, double periodLabelWidth, double smallFontSize) {
    // Check if there's a full week event for this period
    final fullWeekEvents = _planData.where((data) => 
      data.isFullWeekEvent && data.periodIndex == periodIndex
    ).toList();
    
    if (fullWeekEvents.isEmpty) {
      // No full week event for this period, show empty gap
      return Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: periodLabelWidth,
              height: 40,
            ),
            ...List.generate(5, (dayIndex) {
              return Expanded(
                child: Container(
                  height: 40,
                  margin: EdgeInsets.only(left: 3, right: 3),
                  child: DragTarget<WeeklyPlanData>(
                    onWillAcceptWithDetails: (details) {
                      final draggedData = details.data;
                      return draggedData.isFullWeekEvent;
                    },
                    onAcceptWithDetails: (details) {
                      // Handle full week event drop
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: candidateData.isNotEmpty 
                            ? Border.all(color: Colors.orange.withValues(alpha: 0.3), width: 1)
                            : null,
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      );
    } else {
      // Show the full week event
      final event = fullWeekEvents.first;
      return Container(
        height: 40,
        margin: EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Container(
              width: periodLabelWidth,
              height: 40,
              alignment: Alignment.center,
                             child: Text(
                 'Full Week',
                 style: TextStyle(
                   fontSize: smallFontSize,
                   color: Colors.grey[600],
                   fontWeight: FontWeight.w600,
                   fontFamily: 'Roboto',
                 ),
               ),
            ),
            ...List.generate(5, (dayIndex) {
              return Expanded(
                child: Container(
                  height: 40,
                  margin: EdgeInsets.only(left: 3, right: 3),
                  decoration: BoxDecoration(
                    color: event.lessonColor ?? Colors.orange,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                                         child: Text(
                       event.content,
                       style: TextStyle(
                         fontSize: smallFontSize - 1,
                         color: Colors.white,
                         fontWeight: FontWeight.w600,
                         fontFamily: 'Roboto',
                       ),
                       textAlign: TextAlign.center,
                       overflow: TextOverflow.ellipsis,
                     ),
                  ),
                ),
              );
            }),
          ],
        ),
      );
    }
  }

  void addFullWeekEvent() {
    _showFullWeekEventDialog();
  }

  void _showFullWeekEventDialog() {
    final eventTypeController = TextEditingController();
    String selectedEventType = 'Lunch';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Add Full Week Event'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              DropdownButtonFormField<String>(
                value: selectedEventType,
                  decoration: InputDecoration(
                  labelText: 'Event Type',
                    border: OutlineInputBorder(),
                ),
                items: [
                  'Lunch',
                  'Recess',
                  'Assembly',
                  'Break',
                  'Sport',
                  'Library',
                  'Custom'
                ].map((type) => DropdownMenuItem(
                  value: type,
                  child: Text(type),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedEventType = value!;
                    if (value != 'Custom') {
                      eventTypeController.text = value;
                    }
                  });
                },
              ),
              if (selectedEventType == 'Custom') ...[
                SizedBox(height: 16),
                TextField(
                  controller: eventTypeController,
                  decoration: InputDecoration(
                    labelText: 'Custom Event Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
                _addFullWeekEventForAllDays(
                  selectedEventType == 'Custom' 
                    ? eventTypeController.text.trim()
                    : selectedEventType
                );
                Navigator.pop(context);
              },
              child: Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  void _addFullWeekEventForAllDays(String eventName) {
    if (eventName.isEmpty) return;
    
    // Show period selection dialog
    _showPeriodSelectionDialog(eventName);
  }

  void _showPeriodSelectionDialog(String eventName) {
    int selectedPeriod = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Select Period for $eventName'),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text('Which period should this event occur during?'),
                SizedBox(height: 16),
              ...List.generate(widget.periods, (index) => 
                RadioListTile<int>(
                  title: Text('Period ${index + 1}'),
                  value: index,
                  groupValue: selectedPeriod,
                  onChanged: (value) => setState(() => selectedPeriod = value!),
                ),
              ),
            ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
                _createFullWeekEvent(eventName, selectedPeriod);
                Navigator.pop(context);
              },
              child: Text('Add to All Days'),
            ),
          ],
        ),
      ),
    );
  }

  void _createFullWeekEvent(String eventName, int periodIndex) {
    setState(() {
      // Remove any existing full week events for this period
      _planData.removeWhere((data) => 
        data.isFullWeekEvent && data.periodIndex == periodIndex
      );
      
      // Add the event to all 5 weekdays
      for (int dayIndex = 0; dayIndex < 5; dayIndex++) {
        _planData.add(WeeklyPlanData(
          dayIndex: dayIndex,
          periodIndex: periodIndex,
          content: eventName,
          subject: eventName,
          notes: '',
          lessonId: 'fullweek_${eventName.toLowerCase()}_${periodIndex}_$dayIndex',
          date: widget.weekStartDate?.add(Duration(days: dayIndex)) ?? DateTime.now(),
          isLesson: false,
          isFullWeekEvent: true,
          subLessons: [],
          lessonColor: Colors.orange, // Orange color for full week events
        ));
      }
      
      // Notify parent of changes
      widget.onPlanChanged(_planData);
    });
    
    // Save the data
    _saveWeekData();
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$eventName added to all days in Period ${periodIndex + 1}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _previousWeek() {
    if (widget.onPreviousWeek != null) {
      widget.onPreviousWeek!();
    }
  }

  void _nextWeek() {
    if (widget.onNextWeek != null) {
      widget.onNextWeek!();
    }
  }

  void _loadWeeklyPlan() {
    // TODO: Load actual weekly plan data for the current week
    try {
      debugPrint('Loading weekly plan for week starting: ${_getWeekText()}');
      // Here you would typically load data from storage/database
      // For now, we just trigger a rebuild with existing data
                  setState(() {
        // Refresh the plan data if needed
        widget.onPlanChanged(_planData);
      });
                } catch (e) {
      debugPrint('Error loading weekly plan: $e');
    }
  }

  void _showWeekPicker() {
    // TODO: Implement week picker dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Week picker coming soon')),
    );
  }

  String _getWeekText() {
    if (widget.weekStartDate == null) return 'Week View';
    
    final startOfWeek = widget.weekStartDate!;
    final endOfWeek = startOfWeek.add(Duration(days: 4)); // Friday (5 days)
    return '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildHorizontalView() {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    final screenSize = MediaQuery.of(context).size;
    
    return _buildHorizontalLayout(theme, isTablet, screenSize);
  }

  Widget _buildVerticalView() {
    final theme = Theme.of(context);
    final isTablet = MediaQuery.of(context).size.width > 768;
    final screenSize = MediaQuery.of(context).size;
    
    return _buildVerticalLayout(theme, isTablet, screenSize);
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  bool _hasError = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _hasError = false;
                  _errorMessage = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    // Set up error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _hasError = true;
        _errorMessage = details.exception.toString();
      });
    };
  }
} 