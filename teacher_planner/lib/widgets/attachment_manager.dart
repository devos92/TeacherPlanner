// lib/widgets/attachment_manager.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/curriculum_models.dart';
import '../services/storage_service.dart';

class AttachmentManager extends StatefulWidget {
  final List<Attachment> attachments;
  final Function(List<Attachment>) onAttachmentsChanged;
  final String folder;
  final bool showUploadButton;

  const AttachmentManager({
    Key? key,
    required this.attachments,
    required this.onAttachmentsChanged,
    required this.folder,
    this.showUploadButton = true,
  }) : super(key: key);

  @override
  _AttachmentManagerState createState() => _AttachmentManagerState();
}

class _AttachmentManagerState extends State<AttachmentManager> {
  final StorageService _storageService = StorageServiceFactory.create(StorageProvider.supabase);
  bool _isUploading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.attach_file, size: 20, color: theme.primaryColor),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Attachments (${widget.attachments.length})',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (widget.showUploadButton)
              TextButton.icon(
                onPressed: _isUploading ? null : _pickAndUploadFile,
                icon: _isUploading 
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.add, size: 16),
                label: Text(_isUploading ? 'Uploading...' : 'Add File'),
              ),
          ],
        ),

        SizedBox(height: 8),

        // Attachments List
        if (widget.attachments.isNotEmpty)
          Container(
            constraints: BoxConstraints(
              maxHeight: 200,
            ),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.attachments.length,
              itemBuilder: (context, index) {
                final attachment = widget.attachments[index];
                return _buildAttachmentTile(attachment, theme);
              },
            ),
          )
        else
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'No attachments yet',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttachmentTile(Attachment attachment, ThemeData theme) {
    return ListTile(
      leading: _getAttachmentIcon(attachment.type, theme),
      title: Text(
        attachment.name,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatFileSize(attachment.size),
            style: theme.textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            'Uploaded ${_formatDate(attachment.uploadedAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleAttachmentAction(value, attachment),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'download',
            child: ListTile(
              leading: Icon(Icons.download, size: 20),
              title: Text('Download'),
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 0,
            ),
          ),
          PopupMenuItem(
            value: 'preview',
            child: ListTile(
              leading: Icon(Icons.preview, size: 20),
              title: Text('Preview'),
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 0,
            ),
          ),
          PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete, color: Colors.red, size: 20),
              title: Text('Delete', style: TextStyle(color: Colors.red)),
              contentPadding: EdgeInsets.zero,
              minLeadingWidth: 0,
            ),
          ),
        ],
        child: Icon(Icons.more_vert),
      ),
      onTap: () => _previewAttachment(attachment),
    );
  }

  Widget _getAttachmentIcon(AttachmentType type, ThemeData theme) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case AttachmentType.image:
        iconData = Icons.image;
        iconColor = Colors.green;
        break;
      case AttachmentType.document:
        iconData = Icons.description;
        iconColor = Colors.blue;
        break;
      case AttachmentType.video:
        iconData = Icons.video_file;
        iconColor = Colors.red;
        break;
      case AttachmentType.audio:
        iconData = Icons.audio_file;
        iconColor = Colors.orange;
        break;
      case AttachmentType.other:
        iconData = Icons.insert_drive_file;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() => _isUploading = true);

      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        type: FileType.any,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.first.path!);
        final fileName = result.files.first.name;

        // Upload file
        final url = await _storageService.uploadFile(file, widget.folder);

        // Create attachment object
        final attachment = Attachment(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: fileName,
          url: url,
          type: _getAttachmentType(fileName),
          uploadedAt: DateTime.now(),
          size: await file.length(),
        );

        // Add to attachments list
        final newAttachments = List<Attachment>.from(widget.attachments);
        newAttachments.add(attachment);
        widget.onAttachmentsChanged(newAttachments);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File uploaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  void _handleAttachmentAction(String action, Attachment attachment) async {
    switch (action) {
      case 'download':
        await _downloadAttachment(attachment);
        break;
      case 'preview':
        _previewAttachment(attachment);
        break;
      case 'delete':
        _deleteAttachment(attachment);
        break;
    }
  }

  Future<void> _downloadAttachment(Attachment attachment) async {
    try {
      final bytes = await _storageService.downloadFile(attachment.url);
      // TODO: Implement actual file download to device
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download started: ${attachment.name}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _previewAttachment(Attachment attachment) {
    // TODO: Implement file preview based on type
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          attachment.name,
          overflow: TextOverflow.ellipsis,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${attachment.type.toString().split('.').last}'),
            Text('Size: ${_formatFileSize(attachment.size)}'),
            Text('Uploaded: ${_formatDate(attachment.uploadedAt)}'),
            SizedBox(height: 16),
            Text('Preview not yet implemented for this file type.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _deleteAttachment(Attachment attachment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Attachment'),
        content: Text('Are you sure you want to delete "${attachment.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _performDelete(attachment);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(Attachment attachment) async {
    try {
      await _storageService.deleteFile(attachment.url);
      
      final newAttachments = List<Attachment>.from(widget.attachments);
      newAttachments.removeWhere((a) => a.id == attachment.id);
      widget.onAttachmentsChanged(newAttachments);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('File deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  AttachmentType _getAttachmentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'bmp':
      case 'webp':
        return AttachmentType.image;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'rtf':
        return AttachmentType.document;
      case 'mp4':
      case 'avi':
      case 'mov':
      case 'wmv':
        return AttachmentType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'ogg':
        return AttachmentType.audio;
      default:
        return AttachmentType.other;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 