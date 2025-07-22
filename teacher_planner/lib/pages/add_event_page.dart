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
  late String _day, _subject, _subtitle, _body;
  late int _startHour, _duration;
  late Color _color;

  late TextEditingController _bodyController;

  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final hours = List.generate(24, (i) => i);
  final durations = List.generate(8, (i) => i + 1);
  final palette = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      final ev = widget.event!;
      _day = ev.day;
      _subject = ev.subject;
      _subtitle = ev.subtitle;
      _body = ev.body;
      _startHour = ev.startHour;
      _duration = ev.duration;
      _color = ev.color;
    } else {
      _day = days.first;
      _subject = '';
      _subtitle = '';
      _body = '';
      _startHour = hours.first;
      _duration = durations.first;
      _color = palette.first;
    }
    _bodyController = TextEditingController(text: _body);
  }

  void _save() {
    _body = _bodyController.text;
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.event != null) {
      final ev = widget.event!;
      ev
        ..day = _day
        ..subject = _subject
        ..subtitle = _subtitle
        ..body = _body
        ..startHour = _startHour
        ..duration = _duration
        ..color = _color;
      Navigator.pop(context);
    } else {
      Navigator.pop(
        context,
        EventBlock(
          day: _day,
          subject: _subject,
          subtitle: _subtitle,
          body: _body,
          color: _color,
          startHour: _startHour,
          duration: _duration,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext ctx) {
    final theme = Theme.of(ctx);
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
                    // Section: Lesson Info
                    Text('Lesson Info', style: theme.textTheme.headline6),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
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
                            const SizedBox(height: 12),
                            TextFormField(
                              initialValue: _subtitle,
                              decoration: InputDecoration(
                                labelText: 'Subtitle',
                                border: OutlineInputBorder(),
                              ),
                              onSaved: (v) => _subtitle = v ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section: Schedule
                    Text('Schedule', style: theme.textTheme.subtitle1),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Day
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
                            const SizedBox(width: 8),
                            // Start Hour
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
                            const SizedBox(width: 8),
                            // Duration
                            Expanded(
                              child: DropdownButtonFormField<int>(
                                value: _duration,
                                decoration: InputDecoration(
                                  labelText: 'Duration',
                                  border: OutlineInputBorder(),
                                ),
                                items: durations
                                    .map(
                                      (d) => DropdownMenuItem(
                                        value: d,
                                        child: Text('$d h'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) =>
                                    setState(() => _duration = v!),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section: Details
                    Text('Details', style: theme.textTheme.subtitle1),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: TextFormField(
                          controller: _bodyController,
                          decoration: InputDecoration(
                            labelText: 'Lesson plan details',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 6,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Section: Color
                    Text('Color', style: theme.textTheme.subtitle1),
                    const SizedBox(height: 8),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Wrap(
                          spacing: 12,
                          children: palette.map((c) {
                            final selected = c == _color;
                            return GestureDetector(
                              onTap: () => setState(() => _color = c),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: c,
                                  border: Border.all(
                                    color: selected
                                        ? Colors.black
                                        : Colors.white,
                                    width: selected ? 3 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _save,
                      child: Text(
                        'Save Lesson',
                        style: TextStyle(fontSize: 16),
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
