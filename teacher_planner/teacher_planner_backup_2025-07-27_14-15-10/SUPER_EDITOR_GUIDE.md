# Super Editor Integration Guide for Teacher Planner

This guide explains how super_editor is integrated into your teacher planner app and how to use its features effectively.

## Overview

Super Editor is a powerful rich text editor for Flutter that provides:

- Rich text formatting (bold, italic, underline)
- Lists (ordered and unordered)
- Document templates
- Read-only display mode
- Custom styling

## Files Overview

### 1. `rich_text_editor.dart`

A reusable component that provides a rich text editor with formatting toolbar.

**Features:**

- Formatting buttons (bold, italic, underline)
- List creation (bullet and numbered)
- Template selection
- Real-time text extraction

**Usage:**

```dart
RichTextEditor(
  initialText: 'Your initial text here',
  onTextChanged: (text) {
    // Handle text changes
    setState(() {
      _body = text;
    });
  },
  height: 200,
  showTemplates: true,
)
```

### 2. `document_templates.dart`

Provides pre-built document templates for different lesson types.

**Available Templates:**

- `createLessonPlanTemplate()` - Structured lesson plan with sections
- `createNoteTemplate()` - Simple blank note
- `createHomeworkTemplate()` - Homework assignment template

**Utility Functions:**

- `documentToText(Document)` - Converts document to plain text
- `textToDocument(String)` - Converts plain text to document

### 3. `add_event_page.dart`

Updated to use the rich text editor for lesson details.

**Key Changes:**

- Replaced simple TextFormField with RichTextEditor
- Added template functionality
- Proper text extraction and saving

### 4. `lesson_detail_page.dart`

Enhanced to display rich text content in read-only mode.

**Features:**

- Beautiful layout with event information
- Rich text display using SuperEditor
- Proper styling and formatting

## How to Use

### 1. Creating a New Lesson

1. Tap the "+" button in the week view
2. Fill in the lesson information
3. Use the rich text editor for lesson details:
   - **Templates**: Tap the template icon to choose a pre-built template
   - **Formatting**: Use the toolbar buttons for bold, italic, underline
   - **Lists**: Create bullet or numbered lists
4. Save the lesson

### 2. Editing an Existing Lesson

1. Tap on any lesson block in the week view
2. The rich text editor will load with existing content
3. Make your changes using the formatting tools
4. Save the lesson

### 3. Viewing Lesson Details

1. Long press on a lesson block to see a preview
2. Tap "View Full" to see the complete lesson detail page
3. The rich text content is displayed in read-only mode

## Advanced Features

### Custom Templates

You can create custom templates by adding new methods to `DocumentTemplates`:

```dart
static Document createCustomTemplate() {
  return Document(
    nodes: [
      ParagraphNode(
        id: DocumentEditor.createNodeId(),
        text: AttributedText(
          text: 'Custom Title',
          spans: AttributedSpans(
            attributions: [
              const SpanMarker(
                attribution: boldAttribution,
                offset: 0,
                markerType: SpanMarkerType.start,
              ),
              const SpanMarker(
                attribution: boldAttribution,
                offset: 12,
                markerType: SpanMarkerType.end,
              ),
            ],
          ),
        ),
      ),
      // Add more nodes as needed
    ],
  );
}
```

### Custom Styling

You can customize the editor appearance by modifying the stylesheet:

```dart
SuperEditor(
  editor: _documentEditor,
  stylesheet: defaultStylesheet.copyWith(
    documentPadding: EdgeInsets.all(16),
    paragraphStyles: [
      ParagraphStyle(
        textStyle: TextStyle(
          fontSize: 16,
          height: 1.4,
          color: Colors.black87,
        ),
      ),
    ],
    textStyles: {
      'bold': TextStyle(fontWeight: FontWeight.bold),
      'italic': TextStyle(fontStyle: FontStyle.italic),
    },
  ),
)
```

### Adding New Formatting Options

To add new formatting options, extend the `RichTextEditor`:

```dart
void _toggleStrikethrough() {
  final selection = _composer.selection;
  if (selection != null) {
    _documentEditor.toggleAttribution(
      selection,
      strikethroughAttribution,
    );
  }
}
```

## Best Practices

1. **Performance**: Always dispose of DocumentEditor instances to prevent memory leaks
2. **Text Extraction**: Use the provided utility functions for consistent text handling
3. **Templates**: Create templates for common lesson types to save time
4. **Styling**: Maintain consistent styling across the app
5. **User Experience**: Provide clear visual feedback for formatting actions

## Troubleshooting

### Common Issues

1. **Text not saving**: Ensure you're calling the `onTextChanged` callback
2. **Formatting not working**: Check that you have a valid selection
3. **Templates not loading**: Verify the template creation methods are working
4. **Performance issues**: Make sure to dispose of editors properly

### Debug Tips

1. Use `print()` statements to debug text extraction
2. Check the document structure with `document.nodes`
3. Verify selection state with `_composer.selection`
4. Test templates individually

## Future Enhancements

Potential improvements you could add:

1. **Image Support**: Add image insertion capabilities
2. **Tables**: Implement table creation and editing
3. **Collaboration**: Real-time collaborative editing
4. **Export**: PDF export with rich formatting
5. **Auto-save**: Automatic saving of changes
6. **Version History**: Track changes over time

## Resources

- [Super Editor Documentation](https://superlist.com/super_editor)
- [Flutter Documentation](https://flutter.dev/docs)
- [GitHub Repository](https://github.com/superlistapp/super_editor)

---

This integration provides a powerful rich text editing experience for your teacher planner app, making it easy to create detailed lesson plans with proper formatting and structure.
