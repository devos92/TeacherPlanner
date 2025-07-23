// lib/pages/multi_select_event_page.dart

import 'package:flutter/material.dart';
import 'week_view.dart';

class MultiSelectEventPage extends StatefulWidget {
  const MultiSelectEventPage({Key? key}) : super(key: key);

  @override
  _MultiSelectEventPageState createState() => _MultiSelectEventPageState();
}

class _MultiSelectEventPageState extends State<MultiSelectEventPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Form fields
  late String _subject, _subtitle;
  late Color _color;
  
  // Multi-select data
  List<EventSlot> _eventSlots = [];
  
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final hours = List.generate(24, (i) => i);
  final durations = List.generate(8, (i) => i + 1);
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
    _subject = '';
    _subtitle = '';
    _color = palette.first;
    // Start with one empty slot
    _addEventSlot();
  }

  void _addEventSlot() {
    setState(() {
      _eventSlots.add(EventSlot(
        day: days.first,
        startHour: 9,
        duration: 1,
      ));
    });
  }

  void _removeEventSlot(int index) {
    setState(() {
      _eventSlots.removeAt(index);
    });
  }

  void _updateEventSlot(int index, EventSlot slot) {
    setState(() {
      _eventSlots[index] = slot;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_eventSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add at least one event slot')),
      );
      return;
    }

    // Create events for each slot
    final events = _eventSlots.map((slot) => EventBlock(
      day: slot.day,
      subject: _subject,
      subtitle: _subtitle,
      body: '',
      color: _color,
      startHour: slot.startHour,
      duration: slot.duration,
    )).toList();
    
    Navigator.pop(context, events);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Multi-Select Event'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Create Events',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Event Info Section
              Text('Event Information', style: theme.textTheme.titleLarge),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
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
                      SizedBox(height: 16),
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

              SizedBox(height: 24),

              // Color Section
              Text('Color', style: theme.textTheme.titleLarge),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
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

              SizedBox(height: 24),

              // Event Slots Section
              Row(
                children: [
                  Text('Event Slots', style: theme.textTheme.titleLarge),
                  Spacer(),
                  ElevatedButton.icon(
                    onPressed: _addEventSlot,
                    icon: Icon(Icons.add),
                    label: Text('Add Slot'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _color,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Event slots list
              ..._eventSlots.asMap().entries.map((entry) {
                final index = entry.key;
                final slot = entry.value;
                
                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Slot ${index + 1}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Spacer(),
                            if (_eventSlots.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _removeEventSlot(index),
                                tooltip: 'Remove Slot',
                              ),
                          ],
                        ),
                        SizedBox(height: 12),
                        
                        // Day selection
                        DropdownButtonFormField<String>(
                          value: slot.day,
                          decoration: InputDecoration(
                            labelText: 'Day',
                            border: OutlineInputBorder(),
                          ),
                          items: days
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text(d),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            if (v != null) {
                              _updateEventSlot(index, slot.copyWith(day: v));
                            }
                          },
                        ),
                        SizedBox(height: 12),
                        
                        // Time and duration
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: slot.startHour,
                                decoration: InputDecoration(
                                  labelText: 'Start Time',
                                  border: OutlineInputBorder(),
                                ),
                                items: hours
                                    .map(
                                      (h) => DropdownMenuItem(
                                        value: h,
                                        child: Text('${h.toString().padLeft(2, '0')}:00'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    _updateEventSlot(index, slot.copyWith(startHour: v));
                                  }
                                },
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: slot.duration,
                                decoration: InputDecoration(
                                  labelText: 'Duration',
                                  border: OutlineInputBorder(),
                                ),
                                items: durations
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text('$d hour${d > 1 ? 's' : ''}'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    _updateEventSlot(index, slot.copyWith(duration: v));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                        
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${slot.day} at ${slot.startHour.toString().padLeft(2, '0')}:00 - ${(slot.startHour + slot.duration).toString().padLeft(2, '0')}:00',
                            style: TextStyle(
                              color: _color.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

              SizedBox(height: 32),

              // Summary
              if (_eventSlots.isNotEmpty) ...[
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Summary',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Will create ${_eventSlots.length} event${_eventSlots.length > 1 ? 's' : ''} with different times:',
                          style: theme.textTheme.bodyMedium,
                        ),
                        SizedBox(height: 8),
                        ..._eventSlots.map((slot) => Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            '• ${slot.day}: ${slot.startHour.toString().padLeft(2, '0')}:00 - ${(slot.startHour + slot.duration).toString().padLeft(2, '0')}:00',
                            style: theme.textTheme.bodySmall,
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
              ],

              // Create Events Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  'Create ${_eventSlots.length} Event${_eventSlots.length > 1 ? 's' : ''}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper class for event slots
class EventSlot {
  final String day;
  final int startHour;
  final int duration;

  EventSlot({
    required this.day,
    required this.startHour,
    required this.duration,
  });

  EventSlot copyWith({
    String? day,
    int? startHour,
    int? duration,
  }) {
    return EventSlot(
      day: day ?? this.day,
      startHour: startHour ?? this.startHour,
      duration: duration ?? this.duration,
    );
  }
} 