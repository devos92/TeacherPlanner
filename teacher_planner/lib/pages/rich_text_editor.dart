// lib/pages/rich_text_editor.dart

import 'package:flutter/material.dart';
import 'package:super_editor/super_editor.dart';
import 'document_templates.dart';

class RichTextEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onTextChanged;
  final double height;
  final bool showTemplates;

  const RichTextEditor({
    Key? key,
    this.initialText = '',
    required this.onTextChanged,
    this.height = 200,
    this.showTemplates = true,
  }) : super(key: key);

  @override
  _RichTextEditorState createState() => _RichTextEditorState();
}

class _RichTextEditorState extends State<RichTextEditor> {
  late MutableDocument _document;
  late DocumentComposer _composer;

  @override
  void initState() {
    super.initState();
    
    _composer = DocumentComposer();
    
    // Initialize with existing text or empty document
    if (widget.initialText.isNotEmpty) {
      _document = DocumentTemplates.textToDocument(widget.initialText);
    } else {
      _document = MutableDocument(
        nodes: [
          ParagraphNode(
            id: DocumentEditor.createNodeId(),
            text: AttributedText([AttributedTextSpan(text: '')]),
          ),
        ],
      );
    }

    // Listen to document changes
    _document.addListener(_onDocumentChanged);
  }

  void _onDocumentChanged() {
    final text = DocumentTemplates.documentToText(_document);
    widget.onTextChanged(text);
  }

  @override
  void dispose() {
    _document.removeListener(_onDocumentChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Formatting toolbar
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              if (widget.showTemplates) ...[
                _buildFormatButton(
                  icon: Icons.dashboard,
                  onPressed: () => _showTemplateDialog(),
                  tooltip: 'Templates',
                ),
                SizedBox(width: 8),
              ],
              _buildFormatButton(
                icon: Icons.format_bold,
                onPressed: () => _toggleBold(),
                tooltip: 'Bold',
              ),
              SizedBox(width: 4),
              _buildFormatButton(
                icon: Icons.format_italic,
                onPressed: () => _toggleItalic(),
                tooltip: 'Italic',
              ),
              SizedBox(width: 4),
              _buildFormatButton(
                icon: Icons.format_underline,
                onPressed: () => _toggleUnderline(),
                tooltip: 'Underline',
              ),
              SizedBox(width: 8),
              _buildFormatButton(
                icon: Icons.format_list_bulleted,
                onPressed: () => _addBulletList(),
                tooltip: 'Bullet List',
              ),
              SizedBox(width: 4),
              _buildFormatButton(
                icon: Icons.format_list_numbered,
                onPressed: () => _addNumberedList(),
                tooltip: 'Numbered List',
              ),
            ],
          ),
        ),
        // Editor
        Expanded(
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: SuperEditor(
              editor: DocumentEditor(document: _document),
              composer: _composer,
              stylesheet: defaultStylesheet.copyWith(
                documentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormatButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.grey.shade700,
        ),
      ),
    );
  }

  void _showTemplateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Template'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Lesson Plan'),
              subtitle: Text('Structured lesson plan template'),
              onTap: () {
                Navigator.pop(context);
                _loadTemplate(DocumentTemplates.createLessonPlanTemplate());
              },
            ),
            ListTile(
              leading: Icon(Icons.note),
              title: Text('Simple Note'),
              subtitle: Text('Blank note template'),
              onTap: () {
                Navigator.pop(context);
                _loadTemplate(DocumentTemplates.createNoteTemplate());
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment),
              title: Text('Homework'),
              subtitle: Text('Homework assignment template'),
              onTap: () {
                Navigator.pop(context);
                _loadTemplate(DocumentTemplates.createHomeworkTemplate());
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _loadTemplate(MutableDocument template) {
    _document = template;
    setState(() {});
  }

  void _toggleBold() {
    final selection = _composer.selection;
    if (selection != null) {
      DocumentEditor(document: _document).toggleAttribution(
        selection,
        boldAttribution,
      );
    }
  }

  void _toggleItalic() {
    final selection = _composer.selection;
    if (selection != null) {
      DocumentEditor(document: _document).toggleAttribution(
        selection,
        italicAttribution,
      );
    }
  }

  void _toggleUnderline() {
    final selection = _composer.selection;
    if (selection != null) {
      DocumentEditor(document: _document).toggleAttribution(
        selection,
        underlineAttribution,
      );
    }
  }

  void _addBulletList() {
    final selection = _composer.selection;
    if (selection != null) {
      DocumentEditor(document: _document).addNode(
        ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        selection.base.nodeId,
      );
    }
  }

  void _addNumberedList() {
    final selection = _composer.selection;
    if (selection != null) {
      DocumentEditor(document: _document).addNode(
        ListItemNode.ordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        selection.base.nodeId,
      );
    }
  }
} 