/// lib/pages/add_event_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'week_view.dart'; // EventBlock

class AddEventPage extends StatefulWidget {
  final EventBlock? event;
  const AddEventPage({Key? key, this.event}) : super(key: key);

  @override
  _AddEventPageState createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  // core fields
  late String _day;
  late int _startHour;
  late String _subject;
  late Color _color;

  // rich‑text controller
  late quill.QuillController _quillController;

  // pickers data
  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final hours = List.generate(24, (i) => i);
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
    // if editing, prefill; else defaults
    if (widget.event != null) {
      final ev = widget.event!;
      _day = ev.day;
      _startHour = ev.startHour;
      _subject = ev.subject;
      _color = ev.color;
      // initialize quill with existing HTML (we store details as plain Delta)
      _quillController = quill.QuillController(
        document: quill.Document.fromDelta(ev.detailsDelta ?? quill.Delta()),
        selection: TextSelection.collapsed(offset: 0),
      );
    } else {
      _day = 'Mon';
      _startHour = 6;
      _subject = '';
      _color = palette.first;
      _quillController = quill.QuillController.basic();
    }
  }

  @override
  void dispose() {
    _quillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Add Event' : 'Edit Event'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Subject
              TextFormField(
                initialValue: _subject,
                decoration: InputDecoration(labelText: 'Subject'),
                validator: (v) => (v?.isEmpty ?? true) ? 'Enter subject' : null,
                onSaved: (v) => _subject = v!,
              ),
              SizedBox(height: 16),

              // Day picker
              DropdownButtonFormField<String>(
                value: _day,
                decoration: InputDecoration(labelText: 'Day'),
                items: days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => _day = v!),
              ),
              SizedBox(height: 16),

              // Start hour picker
              DropdownButtonFormField<int>(
                value: _startHour,
                decoration: InputDecoration(labelText: 'Start Hour'),
                items: hours
                    .map(
                      (h) => DropdownMenuItem(value: h, child: Text('$h:00')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _startHour = v!),
              ),
              SizedBox(height: 16),

              // Color picker
              Row(
                children: [
                  Text('Color:', style: Theme.of(context).textTheme.bodyLarge),
                  SizedBox(width: 12),
                  Wrap(
                    spacing: 8,
                    children: palette.map((c) {
                      final sel = c == _color;
                      return GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: c,
                            border: Border.all(
                              color: sel ? Colors.black : Colors.grey,
                              width: sel ? 3 : 1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Rich‑text editor toolbar
              quill.QuillToolbar.basic(controller: _quillController),
              SizedBox(height: 8),

              // Rich‑text editor
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: quill.QuillEditor(
                    controller: _quillController,
                    readOnly: false,
                    scrollController: ScrollController(),
                    scrollable: true,
                    focusNode: FocusNode(),
                    autoFocus: false,
                    expands: true,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),

              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Save'),
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  _formKey.currentState!.save();

                  final delta = _quillController.document.toDelta();
                  if (widget.event != null) {
                    // update
                    final ev = widget.event!;
                    ev
                      ..day = _day
                      ..startHour = _startHour
                      ..subject = _subject
                      ..color = _color
                      ..detailsDelta = delta;
                    Navigator.pop(context);
                  } else {
                    // create new
                    final newEv = EventBlock(
                      day: _day,
                      subject: _subject,
                      detailsDelta: delta,
                      color: _color,
                      startHour: _startHour,
                      duration: 1, // default, ignored in day‑detail
                    );
                    Navigator.pop(context, newEv);
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
