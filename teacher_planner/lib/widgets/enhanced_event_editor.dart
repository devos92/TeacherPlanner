// lib/widgets/enhanced_event_editor.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import 'attachment_manager.dart';

class EnhancedEventEditor extends StatefulWidget {
  final EnhancedEventBlock event;
  final Function(EnhancedEventBlock) onEventUpdated;
  final List<CurriculumOutcome> availableOutcomes;

  const EnhancedEventEditor({
    Key? key,
    required this.event,
    required this.onEventUpdated,
    required this.availableOutcomes,
  }) : super(key: key);

  @override
  _EnhancedEventEditorState createState() => _EnhancedEventEditorState();
}

class _EnhancedEventEditorState extends State<EnhancedEventEditor> {
  late TextEditingController _subjectController;
  late TextEditingController _subtitleController;
  late TextEditingController _bodyController;
  late List<Attachment> _attachments;
  late List<String> _curriculumOutcomeIds;
  late List<Hyperlink> _hyperlinks;
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _subjectController = TextEditingController(text: widget.event.subject);
    _subtitleController = TextEditingController(text: widget.event.subtitle);
    _bodyController = TextEditingController(text: widget.event.body);
    _attachments = []; // TODO: Load actual attachments
    _curriculumOutcomeIds = List.from(widget.event.curriculumOutcomeIds);
    _hyperlinks = []; // TODO: Load actual hyperlinks
    _selectedColor = widget.event.color;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _subtitleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.edit, color: theme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Edit Event',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Basic Event Info
                  _buildBasicInfoSection(theme),
                  SizedBox(height: 24),

                  // Time Settings
                  _buildTimeSection(theme),
                  SizedBox(height: 24),

                  // Color Selection
                  _buildColorSection(theme),
                  SizedBox(height: 24),

                  // Curriculum Outcomes
                  _buildCurriculumSection(theme),
                  SizedBox(height: 24),

                  // Hyperlinks
                  _buildHyperlinksSection(theme),
                  SizedBox(height: 24),

                  // Attachments
                  _buildAttachmentsSection(theme),
                  SizedBox(height: 24),

                  // Save Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _saveEvent,
                    child: Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  // Bottom padding for keyboard
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event Information',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _subtitleController,
              decoration: InputDecoration(
                labelText: 'Subtitle (Optional)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _bodyController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Settings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.event.startHour.toString(),
                    decoration: InputDecoration(
                      labelText: 'Start Hour',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hour = int.tryParse(value);
                      if (hour != null && hour >= 0 && hour <= 23) {
                        _updateEventTime(startHour: hour);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.event.startMinute.toString(),
                    decoration: InputDecoration(
                      labelText: 'Start Minute',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final minute = int.tryParse(value);
                      if (minute != null && minute >= 0 && minute <= 59) {
                        _updateEventTime(startMinute: minute);
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: widget.event.finishHour.toString(),
                    decoration: InputDecoration(
                      labelText: 'Finish Hour',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final hour = int.tryParse(value);
                      if (hour != null && hour >= 0 && hour <= 23) {
                        _updateEventTime(finishHour: hour);
                      }
                    },
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: widget.event.finishMinute.toString(),
                    decoration: InputDecoration(
                      labelText: 'Finish Minute',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final minute = int.tryParse(value);
                      if (minute != null && minute >= 0 && minute <= 59) {
                        _updateEventTime(finishMinute: minute);
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duration: ${widget.event.durationMinutes} minutes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSection(ThemeData theme) {
    final colors = [
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

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Color',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: colors.map((color) {
                final isSelected = color == _selectedColor;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedColor = color);
                    _updateEventColor(color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.white,
                        width: isSelected ? 3 : 1,
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
                    child: isSelected
                        ? Icon(Icons.check, color: Colors.white, size: 20)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurriculumSection(ThemeData theme) {
    final selectedOutcomes = widget.availableOutcomes
        .where((outcome) => _curriculumOutcomeIds.contains(outcome.id))
        .toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Curriculum Outcomes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: () => _showCurriculumDialog(context),
                  child: Text('Select Outcomes'),
                ),
              ],
            ),
            if (selectedOutcomes.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 150,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: selectedOutcomes.map((outcome) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        title: Text(
                          outcome.code,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          outcome.description,
                          style: theme.textTheme.bodySmall,
                          // Remove maxLines and overflow to show full description
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline, 
                                    color: Colors.red, 
                                    size: 20),
                          onPressed: () {
                            setState(() {
                              _curriculumOutcomeIds.remove(outcome.id);
                            });
                          },
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 12),
              Text(
                'No curriculum outcomes selected',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHyperlinksSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Hyperlinks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddHyperlinkDialog(context),
                  icon: Icon(Icons.add, size: 16),
                  label: Text('Add Link'),
                ),
              ],
            ),
            if (_hyperlinks.isNotEmpty) ...[
              SizedBox(height: 12),
              Container(
                constraints: BoxConstraints(
                  maxHeight: 150,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: _hyperlinks.map((link) => Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.link, color: theme.primaryColor),
                        title: Text(
                          link.title,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          link.url,
                          style: theme.textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.remove_circle_outline, 
                                    color: Colors.red, 
                                    size: 20),
                          onPressed: () {
                            setState(() {
                              _hyperlinks.remove(link);
                            });
                          },
                        ),
                        onTap: () => _openHyperlink(link.url),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ] else ...[
              SizedBox(height: 12),
              Text(
                'No hyperlinks added',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attachments',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            AttachmentManager(
              attachments: _attachments,
              onAttachmentsChanged: (attachments) {
                setState(() => _attachments = attachments);
              },
              folder: 'events/${widget.event.id}',
              showUploadButton: true,
            ),
          ],
        ),
      ),
    );
  }

  void _updateEventTime({
    int? startHour,
    int? startMinute,
    int? finishHour,
    int? finishMinute,
  }) {
    final updatedEvent = widget.event.copyWith(
      startHour: startHour ?? widget.event.startHour,
      startMinute: startMinute ?? widget.event.startMinute,
      finishHour: finishHour ?? widget.event.finishHour,
      finishMinute: finishMinute ?? widget.event.finishMinute,
    );
    widget.onEventUpdated(updatedEvent);
  }

  void _updateEventColor(Color color) {
    final updatedEvent = widget.event.copyWith(color: color);
    widget.onEventUpdated(updatedEvent);
  }

  void _saveEvent() {
    final updatedEvent = widget.event.copyWith(
      subject: _subjectController.text,
      subtitle: _subtitleController.text,
      body: _bodyController.text,
      curriculumOutcomeIds: _curriculumOutcomeIds,
      hyperlinks: _hyperlinks.map((link) => link.id).toList(),
      attachmentIds: _attachments.map((attachment) => attachment.id).toList(),
      updatedAt: DateTime.now(),
    );
    
    widget.onEventUpdated(updatedEvent);
    Navigator.pop(context);
  }

  void _showCurriculumDialog(BuildContext context) {
    // TODO: Implement curriculum selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Select Curriculum Outcomes'),
        content: Text('Curriculum selection dialog will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddHyperlinkDialog(BuildContext context) {
    final titleController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Hyperlink'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: urlController,
              decoration: InputDecoration(
                labelText: 'URL',
                border: OutlineInputBorder(),
                hintText: 'https://example.com',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty && urlController.text.isNotEmpty) {
                final hyperlink = Hyperlink(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text,
                  url: urlController.text,
                );
                setState(() {
                  _hyperlinks.add(hyperlink);
                });
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _openHyperlink(String url) {
    // TODO: Implement URL opening
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opening: $url')),
    );
  }
} 