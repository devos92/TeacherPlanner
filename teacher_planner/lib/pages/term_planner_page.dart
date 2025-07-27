// lib/pages/term_planner_page.dart

import 'package:flutter/material.dart';
import '../models/term_models.dart';

class TermPlannerPage extends StatefulWidget {
  const TermPlannerPage({Key? key}) : super(key: key);

  @override
  _TermPlannerPageState createState() => _TermPlannerPageState();
}

class _TermPlannerPageState extends State<TermPlannerPage> {
  Term? _currentTerm;
  List<TermEvent> _termEvents = [];
  bool _isEditingTerm = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTerm();
  }

  void _loadCurrentTerm() {
    // TODO: Load from storage
    // For now, create a sample term for testing
    setState(() {
      _currentTerm = Term(
        id: '1',
        name: 'Term 1', // Removed year from name
        startDate: DateTime(2025, 1, 27), // Updated to 2025 and Monday Jan 27, 2025
        weekCount: 10,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentTerm?.name ?? 'Term Planner'),
        actions: [
          if (_currentTerm != null) ...[
            IconButton(
              icon: Icon(Icons.add_circle_outline),
              onPressed: _showAddEventDialog,
              tooltip: 'Add Term Event',
            ),
          ],
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showTermSetupDialog,
            tooltip: 'Term Settings',
          ),
        ],
      ),
      body: _currentTerm == null ? _buildTermSetup() : _buildTermCalendar(),
    );
  }

  Widget _buildTermSetup() {
    return Center(
      child: Card(
        margin: EdgeInsets.all(32),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text(
                'Set Up Your Term',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'Configure your term dates and duration',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: _showTermSetupDialog,
                child: Text('Create New Term'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermCalendar() {
    if (_currentTerm == null) return SizedBox.shrink();

    // Get screen information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final isDesktop = screenWidth > 1200;
    final isTablet = screenWidth > 768 && screenWidth <= 1200;
    
    // Responsive padding and constraints
    double horizontalPadding;
    double? maxWidth;
    
    if (isDesktop) {
      // On desktop, use more moderate padding and no max width constraint
      horizontalPadding = screenWidth * 0.08; // 8% padding on each side
      maxWidth = null; // Allow full width
    } else if (isTablet) {
      horizontalPadding = 24;
      maxWidth = 1000;
    } else {
      // Mobile
      horizontalPadding = 16;
      maxWidth = null;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      child: Container(
        constraints: maxWidth != null ? BoxConstraints(maxWidth: maxWidth) : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildCalendarHeader(),
            _buildDayHeaders(),
            ..._buildCalendarContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _getTermName(), // Just the term name (e.g., "Term 1")
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.grey[800],
              letterSpacing: 1.0,
            ),
          ),
          Text(
            '${_currentTerm!.startDate.year}', // Year from the term's start date
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Colors.grey[800],
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  String _getTermName() {
    // Extract just the term part (e.g., "Term 1" from "Term 1 2024")
    final name = _currentTerm!.name;
    final parts = name.split(' ');
    if (parts.length >= 2 && parts[1].length == 4 && int.tryParse(parts[1]) != null) {
      // If second part is a year, remove it
      return parts.sublist(0, parts.length - 1).join(' ');
    }
    return name; // Return as-is if no year found
  }

  Widget _buildDayHeaders() {
    const dayHeaders = ['MON', 'TUE', 'WED', 'THU', 'FRI'];
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          // Empty space for month column
          Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey[300]!, width: 1),
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
          ),
          // Day headers
          ...dayHeaders.asMap().entries.map((entry) {
            int index = entry.key;
            String day = entry.value;
            bool isLast = index == dayHeaders.length - 1;
            
            return Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey[300]!, width: 1), // Keep all right borders
                    bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                  ),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<Widget> _buildCalendarContent() {
    List<Widget> content = [];
    DateTime currentDate = _currentTerm!.startDate;
    String? currentMonth;
    int weekNumber = 1;
    
    // Generate content week by week instead of month by month
    for (int week = 0; week < _currentTerm!.weekCount; week++) {
      DateTime weekStart = _currentTerm!.startDate.add(Duration(days: week * 7));
      
      // Check if we need a new month section
      String monthName = _getFullMonthName(weekStart.month);
      if (monthName != currentMonth) {
        currentMonth = monthName;
        content.add(_buildMonthSection(monthName, weekStart, week + 1));
      } else {
        // Regular week row without month section
        content.add(_buildWeekRow(weekStart, week + 1));
      }
    }
    
    return content;
  }

  Widget _buildMonthSection(String monthName, DateTime startDate, int weekNumber) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1), // Make bottom border consistent
        ),
      ),
      child: Row(
        children: [
          // Month name
          Container(
            width: 80,
            height: 100, // Square cells
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(
                top: BorderSide(color: Colors.grey[300]!, width: 1),
                left: BorderSide(color: Colors.grey[300]!, width: 1),
                right: BorderSide(color: Colors.grey[300]!, width: 1),
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
            child: Center(
              child: RotatedBox(
                quarterTurns: 3, // Rotate text 90 degrees
                child: Text(
                  monthName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
          ),
          // Week cells for this month start
          ...List.generate(5, (dayIndex) {
            DateTime cellDate = startDate.add(Duration(days: dayIndex));
            List<TermEvent> eventsForDay = _getEventsForDate(cellDate);
            bool isFirstDay = dayIndex == 0;
            
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1.0, // Force perfect squares
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!, width: 1),
                      right: BorderSide(color: Colors.grey[300]!, width: 1), // Keep all right borders
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: _buildCalendarCell(
                    date: cellDate,
                    events: eventsForDay,
                    showWeekNumber: isFirstDay,
                    weekNumber: isFirstDay ? weekNumber : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildWeekRow(DateTime startDate, int weekNumber) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1), // Make bottom border consistent
        ),
      ),
      child: Row(
        children: [
          // Empty month space
          Container(
            width: 80,
            height: 100, // Square cells
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: Colors.grey[300]!, width: 1),
                right: BorderSide(color: Colors.grey[300]!, width: 1),
                bottom: BorderSide(color: Colors.grey[300]!, width: 1),
              ),
            ),
          ),
          // Week days
          ...List.generate(5, (dayIndex) {
            DateTime cellDate = startDate.add(Duration(days: dayIndex));
            List<TermEvent> eventsForDay = _getEventsForDate(cellDate);
            bool isFirstDay = dayIndex == 0;
            
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1.0, // Force perfect squares
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey[300]!, width: 1), // Keep all right borders
                      bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                    ),
                  ),
                  child: _buildCalendarCell(
                    date: cellDate,
                    events: eventsForDay,
                    showWeekNumber: isFirstDay,
                    weekNumber: isFirstDay ? weekNumber : null,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalendarCell({
    required DateTime date,
    required List<TermEvent> events,
    bool showWeekNumber = false,
    int? weekNumber,
  }) {
    final isToday = _isToday(date);
    
    return GestureDetector(
      onTap: () => _showAddEventForDate(date),
      onLongPress: () => _showWeekNavigation(weekNumber), // Navigate to week view
      child: Container(
        decoration: BoxDecoration(
          color: events.isNotEmpty 
            ? events.first.color.withOpacity(0.15)
            : (isToday ? Colors.blue.withOpacity(0.1) : Colors.white),
          // Removed individual cell borders since they're now handled by the parent containers
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Week number at the top (if this is the first day of the week)
              if (showWeekNumber && weekNumber != null) ...[
                GestureDetector(
                  onTap: () => _showWeekNavigation(weekNumber),
                  child: Text(
                    'Week $weekNumber',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                SizedBox(height: 2),
              ],
              
              // Date
              Text(
                '${date.day}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                  color: events.isNotEmpty 
                    ? events.first.color
                    : (isToday ? Colors.blue : Colors.grey[800]),
                ),
              ),
              
              // Event content
              if (events.isNotEmpty) ...[
                SizedBox(height: 4),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _showEventOptions(events.first),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: events.first.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: events.first.color.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            events.first.title,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: events.first.color,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (events.length > 1) ...[
                            SizedBox(height: 2),
                            Text(
                              '+${events.length - 1}',
                              style: TextStyle(
                                fontSize: 8,
                                color: events.first.color.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getFullMonthName(int month) {
    const months = [
      'JANUARY', 'FEBRUARY', 'MARCH', 'APRIL', 'MAY', 'JUNE',
      'JULY', 'AUGUST', 'SEPTEMBER', 'OCTOBER', 'NOVEMBER', 'DECEMBER'
    ];
    return months[month - 1];
  }

  Color _getDayHeaderColor(String day) {
    const colors = [
      Color(0xFF4CAF50), // Monday - Green
      Color(0xFF2196F3), // Tuesday - Blue  
      Color(0xFFFF9800), // Wednesday - Orange
      Color(0xFF9C27B0), // Thursday - Purple
      Color(0xFFE91E63), // Friday - Pink
    ];
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    return colors[days.indexOf(day)];
  }

  List<Widget> _buildCalendarWeeks() {
    List<Widget> weeks = [];
    
    for (int weekIndex = 0; weekIndex < _currentTerm!.weekCount; weekIndex++) {
      weeks.add(_buildCalendarWeek(weekIndex));
      if (weekIndex < _currentTerm!.weekCount - 1) {
        weeks.add(Divider(height: 0.5, color: Colors.grey[100]));
      }
    }
    
    return weeks;
  }

  Widget _buildCalendarWeek(int weekIndex) {
    final weekStart = _currentTerm!.startDate.add(Duration(days: weekIndex * 7));
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8), // Reduced padding
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week number
          Container(
            width: 40, // Smaller width
            height: 80, // Smaller height
            child: Center(
              child: Text(
                '${weekIndex + 1}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          // Days - smaller squares
          ...List.generate(5, (dayIndex) {
            final currentDate = weekStart.add(Duration(days: dayIndex));
            final eventsForDay = _getEventsForDate(currentDate);
            
            return Expanded(
              child: Container(
                height: 80, // Fixed smaller height
                margin: EdgeInsets.all(1),
                child: _buildCalendarDay(
                  date: currentDate,
                  weekIndex: weekIndex,
                  dayIndex: dayIndex,
                  events: eventsForDay,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCalendarDay({
    required DateTime date,
    required int weekIndex,
    required int dayIndex,
    required List<TermEvent> events,
  }) {
    final isToday = _isToday(date);
    final dayColor = _getDayColor(dayIndex);
    final isFirstOfMonth = date.day == 1;
    
    return GestureDetector(
      onTap: () => _showAddEventForDate(date),
      child: Container(
        decoration: BoxDecoration(
          color: isToday ? dayColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isToday ? dayColor : Colors.grey[300]!,
            width: isToday ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: events.isEmpty 
          ? _buildEmptyDay(date, isToday, dayColor, isFirstOfMonth)
          : _buildDayWithEvents(date, isToday, dayColor, isFirstOfMonth, events),
      ),
    );
  }

  Widget _buildEmptyDay(DateTime date, bool isToday, Color dayColor, bool isFirstOfMonth) {
    return Padding(
      padding: EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getOrdinalDate(date.day),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                  color: isToday ? dayColor : Colors.grey[800],
                ),
              ),
              if (isFirstOfMonth) ...[
                SizedBox(width: 2),
                Text(
                  _getMonthAbbreviation(date.month),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDayWithEvents(DateTime date, bool isToday, Color dayColor, bool isFirstOfMonth, List<TermEvent> events) {
    final primaryEvent = events.first;
    
    return Container(
      decoration: BoxDecoration(
        color: primaryEvent.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: primaryEvent.color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date in top corner
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      _getOrdinalDate(date.day),
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: primaryEvent.color.withOpacity(0.8),
                      ),
                    ),
                    if (isFirstOfMonth) ...[
                      SizedBox(width: 2),
                      Text(
                        _getMonthAbbreviation(date.month),
                        style: TextStyle(
                          fontSize: 7,
                          fontWeight: FontWeight.w500,
                          color: primaryEvent.color.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ],
                ),
                if (events.length > 1)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: primaryEvent.color.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '+${events.length - 1}',
                      style: TextStyle(
                        fontSize: 7,
                        fontWeight: FontWeight.w600,
                        color: primaryEvent.color,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 4),
            // Event title - bigger and centered
            Expanded(
              child: Center(
                child: Text(
                  primaryEvent.title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: primaryEvent.color,
                    height: 1.1,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getDayColor(int dayIndex) {
    const colors = [
      Color(0xFF4CAF50), // Monday - Green
      Color(0xFF2196F3), // Tuesday - Blue  
      Color(0xFFFF9800), // Wednesday - Orange
      Color(0xFF9C27B0), // Thursday - Purple
      Color(0xFFE91E63), // Friday - Pink
    ];
    return colors[dayIndex];
  }

  String _formatDateRange(DateTime date) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _getOrdinalDate(int day) {
    if (day >= 11 && day <= 13) {
      return '${day}th';
    }
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }

  String _getMonthAbbreviation(int month) {
    const months = [
      'jan', 'feb', 'mar', 'apr', 'may', 'jun',
      'jul', 'aug', 'sep', 'oct', 'nov', 'dec'
    ];
    return months[month - 1];
  }

  List<TermEvent> _getEventsForDate(DateTime date) {
    return _termEvents.where((event) {
      return event.startDate.year == date.year &&
             event.startDate.month == date.month &&
             event.startDate.day == date.day;
    }).toList();
  }

  bool _isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  void _showTermSetupDialog() {
    showDialog(
      context: context,
      builder: (context) => _TermSetupDialog(
        existingTerm: _currentTerm,
        onTermCreated: (term) {
          setState(() {
            _currentTerm = term;
          });
        },
      ),
    );
  }

  void _showAddEventDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddEventDialog(
        onEventAdded: (event) {
          setState(() {
            _termEvents.add(event);
          });
        },
      ),
    );
  }

  void _showAddEventForDate(DateTime date) {
    showDialog(
      context: context,
      builder: (context) => _AddEventDialog(
        selectedDate: date,
        onEventAdded: (event) {
          setState(() {
            _termEvents.add(event);
          });
        },
      ),
    );
  }

  void _showWeekNavigation(int? weekNumber) {
    if (weekNumber == null || _currentTerm == null) return;
    
    // Calculate the week start date
    final weekStartDate = _currentTerm!.startDate.add(Duration(days: (weekNumber - 1) * 7));
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Navigate to Week $weekNumber'),
        content: Text('Go to Week $weekNumber in the weekly planner?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to WeekView with the specific week and term events
              // This will be easier when database is wired up
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Week navigation will be implemented with database integration'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Go to Week'),
          ),
        ],
      ),
    );
  }

  void _showEventOptions(TermEvent event) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Event title
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 16),
            
            Text(
              event.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            if (event.description.isNotEmpty) ...[
              SizedBox(height: 8),
              Text(
                event.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            
            SizedBox(height: 24),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _editEvent(event);
                    },
                    icon: Icon(Icons.edit, size: 18),
                    label: Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteEvent(event);
                    },
                    icon: Icon(Icons.delete, size: 18),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _editEvent(TermEvent event) {
    showDialog(
      context: context,
      builder: (context) => _AddEventDialog(
        selectedDate: event.startDate,
        existingEvent: event,
        onEventAdded: (updatedEvent) {
          setState(() {
            final index = _termEvents.indexWhere((e) => e.id == event.id);
            if (index != -1) {
              _termEvents[index] = updatedEvent;
            }
          });
        },
      ),
    );
  }

  void _deleteEvent(TermEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _termEvents.removeWhere((e) => e.id == event.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event deleted'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 2),
                ),
              );
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
  }
}

// Term Setup Dialog
class _TermSetupDialog extends StatefulWidget {
  final Term? existingTerm;
  final Function(Term) onTermCreated;

  const _TermSetupDialog({
    required this.existingTerm,
    required this.onTermCreated,
  });

  @override
  State<_TermSetupDialog> createState() => _TermSetupDialogState();
}

class _TermSetupDialogState extends State<_TermSetupDialog> {
  final _nameController = TextEditingController();
  DateTime? _startDate;
  int _weekCount = 10;

  @override
  void initState() {
    super.initState();
    if (widget.existingTerm != null) {
      _nameController.text = widget.existingTerm!.name;
      _startDate = widget.existingTerm!.startDate;
      _weekCount = widget.existingTerm!.weekCount;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingTerm == null ? 'Create Term' : 'Edit Term'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Term Name',
                hintText: 'e.g. Term 1 2024',
              ),
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('First Day of Term'),
              subtitle: Text(_startDate == null ? 'Select date' : _formatDate(_startDate!)),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectStartDate,
            ),
            SizedBox(height: 16),
            Text('Number of Weeks: $_weekCount'),
            Slider(
              value: _weekCount.toDouble(),
              min: 8,
              max: 12,
              divisions: 4,
              label: '$_weekCount weeks',
              onChanged: (value) {
                setState(() {
                  _weekCount = value.round();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canCreate() ? _createTerm : null,
          child: Text(widget.existingTerm == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  bool _canCreate() {
    return _nameController.text.trim().isNotEmpty && _startDate != null;
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (date != null) {
      // Ensure it's a Monday
      final monday = date.subtract(Duration(days: date.weekday - 1));
      setState(() {
        _startDate = monday;
      });
    }
  }

  void _createTerm() {
    final term = Term(
      id: widget.existingTerm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      startDate: _startDate!,
      weekCount: _weekCount,
    );
    
    widget.onTermCreated(term);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Add Event Dialog
class _AddEventDialog extends StatefulWidget {
  final DateTime? selectedDate; // Add selected date parameter
  final TermEvent? existingEvent; // Add existing event parameter
  final Function(TermEvent) onEventAdded;

  const _AddEventDialog({
    this.selectedDate, // Optional selected date
    this.existingEvent, // Optional existing event
    required this.onEventAdded,
  });

  @override
  State<_AddEventDialog> createState() => _AddEventDialogState();
}

class _AddEventDialogState extends State<_AddEventDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _startDate;
  TermEventType _eventType = TermEventType.schoolEvent;
  Color _eventColor = Colors.blue;

  @override
  void initState() {
    super.initState();
    // Pre-fill the date if provided
    _startDate = widget.selectedDate;
    if (_startDate != null) {
      _eventColor = _eventType.defaultColor;
    }
    if (widget.existingEvent != null) {
      _titleController.text = widget.existingEvent!.title;
      _descriptionController.text = widget.existingEvent!.description;
      _startDate = widget.existingEvent!.startDate;
      _eventType = widget.existingEvent!.type;
      _eventColor = widget.existingEvent!.color;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existingEvent == null ? 'Add Term Event' : 'Edit Term Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                hintText: 'e.g. Public Holiday',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
              ),
              maxLines: 2,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<TermEventType>(
              value: _eventType,
              decoration: InputDecoration(labelText: 'Event Type'),
              items: TermEventType.values.map((type) =>
                DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _eventType = value!;
                  _eventColor = value.defaultColor;
                });
              },
            ),
            SizedBox(height: 16),
            ListTile(
              title: Text('Date'),
              subtitle: Text(_startDate == null ? 'Select date' : _formatDate(_startDate!)),
              trailing: Icon(Icons.calendar_today),
              onTap: _selectDate,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canCreate() ? _createEvent : null,
          child: Text(widget.existingEvent == null ? 'Add Event' : 'Update Event'),
        ),
      ],
    );
  }

  bool _canCreate() {
    return _titleController.text.trim().isNotEmpty && _startDate != null;
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }

  void _createEvent() {
    final event = TermEvent(
      id: widget.existingEvent?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      startDate: _startDate!,
      // No endDate - single day event
      type: _eventType,
      color: _eventColor,
    );
    
    widget.onEventAdded(event);
    Navigator.pop(context);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
} 