// lib/widgets/resource_image_item.dart

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../models/curriculum_models.dart';

class ResourceImageItem extends StatelessWidget {
  final String imagePath;
  final EnhancedEventBlock event;
  final Function(String) onView;
  final Function(String) onRemove;
  final bool isTablet;

  const ResourceImageItem({
    Key? key,
    required this.imagePath,
    required this.event,
    required this.onView,
    required this.onRemove,
    required this.isTablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          _buildImagePreview(file),
          _buildImageInfo(fileName, file),
        ],
      ),
    );
  }

  Widget _buildImagePreview(File file) {
    return ClipRRect(
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
    );
  }

  Widget _buildImageInfo(String fileName, File file) {
    return Padding(
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
                  onTap: () => onView(imagePath),
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
                onTap: () => onRemove(imagePath),
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
    );
  }
} 