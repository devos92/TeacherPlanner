import 'package:flutter/material.dart';
import 'week_view.dart';

class AddEventPage extends StatefulWidget {
  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();
  String _day = 'Mon';
  int _startHour = 6;
  int _duration = 1;
  String _subject = '';
  Color _color = Colors.blue;

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<int> hours = List.generate(24, (i) => i);
  final List<int> durations = List.generate(8, (i) => i + 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Subject'),
                onSaved: (v) => _subject = v ?? '',
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter subject' : null,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Day'),
                value: _day,
                items: days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _day = v!),
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Start Hour'),
                value: _startHour,
                items: hours
                    .map(
                      (h) => DropdownMenuItem(value: h, child: Text('$h:00')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _startHour = v!),
              ),
              DropdownButtonFormField<int>(
                decoration: InputDecoration(labelText: 'Duration (hours)'),
                value: _duration,
                items: durations
                    .map((d) => DropdownMenuItem(value: d, child: Text('$d')))
                    .toList(),
                onChanged: (v) => setState(() => _duration = v!),
              ),
              SizedBox(height: 16),
              Text('Color'),
              Wrap(
                spacing: 8,
                children:
                    [
                          Colors.blue,
                          Colors.red,
                          Colors.green,
                          Colors.orange,
                          Colors.purple,
                        ]
                        .map(
                          (c) => GestureDetector(
                            onTap: () => setState(() => _color = c),
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: c,
                                border: Border.all(
                                  color: _color == c
                                      ? Colors.black
                                      : Colors.white,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    final newEvent = EventBlock(
                      day: _day,
                      subject: _subject,
                      startHour: _startHour,
                      duration: _duration,
                      color: _color,
                    );
                    Navigator.pop(context, newEvent);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
