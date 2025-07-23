// lib/pages/simple_text_editor.dart

import 'package:flutter/material.dart';

class SimpleTextEditor extends StatefulWidget {
  final String initialText;
  final Function(String) onTextChanged;
  final double height;
  final String labelText;

  const SimpleTextEditor({
    Key? key,
    this.initialText = '',
    required this.onTextChanged,
    this.height = 200,
    this.labelText = 'Lesson plan details',
  }) : super(key: key);

  @override
  _SimpleTextEditorState createState() => _SimpleTextEditorState();
}

class _SimpleTextEditorState extends State<SimpleTextEditor> {
  late TextEditingController _controller;
  bool _isBold = false;
  bool _isItalic = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
    _controller.addListener(() {
      widget.onTextChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Simple formatting toolbar
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
              _buildFormatButton(
                icon: Icons.format_bold,
                isSelected: _isBold,
                onPressed: () {
                  setState(() {
                    _isBold = !_isBold;
                  });
                  _applyFormatting();
                },
                tooltip: 'Bold',
              ),
              SizedBox(width: 4),
              _buildFormatButton(
                icon: Icons.format_italic,
                isSelected: _isItalic,
                onPressed: () {
                  setState(() {
                    _isItalic = !_isItalic;
                  });
                  _applyFormatting();
                },
                tooltip: 'Italic',
              ),
              SizedBox(width: 8),
              _buildFormatButton(
                icon: Icons.format_list_bulleted,
                onPressed: () => _addBulletPoint(),
                tooltip: 'Add Bullet Point',
              ),
              SizedBox(width: 4),
              _buildFormatButton(
                icon: Icons.format_list_numbered,
                onPressed: () => _addNumberedPoint(),
                tooltip: 'Add Numbered Point',
              ),
            ],
          ),
        ),
        // Text editor
        Expanded(
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: widget.labelText,
                contentPadding: EdgeInsets.all(16),
                border: InputBorder.none,
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                ),
              ),
              style: TextStyle(
                fontSize: 16,
                height: 1.4,
                fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
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
    bool isSelected = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, size: 20),
        onPressed: onPressed,
        padding: EdgeInsets.all(4),
        constraints: BoxConstraints(minWidth: 32, minHeight: 32),
        style: IconButton.styleFrom(
          backgroundColor: isSelected ? Colors.blue.shade100 : Colors.transparent,
          foregroundColor: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
        ),
      ),
    );
  }

  void _applyFormatting() {
    // For now, we'll just update the style
    // In a real implementation, you'd want to apply formatting to selected text
    setState(() {});
  }

  void _addBulletPoint() {
    final currentText = _controller.text;
    final selection = _controller.selection;
    final newText = currentText.substring(0, selection.baseOffset) + '• ' + currentText.substring(selection.extentOffset);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: selection.baseOffset + 2);
  }

  void _addNumberedPoint() {
    final currentText = _controller.text;
    final selection = _controller.selection;
    final lines = currentText.split('\n');
    final currentLine = lines.takeWhile((line) => line.length < selection.baseOffset).length;
    final newText = currentText.substring(0, selection.baseOffset) + '${currentLine + 1}. ' + currentText.substring(selection.extentOffset);
    _controller.text = newText;
    _controller.selection = TextSelection.collapsed(offset: selection.baseOffset + 3);
  }
} 