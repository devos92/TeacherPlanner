// lib/widgets/resources_section_widget.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import 'resource_image_item.dart';

class ResourcesSectionWidget extends StatelessWidget {
  final EnhancedEventBlock event;
  final bool isTablet;
  final Function(EnhancedEventBlock) onAddPicture;
  final Function(EnhancedEventBlock) onAddHyperlink;
  final Function(String) onViewImage;
  final Function(EnhancedEventBlock, String) onRemovePicture;
  final Function(EnhancedEventBlock, String) onRemoveHyperlink;

  const ResourcesSectionWidget({
    Key? key,
    required this.event,
    required this.isTablet,
    required this.onAddPicture,
    required this.onAddHyperlink,
    required this.onViewImage,
    required this.onRemovePicture,
    required this.onRemoveHyperlink,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: 12),
        _buildResourcesContent(),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
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
    );
  }

  Widget _buildResourcesContent() {
    if (event.attachmentIds.isNotEmpty || event.hyperlinks.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (event.attachmentIds.isNotEmpty) ...[
            Text('Pictures', style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: event.attachmentIds.map((imagePath) => ResourceImageItem(
                imagePath: imagePath,
                event: event,
                onView: onViewImage,
                onRemove: (path) => onRemovePicture(event, path),
                isTablet: isTablet,
              )).toList(),
            ),
            SizedBox(height: 16),
          ],
          if (event.hyperlinks.isNotEmpty) ...[
            Text('Links', style: TextStyle(fontSize: isTablet ? 14 : 12, fontWeight: FontWeight.w600, color: Colors.grey.shade700)),
            SizedBox(height: 8),
            ...event.hyperlinks.map((linkData) => _buildLinkItem(linkData)).toList(),
          ],
        ],
      );
    } else {
      return _buildEmptyState();
    }
  }

  Widget _buildLinkItem(String linkData) {
    final parts = linkData.split('|');
    final linkTitle = parts.length > 0 ? parts[0] : 'Link';
    final linkUrl = parts.length > 1 ? parts[1] : linkData;
    
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.all(isTablet ? 8 : 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: event.color, size: isTablet ? 14 : 12),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  linkTitle,
                  style: TextStyle(fontWeight: FontWeight.w600, color: event.color, fontSize: isTablet ? 10 : 9),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                onPressed: () => onRemoveHyperlink(event, linkData),
                icon: Icon(Icons.close, size: isTablet ? 12 : 10, color: Colors.red.shade400),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: isTablet ? 16 : 14, minHeight: isTablet ? 16 : 14),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(
            linkUrl,
            style: TextStyle(color: Colors.grey.shade600, fontSize: isTablet ? 9 : 8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(isTablet ? 12 : 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: isTablet ? 16 : 14),
          SizedBox(width: 6),
          Text(
            'No resources added yet. Click "Picture" or "Link" to add.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: isTablet ? 11 : 10),
          ),
        ],
      ),
    );
  }
} 