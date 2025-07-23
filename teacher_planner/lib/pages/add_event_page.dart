// lib/pages/add_event_page.dart

import 'package:flutter/material.dart';
import 'week_view.dart';

class AddEventPage extends StatefulWidget {
  final EventBlock? event;
  const AddEventPage({Key? key, this.event}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  late String _subject, _subtitle;
  late Color _color;
  late int _startHour, _finishHour;
  late int _startMinute, _finishMinute; // Add minute fields
  
  // Multi-day selection
  Map<String, bool> _selectedDays = {
    'Mon': false,
    'Tue': false,
    'Wed': false,
    'Thu': false,
    'Fri': false,
  };

  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final palette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final ev = widget.event!;
      _subject = ev.subject;
      _subtitle = ev.subtitle;
      _color = ev.color;
      _startHour = ev.startHour;
      _startMinute = ev.startMinute;
      _finishHour = ev.finishHour;
      _finishMinute = ev.finishMinute;
      // For editing, select the current day
      _selectedDays[ev.day] = true;
    } else {
      _subject = '';
      _subtitle = '';
      _color = palette.first;
      _startHour = 9; // Default to 9 AM
      _startMinute = 0; // Default to 0 minutes
      _finishHour = 10; // Default to 10 AM
      _finishMinute = 0; // Default to 0 minutes
      // Default to Wednesday selected
      _selectedDays['Wed'] = true;
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Validate finish time is after start time
    final startMinutes = _startHour * 60 + _startMinute;
    final finishMinutes = _finishHour * 60 + _finishMinute;
    
    if (finishMinutes <= startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Finish time must be after start time')),
      );
      return;
    }

    // Validate minimum duration of 15 minutes
    final duration = finishMinutes - startMinutes;
    if (duration < 15) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Events must be at least 15 minutes long')),
      );
      return;
    }

    // Get selected days
    final selectedDays = _selectedDays.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    if (widget.event != null) {
      final ev = widget.event!;
      ev
        ..subject = _subject
        ..subtitle = _subtitle
        ..color = _color
        ..startHour = _startHour
        ..startMinute = _startMinute
        ..finishHour = _finishHour
        ..finishMinute = _finishMinute;
      Navigator.pop(context);
    } else {
      // Create multiple events for selected days
      final events = selectedDays.map((day) => EventBlock(
        day: day,
        subject: _subject,
        subtitle: _subtitle,
        body: '',
        color: _color,
        startHour: _startHour,
        startMinute: _startMinute,
        finishHour: _finishHour,
        finishMinute: _finishMinute,
      )).toList();
      
      Navigator.pop(context, events);
    }
  }

  void _toggleDay(String day) {
    setState(() {
      _selectedDays[day] = !_selectedDays[day]!;
    });
  }

  void _selectAllDays() {
    setState(() {
      _selectedDays.updateAll((key, value) => true);
    });
  }

  void _clearAllDays() {
    setState(() {
      _selectedDays.updateAll((key, value) => false);
    });
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
    final selectedDaysCount = _selectedDays.values.where((selected) => selected).length;
    
    return Container(
      height: MediaQuery.of(ctx).size.height * 0.8,
      decoration: BoxDecoration(
        color: theme.dialogBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          // Drag handle
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Section: Event Info
                    Text('Event Info', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            TextFormField(
                              initialValue: _subject,
                              decoration: InputDecoration(
                                labelText: 'Title',
                                border: OutlineInputBorder(),
                              ),
                              validator: (v) =>
                                  v == null || v.isEmpty ? 'Required' : null,
                              onSaved: (v) => _subject = v!,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              initialValue: _subtitle,
                              decoration: InputDecoration(
                                labelText: 'Subtitle (Optional)',
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (v) => _subtitle = v ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Section: Schedule
                    Text('Schedule', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Days selection
                            Row(
                              children: [
                                Text('Days:', style: theme.textTheme.titleMedium),
                                Spacer(),
                                TextButton(
                                  onPressed: _selectAllDays,
                                  child: Text('Select All'),
                                ),
                                TextButton(
                                  onPressed: _clearAllDays,
                                  child: Text('Clear All'),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: days.map((day) {
                                final isSelected = _selectedDays[day]!;
                                return FilterChip(
                                  label: Text(day),
                                  selected: isSelected,
                                  onSelected: (selected) => _toggleDay(day),
                                  selectedColor: _color.withOpacity(0.2),
                                  checkmarkColor: _color,
                                  backgroundColor: Colors.grey.shade200,
                                );
                              }).toList(),
                            ),
                            SizedBox(height: 16),
                            
                            // Time selection
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _startHour.toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Start Hour (0-23)',
                                      border: OutlineInputBorder(),
                                      helperText: 'Enter hour (0-23)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final hour = int.tryParse(v);
                                      if (hour == null || hour < 0 || hour > 23) {
                                        return 'Enter 0-23';
                                      }
                                      return null;
                                    },
                                    onSaved: (v) => _startHour = int.parse(v!),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _startMinute.toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Start Minute (0-59)',
                                      border: OutlineInputBorder(),
                                      helperText: 'Enter minute (0-59)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final minute = int.tryParse(v);
                                      if (minute == null || minute < 0 || minute > 59) {
                                        return 'Enter 0-59';
                                      }
                                      return null;
                                    },
                                    onSaved: (v) => _startMinute = int.parse(v!),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _finishHour.toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Finish Hour (0-23)',
                                      border: OutlineInputBorder(),
                                      helperText: 'Enter hour (0-23)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final hour = int.tryParse(v);
                                      if (hour == null || hour < 0 || hour > 23) {
                                        return 'Enter 0-23';
                                      }
                                      return null;
                                    },
                                    onSaved: (v) => _finishHour = int.parse(v!),
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _finishMinute.toString(),
                                    decoration: InputDecoration(
                                      labelText: 'Finish Minute (0-59)',
                                      border: OutlineInputBorder(),
                                      helperText: 'Enter minute (0-59)',
                                    ),
                                    keyboardType: TextInputType.number,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return 'Required';
                                      final minute = int.tryParse(v);
                                      if (minute == null || minute < 0 || minute > 59) {
                                        return 'Enter 0-59';
                                      }
                                      return null;
                                    },
                                    onSaved: (v) => _finishMinute = int.parse(v!),
                                  ),
                                ),
                              ],
                            ),
                            
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                                  SizedBox(width: 8),
                                  Text(
                                    'Time: ${_startHour.toString().padLeft(2, '0')}:${_startMinute.toString().padLeft(2, '0')} - ${_finishHour.toString().padLeft(2, '0')}:${_finishMinute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            if (selectedDaysCount > 0) ...[
                              SizedBox(height: 16),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: _color.withOpacity(0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline, color: _color),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Will create $selectedDaysCount event${selectedDaysCount > 1 ? 's' : ''} for selected day${selectedDaysCount > 1 ? 's' : ''}',
                                        style: TextStyle(color: _color.withOpacity(0.8)),
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

                    const SizedBox(height: 24),

                    // Section: Color
                    Text('Color', style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: palette.map((c) {
                            final selected = c == _color;
                            return GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: c,
                                  border: Border.all(
                                    color: selected
                                        ? Colors.black
                                        : Colors.white,
                                    width: selected ? 3 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: selected
                                    ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : null,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _save,
                      child: Text(
                        widget.event != null ? 'Update Event' : 'Create Events',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(ctx).viewInsets.bottom + 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
