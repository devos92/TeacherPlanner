// lib/pages/add_event_page.dart

import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
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
  late String _day;
  late String _subject;
  late String _subtitle;
  late String _body;
  late int _startHour;
  late Color _color;

  // Super Editor pieces
  late final MutableDocument _doc;
  late final DocumentEditor _docEditor;
  late final DocumentComposer _composer;

  // Pickers data
  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
  final List<int> hours = List.generate(24, (i) => i);
  final List<Color> palette = [
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
      // Editing an existing event
      final ev = widget.event!;
      _day = ev.day;
      _subject = ev.subject;
      _subtitle = ev.subtitle;
      _body = ev.body;
      _startHour = ev.startHour;
      _color = ev.color;
      _doc = MutableDocument(
        nodes: [
          for (var line in _body.split('\n'))
            ParagraphNode(
              id: DocumentEditor.createNodeId(),
              text: AttributedText(line),
            ),
        ],
      );
    } else {
      // Creating a new event
      _day = days.first;
      _subject = '';
      _subtitle = '';
      _body = '';
      _startHour = hours.first;
      _color = palette.first;
      _doc = MutableDocument(
        nodes: [
          ParagraphNode(
            id: DocumentEditor.createNodeId(),
            text: AttributedText(''),
          ),
        ],
      );
    }

    _docEditor = DocumentEditor(document: _doc);
    _composer = DocumentComposer();
  }

  void _save() {
    // Serialize document back to plain text
    final buffer = StringBuffer();
    for (var node in _doc.nodes) {
      if (node is ParagraphNode) {
        buffer.writeln(node.text.text);
      }
    }
    _body = buffer.toString().trimRight();

    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (widget.event != null) {
      // Update existing
      final ev = widget.event!;
      ev
        ..day = _day
        ..subject = _subject
        ..subtitle = _subtitle
        ..body = _body
        ..startHour = _startHour
        ..color = _color;
      Navigator.pop(context);
    } else {
      // Create new
      Navigator.pop(
        context,
        EventBlock(
          day: _day,
          subject: _subject,
          subtitle: _subtitle,
          body: _body,
          color: _color,
          startHour: _startHour,
          duration: 1, // default duration
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextFormField(
                initialValue: _subject,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _subject = v!,
              ),
              SizedBox(height: 8),

              // Subtitle
              TextFormField(
                initialValue: _subtitle,
                decoration: InputDecoration(labelText: 'Subtitle'),
                onSaved: (v) => _subtitle = v ?? '',
              ),
              SizedBox(height: 8),

              // Day & Start Hour pickers
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _day,
                      decoration: InputDecoration(labelText: 'Day'),
                      items: days
                          .map(
                            (d) => DropdownMenuItem(value: d, child: Text(d)),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _day = v!),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _startHour,
                      decoration: InputDecoration(labelText: 'Start Hour'),
                      items: hours
                          .map(
                            (h) => DropdownMenuItem(
                              value: h,
                              child: Text('$h:00'),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => _startHour = v!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),

              // Color picker
              Row(
                children: [
                  Text('Color:'),
                  SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: palette.map((c) {
                      final selected = c == _color;
                      return GestureDetector(
                        onTap: () => setState(() => _color = c),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: c,
                            border: Border.all(
                              color: selected ? Colors.black : Colors.grey,
                              width: selected ? 3 : 1,
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

              // Super Editor toolbar
              EditorToolbar.basic(editor: _docEditor, composer: _composer),
              SizedBox(height: 8),

              // Super Editor editing area
              SizedBox(
                height: 200,
                child: SingleColumnDocumentEditor(
                  document: _doc,
                  editor: _docEditor,
                  composer: _composer,
                  padding: EdgeInsets.all(8),
                ),
              ),
              SizedBox(height: 16),

              // Save button
              ElevatedButton(onPressed: _save, child: Text('Save')),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
