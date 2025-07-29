// lib/widgets/lesson_card_widget.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/curriculum_models.dart';
import '../config/app_fonts.dart';

class LessonCardWidget extends StatelessWidget {
  final EnhancedEventBlock event;
  final Function(EnhancedEventBlock) onEdit;
  final Function(EnhancedEventBlock, String) onRemovePicture;
  final Function(EnhancedEventBlock, String) onRemoveHyperlink;
  final Function(EnhancedEventBlock) onAddPicture;
  final Function(EnhancedEventBlock) onAddHyperlink;
  final Function(String) onViewImage;

  const LessonCardWidget({
    Key? key,
    required this.event,
    required this.onEdit,
    required this.onRemovePicture,
    required this.onRemoveHyperlink,
    required this.onAddPicture,
    required this.onAddHyperlink,
    required this.onViewImage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    final isTablet = screenSize.width >= 600 && screenSize.width < 900;

    return Container(
      margin: EdgeInsets.only(
        bottom: isTablet ? 16 : 12,
        left: isTablet ? 20 : 16,
        right: isTablet ? 20 : 16,
      ),
      child: Material(
        elevation: 0,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
            border: Border.all(
              color: event.color.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: Offset(0, 4),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: event.color.withOpacity(0.08),
                blurRadius: 24,
                offset: Offset(0, 8),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with period and subject
              _buildHeader(context, isTablet),
              
              // Content section with inline editing
              Container(
                padding: EdgeInsets.all(isTablet ? 20 : 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lesson Details Section
                    _buildInlineDetailsSection(context, isTablet),
                    
                    SizedBox(height: 20),
                    
                    // Teacher Notes Section
                    _buildInlineNotesSection(context, isTablet),
                    
                    SizedBox(height: 20),
                    
                    // Attachments and Links Section
                    _buildInlineResourcesSection(context, isTablet),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: event.color.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(isTablet ? 16 : 12),
          topRight: Radius.circular(isTablet ? 16 : 12),
        ),
      ),
      child: Row(
        children: [
          // Period badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 12 : 10,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: event.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
              border: Border.all(
                color: event.color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              'Period ${event.periodIndex + 1}',
              style: AppFonts.labelMedium.copyWith(
                color: event.color,
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Subject
          Expanded(
            child: Text(
              event.headerText?.isNotEmpty == true 
                  ? event.headerText! 
                  : event.subject,
              style: AppFonts.lessonTitle.copyWith(
                fontSize: isTablet ? 22 : 18,
                color: Colors.grey[900],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineDetailsSection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, color: event.color, size: 20),
            SizedBox(width: 8),
            Text(
              'Lesson Details',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: event.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextFormField(
          initialValue: event.body,
          onChanged: (value) {
            // This will be handled by the parent widget
          },
          style: AppFonts.userInput.copyWith(
            fontSize: isTablet ? 16 : 14,
            height: 1.5,
          ),
          maxLines: 6,
          decoration: InputDecoration(
            labelText: 'Lesson Details',
            hintText: 'Enter detailed lesson description, activities, objectives...',
            hintStyle: AppFonts.userInput.copyWith(
              color: Colors.grey.shade400,
              fontSize: isTablet ? 14 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: event.color.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: event.color, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineNotesSection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.note_outlined, color: event.color, size: 20),
            SizedBox(width: 8),
            Text(
              'Teacher Notes',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: event.color,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        TextFormField(
          initialValue: event.notes,
          onChanged: (value) {
            // This will be handled by the parent widget
          },
          style: AppFonts.userInput.copyWith(
            fontSize: isTablet ? 16 : 14,
            height: 1.5,
          ),
          maxLines: 4,
          decoration: InputDecoration(
            labelText: 'Teacher Notes',
            hintText: 'Add your notes, reminders, or additional details...',
            hintStyle: AppFonts.userInput.copyWith(
              color: Colors.grey.shade400,
              fontSize: isTablet ? 14 : 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: event.color.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: event.color, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineResourcesSection(BuildContext context, bool isTablet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_file_outlined, color: event.color, size: 20),
            SizedBox(width: 8),
            Text(
              'Resources',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: event.color,
              ),
            ),
            Spacer(),
            // Add buttons
            TextButton.icon(
              onPressed: () => onAddPicture(event),
              icon: Icon(Icons.add_photo_alternate_outlined, size: 16),
              label: Text('Picture'),
              style: TextButton.styleFrom(
                foregroundColor: event.color,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
            SizedBox(width: 8),
            TextButton.icon(
              onPressed: () => onAddHyperlink(event),
              icon: Icon(Icons.link_outlined, size: 16),
              label: Text('Link'),
              style: TextButton.styleFrom(
                foregroundColor: event.color,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        
        // Display existing resources
        if (event.attachmentIds.isNotEmpty || event.hyperlinks.isNotEmpty) ...[
          // Pictures
          if (event.attachmentIds.isNotEmpty) ...[
            Text(
              'Pictures',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.attachmentIds.map((imagePath) {
                final file = File(imagePath);
                final fileName = path.basename(imagePath);
                
                return Container(
                  width: isTablet ? 150 : 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: event.color.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                        child: Container(
                          height: isTablet ? 100 : 80,
                          width: double.infinity,
                          child: file.existsSync()
                              ? Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: Icon(
                                        Icons.broken_image,
                                        color: Colors.grey.shade400,
                                        size: isTablet ? 40 : 30,
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.image_not_supported,
                                    color: Colors.grey.shade400,
                                    size: isTablet ? 40 : 30,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fileName,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: event.color,
                                fontSize: isTablet ? 9 : 8,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => onViewImage(imagePath),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                      decoration: BoxDecoration(
                                        color: event.color.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'View',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: event.color,
                                          fontSize: isTablet ? 8 : 7,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => onRemovePicture(event, imagePath),
                                  child: Container(
                                    padding: EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      Icons.close,
                                      size: isTablet ? 10 : 8,
                                      color: Colors.red.shade400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16),
          ],
          
          // Links
          if (event.hyperlinks.isNotEmpty) ...[
            Text(
              'Links',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 8),
            ...event.hyperlinks.map((linkData) {
              final parts = linkData.split('|');
              final linkTitle = parts.length > 0 ? parts[0] : 'Link';
              final linkUrl = parts.length > 1 ? parts[1] : linkData;
              
              return Container(
                margin: EdgeInsets.only(bottom: 6),
                padding: EdgeInsets.all(isTablet ? 8 : 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.link,
                          color: event.color,
                          size: isTablet ? 14 : 12,
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            linkTitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: event.color,
                              fontSize: isTablet ? 10 : 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () => onRemoveHyperlink(event, linkData),
                          icon: Icon(
                            Icons.close,
                            size: isTablet ? 12 : 10,
                            color: Colors.red.shade400,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(
                            minWidth: isTablet ? 16 : 14, 
                            minHeight: isTablet ? 16 : 14
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2),
                    Text(
                      linkUrl,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: isTablet ? 9 : 8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ] else ...[
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.grey.shade600,
                  size: isTablet ? 16 : 14,
                ),
                SizedBox(width: 6),
                Text(
                  'No resources added yet. Click "Picture" or "Link" to add.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isTablet ? 11 : 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
} 