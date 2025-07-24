import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for FlutterError.onError

class WeeklyPlanWidget extends StatefulWidget {
  final int periods;
  final List<WeeklyPlanData>? initialData;
  final bool isVerticalLayout;
  final Function(int dayIndex)? onDayTap; // Add navigation callback
  final DateTime? weekStartDate; // Add date for term planner integration
  final VoidCallback? onAddFullWeekEvent; // Add full week event callback

  const WeeklyPlanWidget({
    Key? key,
    required this.periods,
    this.initialData,
    required this.isVerticalLayout,
    this.onDayTap, // Add navigation callback
    this.weekStartDate, // Add date for term planner integration
    this.onAddFullWeekEvent, // Add full week event callback
  }) : super(key: key);

  @override
  State<WeeklyPlanWidget> createState() => WeeklyPlanWidgetState();
}

class WeeklyPlanWidgetState extends State<WeeklyPlanWidget> {
  late List<WeeklyPlanData> _planData;
  int _nextLessonId = 1; // For generating unique lesson IDs

  // Day colors for visual distinction
  static const List<Color> _dayColors = [
    Color(0xFFE1BEE7), // Monday - Light Purple
    Color(0xFFFFCC80), // Tuesday - Light Orange
    Color(0xFFC8E6C9), // Wednesday - Light Green
    Color(0xFFF8BBD9), // Thursday - Light Pink
    Color(0xFFB2DFDB), // Friday - Light Teal
  ];

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday', 
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  void initState() {
    super.initState();
    _planData = widget.initialData ?? [];
    
    // Initialize empty cells for all periods and days
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
          // Update existing data with new dates
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

  @override
  void didUpdateWidget(WeeklyPlanWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update dates when week changes
    if (oldWidget.weekStartDate != widget.weekStartDate && widget.weekStartDate != null) {
      setState(() {
        // Load data for the new week
        _loadWeekData();
        
        // Update dates for existing data
        for (int i = 0; i < _planData.length; i++) {
          final data = _planData[i];
          _planData[i] = data.copyWith(
            date: widget.weekStartDate!.add(Duration(days: data.dayIndex)),
          );
        }
      });
    }
  }

  void _loadWeekData() {
    try {
      // TODO: Load from database
      // This will be implemented when we add database integration
      debugPrint('Loading week data for week starting: ${widget.weekStartDate}');
      
      // For now, we'll keep the existing data structure
      // In the future, this will load lessons from the database for the specific week
    } catch (e) {
      debugPrint('Error loading week data: $e');
      // In production, this would show a user-friendly error message
      // and potentially retry the operation or show cached data
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
      ),
      child: widget.isVerticalLayout ? _buildVerticalLayout(isTablet) : _buildHorizontalLayout(isTablet),
    );
  }

