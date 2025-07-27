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
        name: 'Term 1 2024',
        startDate: DateTime(2024, 1, 29), 
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(16), // Reduced padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTermHeader(),
          SizedBox(height: 16), // Reduced spacing
          _buildCalendarGrid(),
        ],
      ),
    );
  }

  Widget _buildTermHeader() {
    return Container(
      padding: EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Term info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTerm!.name.toLowerCase(),
                  style: TextStyle(
                    fontSize: 20, // Smaller font
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[800],
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '${_formatDateRange(_currentTerm!.startDate)} - ${_formatDateRange(_currentTerm!.endDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '${_currentTerm!.weekCount} weeks • ${_currentTerm!.totalDays} teaching days',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Events count
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                Text(
                  '${_termEvents.length}',
                  style: TextStyle(
                    fontSize: 18, // Smaller font
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  'events',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.blue[600],
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8), // Smaller radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCalendarHeader(),
          Divider(height: 0.5, color: Colors.grey[200]),
          ..._buildCalendarWeeks(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    const dayHeaders = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
    
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12), // Reduced padding
      child: Row(
        children: [
          // Week column header
          Container(
            width: 40, // Smaller width
            child: Text(
              'week',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: Colors.grey[500],
                letterSpacing: 0.8,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Day headers
          ...dayHeaders.map((day) => 
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8), // Reduced padding
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.5, color: _getDayHeaderColor(day)), // Thinner line
                  ),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                    letterSpacing: 0.8,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ).toList(),
        ],
      ),
    );
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
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Week number
          Container(
            width: 50,
            height: 100, // Match the day cell height
            child: Center(
              child: Text(
                '${weekIndex + 1}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          // Days - use Expanded with AspectRatio for proper squares
          ...List.generate(5, (dayIndex) {
            final currentDate = weekStart.add(Duration(days: dayIndex));
            final eventsForDay = _getEventsForDate(currentDate);
            
            return Expanded(
              child: AspectRatio(
                aspectRatio: 1.0, // Perfect square ratio
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
        margin: EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: isToday ? dayColor.withOpacity(0.1) : Colors.grey[50],
          border: Border.all(
            color: isToday ? dayColor : Colors.grey[300]!,
            width: isToday ? 2 : 0.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date with ordinal suffix and month
              Row(
                children: [
                  Text(
                    _getOrdinalDate(date.day),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                      color: isToday ? dayColor : Colors.grey[800],
                    ),
                  ),
                  if (isFirstOfMonth) ...[
                    SizedBox(width: 3),
                    Text(
                      _getMonthAbbreviation(date.month),
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 2),
              // Events
              if (events.isNotEmpty) ...[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...events.take(3).map((event) =>
                        Container(
                          width: double.infinity,
                          height: 10,
                          margin: EdgeInsets.only(bottom: 1),
                          padding: EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: event.color.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(
                              color: event.color.withOpacity(0.6),
                              width: 0.5,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              event.title,
                              style: TextStyle(
                                color: event.color.withOpacity(0.9),
                                fontSize: 7,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ).toList(),
                      if (events.length > 3)
                        Text(
                          '+${events.length - 3}',
                          style: TextStyle(
                            fontSize: 6,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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
  final Function(TermEvent) onEventAdded;

  const _AddEventDialog({
    this.selectedDate, // Optional selected date
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
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Term Event'),
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
          child: Text('Add Event'),
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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