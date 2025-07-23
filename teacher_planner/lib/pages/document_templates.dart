// lib/pages/document_templates.dart

import 'package:super_editor/super_editor.dart';

class DocumentTemplates {
  /// Creates a lesson plan template with structured sections
  static MutableDocument createLessonPlanTemplate() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Lesson Objectives',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '• ')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '• ')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Materials Needed',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Lesson Activities',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ListItemNode.ordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: 'Introduction (5 minutes)')]),
        ),
        ListItemNode.ordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: 'Main Activity (30 minutes)')]),
        ),
        ListItemNode.ordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: 'Conclusion (5 minutes)')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Assessment',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
      ],
    );
  }

  /// Creates a simple note template
  static MutableDocument createNoteTemplate() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
      ],
    );
  }

  /// Creates a homework assignment template
  static MutableDocument createHomeworkTemplate() {
    return MutableDocument(
      nodes: [
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Homework Assignment',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Instructions',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([
            AttributedTextSpan(
              text: 'Due Date',
              attributions: {boldAttribution},
            ),
          ]),
        ),
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
      ],
    );
  }

  /// Converts a document to plain text
  static String documentToText(MutableDocument document) {
    return document.nodes
        .map((node) {
          if (node is ParagraphNode) {
            return node.text.text;
          } else if (node is ListItemNode) {
            return '• ${node.text.text}';
          }
          return '';
        })
        .where((text) => text.isNotEmpty)
        .join('\n');
  }

  /// Converts plain text to a document
  static MutableDocument textToDocument(String text) {
    if (text.isEmpty) {
      return MutableDocument(nodes: [
        ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ),
      ]);
    }

    final lines = text.split('\n');
    final nodes = <DocumentNode>[];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        nodes.add(ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: '')]),
        ));
      } else if (line.trim().startsWith('• ')) {
        nodes.add(ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: line.trim().substring(2))]),
        ));
      } else if (line.trim().startsWith('- ')) {
        nodes.add(ListItemNode.unordered(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: line.trim().substring(2))]),
        ));
      } else {
        nodes.add(ParagraphNode(
          id: DocumentEditor.createNodeId(),
          text: AttributedText([AttributedTextSpan(text: line)]),
        ));
      }
    }

    return MutableDocument(nodes: nodes);
  }
} 