  Widget _buildVerticalLayout(bool isTablet) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Responsive sizing - full screen with better handling for 6-8 periods
    final headerHeight = isTablet ? 80.0 : 60.0;
    final availableHeight = screenSize.height - headerHeight - 120; // Account for padding and spacing
    final cellHeight = availableHeight / widget.periods; // Full height distribution
    final periodLabelWidth = isTablet ? 120.0 : 100.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final smallFontSize = isTablet ? 14.0 : 12.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
      child: Column(
        children: [
          // Day headers with enhanced styling
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Period label column
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
                // Day columns with enhanced colors - only headers
                ...List.generate(5, (dayIndex) => Expanded(
                  child: GestureDetector(
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
                          borderRadius: BorderRadius.circular(dayIndex == 4 ? 16 : 0),
                          boxShadow: [
                            BoxShadow(
                              color: _dayColors[dayIndex].withValues(alpha: 0.3),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _dayNames[dayIndex],
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
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
                  ),
                )),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Period rows - full screen
          Expanded(
            child: ListView.builder(
              itemCount: widget.periods,
              itemBuilder: (context, periodIndex) => 
                _buildPeriodRow(periodIndex, theme, isTablet, cellHeight, periodLabelWidth, smallFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(int periodIndex, ThemeData theme, bool isTablet, double cellHeight, double periodLabelWidth, double smallFontSize) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Period number with enhanced styling
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
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor.withOpacity(0.8),
                fontSize: smallFontSize + 8,
              ),
            ),
          ),
          
          // Day cells with color strips and drag/drop functionality
          ...List.generate(5, (dayIndex) => Expanded(
            child: Container(
              height: cellHeight,
              margin: EdgeInsets.only(left: 4, right: 4), // Add gaps between days
              child: _buildDraggableCell(dayIndex, periodIndex, theme, cellHeight),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(bool isTablet) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    
    // Responsive sizing - full screen with better handling for 6-8 periods
    final headerHeight = isTablet ? 80.0 : 60.0;
    final availableHeight = screenSize.height - headerHeight - 120; // Account for padding and spacing
    final cellHeight = availableHeight / 5; // Full height distribution for 5 days
    final dayLabelWidth = isTablet ? 140.0 : 120.0;
    final fontSize = isTablet ? 18.0 : 16.0;
    final smallFontSize = isTablet ? 14.0 : 12.0;
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: EdgeInsets.all(isTablet ? 32.0 : 20.0),
      child: Column(
        children: [
          // Period headers with enhanced styling
          Container(
            height: headerHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Day label column
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: fontSize,
                      color: theme.primaryColor.withOpacity(0.8),
                    ),
                  ),
                ),
                // Period columns with enhanced styling
                ...List.generate(widget.periods, (periodIndex) => Expanded(
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
                      borderRadius: BorderRadius.circular(periodIndex == widget.periods - 1 ? 16 : 0),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withOpacity(0.2),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Period ${periodIndex + 1}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor.withOpacity(0.8),
                          fontSize: fontSize,
                          shadows: [
                            Shadow(
                              color: Colors.white.withOpacity(0.8),
                              offset: Offset(0, 1),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
          
          SizedBox(height: 20),
          
          // Day rows - full screen
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, dayIndex) => 
                _buildDayRow(dayIndex, theme, isTablet, cellHeight, dayLabelWidth, smallFontSize),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(int dayIndex, ThemeData theme, bool isTablet, double cellHeight, double dayLabelWidth, double smallFontSize) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Day name with enhanced styling - clickable for navigation
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
                  boxShadow: [
                    BoxShadow(
                      color: _dayColors[dayIndex].withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _dayNames[dayIndex],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: smallFontSize,
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
                    SizedBox(height: 2),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.7),
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Period cells with color strips and drag/drop functionality
          ...List.generate(widget.periods, (periodIndex) => Expanded(
            child: Container(
              height: cellHeight,
              margin: EdgeInsets.only(left: 4, right: 4), // Add gaps between periods
              child: _buildDraggableCell(dayIndex, periodIndex, theme, cellHeight),
            ),
          )),
        ],
      ),
    );
  }

  void _editPlanCell(WeeklyPlanData data) {
    // TODO: Implement lesson editing dialog
    print('Edit cell: ${data.dayIndex}, ${data.periodIndex}');
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
        final data = details.data;
        // Don't accept if dropping on the same position
        return data.dayIndex != dayIndex || data.periodIndex != periodIndex;
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        _moveLesson(data, dayIndex, periodIndex);
      },
      builder: (context, candidateData, rejectedData) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: candidateData.isNotEmpty 
                ? _dayColors[dayIndex].withValues(alpha: 0.5)
                : Colors.grey.shade200,
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Color strip on top
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
              // Cell content - takes up majority of space
              Expanded(
                child: _buildCellContent(data, theme, dayIndex),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableLesson(WeeklyPlanData data, ThemeData theme) {
    // Check if this is a full-week event
    final isFullWeekEvent = data.isFullWeekEvent;
    
    return Draggable<WeeklyPlanData>(
      data: data,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: 200,
          height: 100,
          decoration: BoxDecoration(
            color: _dayColors[data.dayIndex].withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              data.subject.isNotEmpty ? data.subject : 'Lesson',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: Center(
          child: Icon(
            Icons.drag_handle,
            color: Colors.grey.shade400,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _editPlanCell(data),
          borderRadius: BorderRadius.circular(12),
          splashColor: _dayColors[data.dayIndex].withValues(alpha: 0.2),
          highlightColor: _dayColors[data.dayIndex].withValues(alpha: 0.1),
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject header - bold and prominent
                if (data.subject.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _dayColors[data.dayIndex].withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            data.subject,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.drag_handle,
                        size: 14,
                        color: _dayColors[data.dayIndex].withValues(alpha: 0.7),
                      ),
                      SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => isFullWeekEvent 
                          ? _deleteFullWeekEventDay(data.dayIndex, data.periodIndex)
                          : _deleteLesson(data),
                        child: Icon(
                          Icons.delete_outline,
                          size: 14,
                          color: Colors.red.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                // Content - takes up all remaining space
                if (data.content.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _dayColors[data.dayIndex].withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _dayColors[data.dayIndex].withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        data.content,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 9,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                        maxLines: null, // Allow unlimited lines
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ),
                ],
                // Notes - minimal space at bottom
                if (data.notes.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: _dayColors[data.dayIndex].withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      data.notes,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 8,
                        fontStyle: FontStyle.italic,
                        color: _dayColors[data.dayIndex].withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleLessonsCell(WeeklyPlanData data, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: _dayColors[data.dayIndex].withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _dayColors[data.dayIndex].withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 6),
          Text(
            'Multiple Lessons (${data.subLessons.length})',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 11,
              color: _dayColors[data.dayIndex].withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 4),
          Expanded(
            child: ListView.builder(
              itemCount: data.subLessons.length,
              itemBuilder: (context, index) {
                final lesson = data.subLessons[index];
                return _buildLessonInMultipleCell(lesson, theme, data.dayIndex, data.periodIndex, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonInMultipleCell(WeeklyPlanData lesson, ThemeData theme, int dayIndex, int periodIndex, int lessonIndex) {
    return Container(
      margin: EdgeInsets.only(bottom: 4),
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _dayColors[dayIndex].withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: _dayColors[dayIndex].withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.subject.isNotEmpty ? lesson.subject : 'Lesson ${lessonIndex + 1}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 9,
                    color: _dayColors[dayIndex].withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (lesson.content.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    lesson.content,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 8,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () => _deleteLessonFromMultipleCell(dayIndex, periodIndex, lessonIndex),
            icon: Icon(
              Icons.delete_outline,
              size: 16,
              color: Colors.red.withValues(alpha: 0.7),
            ),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCell(WeeklyPlanData data, ThemeData theme, int dayIndex) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addLesson(data),
        borderRadius: BorderRadius.circular(12),
        splashColor: _dayColors[dayIndex].withValues(alpha: 0.2),
        highlightColor: _dayColors[dayIndex].withValues(alpha: 0.1),
        child: Container(
          padding: EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_circle_outline,
                  size: 20,
                  color: _dayColors[dayIndex].withValues(alpha: 0.4),
                ),
                SizedBox(height: 4),
                Text(
                  'Add Lesson',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 8,
                    color: _dayColors[dayIndex].withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _moveLesson(WeeklyPlanData data, int newDayIndex, int newPeriodIndex) {
    try {
      setState(() {
        // Remove the lesson from its current position
        _planData.removeWhere((d) => d.lessonId == data.lessonId);

        // Create empty cell for the old position if it doesn't exist
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

        // Remove any existing data from the new position
        _planData.removeWhere((d) => 
          d.dayIndex == newDayIndex && d.periodIndex == newPeriodIndex
        );

        // Add the lesson to the new position with updated date
        _planData.add(data.copyWith(
          dayIndex: newDayIndex,
          periodIndex: newPeriodIndex,
          lessonId: _nextLessonId.toString(), // Assign a new unique ID
          isLesson: true,
          date: widget.weekStartDate?.add(Duration(days: newDayIndex)),
        ));
        _nextLessonId++; // Increment for the next lesson
      });
      
      // Save the updated data
      _saveWeekData();
    } catch (e) {
      debugPrint('Error moving lesson: $e');
      // In production, this would show a user-friendly error message
      // and potentially revert the move operation
    }
  }

  void _addLesson(WeeklyPlanData data) {
    String subject = '';
    String content = '';
    String notes = '';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Lesson to ${_dayNames[data.dayIndex]} - Period ${data.periodIndex + 1}'),
        content: Container(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Subject *',
                    hintText: 'e.g., Mathematics, English, Science',
                    border: OutlineInputBorder(),
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Subject is required';
                    }
                    if (value.trim().length > 50) {
                      return 'Subject must be 50 characters or less';
                    }
                    return null;
                  },
                  onChanged: (value) => subject = value,
                  autofocus: true,
                  maxLength: 50,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Lesson Content',
                    hintText: 'Describe what will be taught in this lesson...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 500) {
                      return 'Content must be 500 characters or less';
                    }
                    return null;
                  },
                  maxLines: 4,
                  maxLength: 500,
                  onChanged: (value) => content = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional notes, resources, or reminders',
                    border: OutlineInputBorder(),
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 200) {
                      return 'Notes must be 200 characters or less';
                    }
                    return null;
                  },
                  maxLines: 2,
                  maxLength: 200,
                  onChanged: (value) => notes = value,
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
              if (formKey.currentState?.validate() == true) {
                try {
                  setState(() {
                    // Check if there's already a lesson in this cell
                    final existingLesson = _planData.where((d) => 
                      d.dayIndex == data.dayIndex && 
                      d.periodIndex == data.periodIndex && 
                      d.isLesson
                    ).toList();

                    if (existingLesson.isNotEmpty) {
                      // Add to existing multiple lessons
                      final existing = existingLesson.first;
                      final updatedSubLessons = List<WeeklyPlanData>.from(existing.subLessons);
                      updatedSubLessons.add(WeeklyPlanData(
                        dayIndex: data.dayIndex,
                        periodIndex: data.periodIndex,
                        subject: subject.trim(),
                        content: content.trim(),
                        notes: notes.trim(),
                        lessonId: _nextLessonId.toString(),
                        isLesson: true,
                        date: widget.weekStartDate?.add(Duration(days: data.dayIndex)),
                      ));
                      
                      _planData.remove(existing);
                      _planData.add(existing.copyWith(
                        subLessons: updatedSubLessons,
                      ));
                    } else {
                      // Create new lesson
                      _planData.remove(data);
                      _planData.add(data.copyWith(
                        subject: subject.trim(),
                        content: content.trim(),
                        notes: notes.trim(),
                        lessonId: _nextLessonId.toString(),
                        isLesson: true,
                        date: widget.weekStartDate?.add(Duration(days: data.dayIndex)),
                      ));
                    }
                    _nextLessonId++;
                  });
                  
                  // Save the updated data
                  _saveWeekData();
                  
                  Navigator.pop(context);
                } catch (e) {
                  // Show error dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to add lesson: ${e.toString()}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: Text('Save Lesson'),
          ),
        ],
      ),
    );
  }

  void _saveWeekData() {
    try {
      // TODO: Save to database
      // This will be implemented when we add database integration
      debugPrint('Saving week data for week starting: ${widget.weekStartDate}');
      debugPrint('Total lessons: ${_planData.where((d) => d.isLesson).length}');
      
      // Example of what will be saved:
      for (final data in _planData.where((d) => d.isLesson)) {
        debugPrint('Lesson: ${data.subject} on ${data.date} at period ${data.periodIndex + 1}');
      }
    } catch (e) {
      debugPrint('Error saving week data: $e');
      // In production, this would show a user-friendly error message
      // and potentially retry the operation
    }
  }

  void addFullWeekEvent() {
    String subject = '';
    String content = '';
    String notes = '';
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Full Week Event'),
        content: Container(
          width: 400,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Event Name *',
                    hintText: 'e.g., Lunch, Recess, Assembly',
                    border: OutlineInputBorder(),
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Event name is required';
                    }
                    if (value.trim().length > 50) {
                      return 'Event name must be 50 characters or less';
                    }
                    return null;
                  },
                  onChanged: (value) => subject = value,
                  autofocus: true,
                  maxLength: 50,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'Describe the event...',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 300) {
                      return 'Description must be 300 characters or less';
                    }
                    return null;
                  },
                  maxLines: 3,
                  maxLength: 300,
                  onChanged: (value) => content = value,
                ),
                SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    hintText: 'Additional information',
                    border: OutlineInputBorder(),
                    errorMaxLines: 2,
                  ),
                  validator: (value) {
                    if (value != null && value.trim().length > 200) {
                      return 'Notes must be 200 characters or less';
                    }
                    return null;
                  },
                  maxLines: 2,
                  maxLength: 200,
                  onChanged: (value) => notes = value,
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
              if (formKey.currentState?.validate() == true) {
                try {
                  setState(() {
                    // Add the event to all days for the specified period
                    for (int dayIndex = 0; dayIndex < 5; dayIndex++) {
                      final existingData = _planData.where((d) => 
                        d.dayIndex == dayIndex && d.periodIndex == 0 // Add to first period
                      ).toList();
                      
                      if (existingData.isNotEmpty) {
                        _planData.remove(existingData.first);
                      }
                      
                      _planData.add(WeeklyPlanData(
                        dayIndex: dayIndex,
                        periodIndex: 0, // First period
                        subject: subject.trim(),
                        content: content.trim(),
                        notes: notes.trim(),
                        lessonId: _nextLessonId.toString(),
                        isLesson: true,
                        isFullWeekEvent: true,
                        date: widget.weekStartDate?.add(Duration(days: dayIndex)),
                      ));
                    }
                    _nextLessonId++;
                  });
                  
                  // Save the updated data
                  _saveWeekData();
                  
                  Navigator.pop(context);
                } catch (e) {
                  // Show error dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to add full week event: ${e.toString()}'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
            child: Text('Add Event'),
          ),
        ],
      ),
    );
  }

  void _deleteFullWeekEventDay(int dayIndex, int periodIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete this event for ${_dayNames[dayIndex]}? Other days will remain unchanged.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _planData.removeWhere((d) => 
                  d.dayIndex == dayIndex && 
                  d.periodIndex == periodIndex && 
                  d.isFullWeekEvent
                );
              });
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _moveFullWeekEventRow(int currentPeriodIndex, int newPeriodIndex) {
    try {
      setState(() {
        // Find all full-week events for the current period
        final fullWeekEvents = _planData.where((d) => 
          d.periodIndex == currentPeriodIndex && d.isFullWeekEvent
        ).toList();

        // Remove them from current period
        for (final event in fullWeekEvents) {
          _planData.remove(event);
        }

        // Add them to the new period
        for (final event in fullWeekEvents) {
          _planData.add(event.copyWith(
            periodIndex: newPeriodIndex,
            lessonId: _nextLessonId.toString(),
          ));
          _nextLessonId++;
        }
      });
      
      // Save the updated data
      _saveWeekData();
    } catch (e) {
      debugPrint('Error moving full week event row: $e');
    }
  }

  String _getDateString(int dayIndex) {
    if (widget.weekStartDate == null) {
      return '';
    }
    final date = widget.weekStartDate!.add(Duration(days: dayIndex));
    
    // Format: "24/7" for day/month
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    
    return '$day/$month';
  }

  Widget _buildCellContent(WeeklyPlanData data, ThemeData theme, int dayIndex) {
    if (data.isLesson) {
      return _buildDraggableLesson(data, theme);
    } else if (data.subLessons.isNotEmpty) {
      return _buildMultipleLessonsCell(data, theme);
    } else {
      return _buildEmptyCell(data, theme, dayIndex);
    }
  }

  void _deleteLessonFromMultipleCell(int dayIndex, int periodIndex, int lessonIndex) {
    setState(() {
      _planData.removeAt(lessonIndex);
    });
    // No need to save immediately, as the cell will be rebuilt
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
              // No need to save immediately, as the cell will be rebuilt
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class WeeklyPlanData {
  final int dayIndex;
  final int periodIndex;
  final String content;
  final String subject;
  final String notes;
  final String lessonId; // Add unique lesson ID for drag and drop
  final DateTime? date; // Add date for term planner integration
  final bool isLesson; // Distinguish between lessons and other content
  final bool isFullWeekEvent; // For events like lunch, recess that span all days
  final List<WeeklyPlanData> subLessons; // For multiple lessons in one cell

  WeeklyPlanData({
    required this.dayIndex,
    required this.periodIndex,
    this.content = '',
    this.subject = '',
    this.notes = '',
    this.lessonId = '',
    this.date,
    this.isLesson = false,
    this.isFullWeekEvent = false,
    this.subLessons = const [],
  });

  WeeklyPlanData copyWith({
    int? dayIndex,
    int? periodIndex,
    String? content,
    String? subject,
    String? notes,
    String? lessonId,
    DateTime? date,
    bool? isLesson,
    bool? isFullWeekEvent,
    List<WeeklyPlanData>? subLessons,
  }) {
    return WeeklyPlanData(
      dayIndex: dayIndex ?? this.dayIndex,
      periodIndex: periodIndex ?? this.periodIndex,
      content: content ?? this.content,
      subject: subject ?? this.subject,
      notes: notes ?? this.notes,
      lessonId: lessonId ?? this.lessonId,
      date: date ?? this.date,
      isLesson: isLesson ?? this.isLesson,
      isFullWeekEvent: isFullWeekEvent ?? this.isFullWeekEvent,
      subLessons: subLessons ?? this.subLessons,
    );
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