// lib/widgets/virtual_lesson_cell.dart

import 'package:flutter/material.dart';
import '../models/weekly_plan_data.dart';
import '../models/curriculum_models.dart';
import 'lesson_cell_widgets.dart';

/// Optimized virtual lesson cell that only renders when visible
class VirtualLessonCell extends StatefulWidget {
  final WeeklyPlanData data;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool isVisible;
  final double cellHeight;
  final double cellWidth;

  const VirtualLessonCell({
    Key? key,
    required this.data,
    this.onTap,
    this.onLongPress,
    required this.isVisible,
    required this.cellHeight,
    required this.cellWidth,
  }) : super(key: key);

  @override
  State<VirtualLessonCell> createState() => _VirtualLessonCellState();
}

class _VirtualLessonCellState extends State<VirtualLessonCell> 
    with AutomaticKeepAliveStateMixin {

  @override
  bool get wantKeepAlive => widget.data.isLesson; // Keep lesson cells alive

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveStateMixin

    // Return placeholder if not visible (for virtual scrolling)
    if (!widget.isVisible) {
      return SizedBox(
        height: widget.cellHeight,
        width: widget.cellWidth,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.cellHeight,
      width: widget.cellWidth,
      child: LessonCellWidget(
        data: widget.data,
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
      ),
    );
  }
}

/// Virtual grid builder for optimized rendering of lesson cells
class VirtualLessonGrid extends StatefulWidget {
  final List<WeeklyPlanData> planData;
  final int periods;
  final bool isVerticalLayout;
  final Function(WeeklyPlanData) onCellTap;
  final Function(WeeklyPlanData) onCellLongPress;
  final ScrollController? scrollController;

  const VirtualLessonGrid({
    Key? key,
    required this.planData,
    required this.periods,
    required this.isVerticalLayout,
    required this.onCellTap,
    required this.onCellLongPress,
    this.scrollController,
  }) : super(key: key);

  @override
  State<VirtualLessonGrid> createState() => _VirtualLessonGridState();
}

class _VirtualLessonGridState extends State<VirtualLessonGrid> {
  late ScrollController _scrollController;
  final Set<int> _visibleIndices = <int>{};

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    _scrollController.addListener(_updateVisibleIndices);
    
    // Initialize visible indices
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateVisibleIndices();
    });
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    } else {
      _scrollController.removeListener(_updateVisibleIndices);
    }
    super.dispose();
  }

  void _updateVisibleIndices() {
    if (!_scrollController.hasClients) return;

    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final viewportHeight = renderBox.size.height;
    final scrollOffset = _scrollController.offset;
    
    // Calculate cell dimensions
    final cellHeight = widget.isVerticalLayout ? 80.0 : 120.0;
    final totalCells = widget.periods * 5; // 5 days per week
    
    // Calculate visible range with buffer
    final buffer = 2; // Load 2 cells above/below viewport
    final startIndex = ((scrollOffset / cellHeight) - buffer).floor().clamp(0, totalCells);
    final endIndex = (((scrollOffset + viewportHeight) / cellHeight) + buffer).ceil().clamp(0, totalCells);
    
    final newVisibleIndices = <int>{};
    for (int i = startIndex; i < endIndex; i++) {
      newVisibleIndices.add(i);
    }
    
    if (newVisibleIndices.length != _visibleIndices.length || 
        !newVisibleIndices.every(_visibleIndices.contains)) {
      setState(() {
        _visibleIndices.clear();
        _visibleIndices.addAll(newVisibleIndices);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVerticalLayout) {
      return _buildVerticalGrid();
    } else {
      return _buildHorizontalGrid();
    }
  }

  Widget _buildVerticalGrid() {
    return Column(
      children: [
        // Header row
        _buildHeaderRow(),
        // Period rows with virtual scrolling
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.periods,
            itemBuilder: (context, periodIndex) {
              return _buildPeriodRow(periodIndex);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalGrid() {
    return Row(
      children: List.generate(5, (dayIndex) => 
        Expanded(child: _buildDayColumn(dayIndex))
      ),
    );
  }

  Widget _buildHeaderRow() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    return Container(
      height: 40,
      child: Row(
        children: [
          Container(width: 60), // Period label space
          ...days.map((day) => Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Text(
                day,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildPeriodRow(int periodIndex) {
    return Container(
      height: 80,
      child: Row(
        children: [
          // Period label
          Container(
            width: 60,
            alignment: Alignment.center,
            child: Text(
              'P${periodIndex + 1}',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          // Day cells
          ...List.generate(5, (dayIndex) {
            final cellIndex = periodIndex * 5 + dayIndex;
            final isVisible = _visibleIndices.contains(cellIndex);
            
            final data = widget.planData.firstWhere(
              (d) => d.dayIndex == dayIndex && d.periodIndex == periodIndex,
              orElse: () => WeeklyPlanData(
                dayIndex: dayIndex,
                periodIndex: periodIndex,
                content: '',
                subject: '',
                notes: '',
                lessonId: '',
                date: null,
                isLesson: false,
                isFullWeekEvent: false,
              ),
            );

            return Expanded(
              child: VirtualLessonCell(
                data: data,
                isVisible: isVisible,
                cellHeight: 80,
                cellWidth: double.infinity,
                onTap: () => widget.onCellTap(data),
                onLongPress: () => widget.onCellLongPress(data),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayColumn(int dayIndex) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    
    return Column(
      children: [
        // Day header
        Container(
          height: 40,
          alignment: Alignment.center,
          child: Text(
            days[dayIndex],
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        // Period cells
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            itemCount: widget.periods,
            itemBuilder: (context, periodIndex) {
              final cellIndex = periodIndex * 5 + dayIndex;
              final isVisible = _visibleIndices.contains(cellIndex);
              
              final data = widget.planData.firstWhere(
                (d) => d.dayIndex == dayIndex && d.periodIndex == periodIndex,
                orElse: () => WeeklyPlanData(
                  dayIndex: dayIndex,
                  periodIndex: periodIndex,
                  content: '',
                  subject: '',
                  notes: '',
                  lessonId: '',
                  date: null,
                  isLesson: false,
                  isFullWeekEvent: false,
                ),
              );

              return VirtualLessonCell(
                data: data,
                isVisible: isVisible,
                cellHeight: 120,
                cellWidth: double.infinity,
                onTap: () => widget.onCellTap(data),
                onLongPress: () => widget.onCellLongPress(data),
              );
            },
          ),
        ),
      ],
    );
  }
}