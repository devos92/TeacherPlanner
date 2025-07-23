// lib/pages/event_detail_editor.dart

import 'package:flutter/material.dart';
import 'week_view.dart';
import 'simple_text_editor.dart';

class EventDetailEditor extends StatefulWidget {
  final EventBlock event;
  
  const EventDetailEditor({Key? key, required this.event}) : super(key: key);

  @override
  _EventDetailEditorState createState() => _EventDetailEditorState();
}

class _EventDetailEditorState extends State<EventDetailEditor> {
  final _formKey = GlobalKey<FormState>();
  
  late String _day, _subject, _subtitle, _body;
  late int _startHour, _duration;
  late Color _color;

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
    final ev = widget.event;
    _day = ev.day;
    _subject = ev.subject;
    _subtitle = ev.subtitle;
    _body = ev.body;
    _startHour = ev.startHour;
    _duration = ev.duration;
    _color = ev.color;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final ev = widget.event;
    ev
      ..day = _day
      ..subject = _subject
      ..subtitle = _subtitle
      ..body = _body
      ..startHour = _startHour
      ..duration = _duration
      ..color = _color;
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Event'),
        backgroundColor: _color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _save,
            tooltip: 'Save Changes',
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

              // Schedule Section
              Text('Schedule', style: theme.textTheme.titleLarge),
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
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _day,
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
                              onChanged: (v) => setState(() => _day = v!),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _startHour,
                              decoration: InputDecoration(
                                labelText: 'Start Hour',
                                border: OutlineInputBorder(),
                              ),
                              items: hours
                                  .map(
                                    (h) => DropdownMenuItem(
                                      value: h,
                                      child: Text('$h:00'),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _startHour = v!),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _duration,
                              decoration: InputDecoration(
                                labelText: 'Duration (hours)',
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
                              onChanged: (v) =>
                                  setState(() => _duration = v!),
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'End Time',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  Text(
                                    '${_startHour + _duration}:00',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

              // Details Section
              Text('Event Details', style: theme.textTheme.titleLarge),
              SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Container(
                    height: 300,
                    child: SimpleTextEditor(
                      initialText: _body,
                      onTextChanged: (text) {
                        setState(() {
                          _body = text;
                        });
                      },
                      labelText: 'Add event details, notes, or lesson plan...',
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32),

              // Save Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _save,
                child: Text(
                  'Save Changes',
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