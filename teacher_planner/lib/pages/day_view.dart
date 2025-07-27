import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DayView extends StatefulWidget {
  @override
  _DayViewState createState() => _DayViewState();
}

class _DayViewState extends State<DayView> {
  String _selectedFont = 'Sans';
  final TextEditingController _planController = TextEditingController();
  
  @override
  void dispose() {
    _planController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get screen information for responsive design
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final isTablet = screenWidth > 768;
    final isLandscape = mediaQuery.orientation == Orientation.landscape;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daily Planner',
          style: TextStyle(
            fontSize: isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
        toolbarHeight: isTablet ? 68 : 56,
        
        // Add actions for better functionality
        actions: [
          IconButton(
            icon: Icon(Icons.save_outlined),
            onPressed: _savePlan,
            tooltip: 'Save plan',
            iconSize: isTablet ? 28 : 24,
          ),
          IconButton(
            icon: Icon(Icons.share_outlined),
            onPressed: _sharePlan,
            tooltip: 'Share plan',
            iconSize: isTablet ? 28 : 24,
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              size: isTablet ? 28 : 24,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all, size: 20),
                    SizedBox(width: 12),
                    Text('Clear All'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'template',
                child: Row(
                  children: [
                    Icon(Icons.description_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Load Template'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced toolbar
              _buildToolbar(isTablet),
              
              SizedBox(height: isTablet ? 20 : 16),
              
              // Main content area with better responsive design
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _planController,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    
                    style: TextStyle(
                      fontFamily: _selectedFont == 'Sans' ? null : _selectedFont,
                      fontSize: isTablet ? 16 : 14,
                      height: 1.5,
                    ),
                    
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Enter your detailed lesson plan...\n\n• Learning objectives\n• Materials needed\n• Activities\n• Assessment methods\n• Homework/follow-up',
                      hintStyle: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                      contentPadding: EdgeInsets.all(isTablet ? 20 : 16),
                    ),
                    
                    // Enhanced text input features
                    textCapitalization: TextCapitalization.sentences,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    
                    onChanged: (text) {
                      // Auto-save functionality could go here
                    },
                  ),
                ),
              ),
              
              // Quick action buttons at bottom
              if (MediaQuery.of(context).viewInsets.bottom == 0) ...[
                SizedBox(height: isTablet ? 20 : 16),
                _buildQuickActions(isTablet),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 16 : 12,
        vertical: isTablet ? 12 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Font selector
          Row(
            children: [
              Icon(
                Icons.font_download_outlined,
                size: isTablet ? 20 : 18,
                color: Colors.grey[700],
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButton<String>(
                  value: _selectedFont,
                  underline: SizedBox.shrink(),
                  icon: Icon(Icons.arrow_drop_down, size: 18),
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: Colors.black87,
                  ),
                  items: ['Sans', 'Serif', 'Mono']
                      .map((font) => DropdownMenuItem(
                            value: font,
                            child: Text(
                              font,
                              style: TextStyle(
                                fontFamily: font == 'Sans' ? null : font,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (newFont) {
                    if (newFont != null) {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _selectedFont = newFont;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          
          Spacer(),
          
          // Word count indicator
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${_planController.text.split(' ').where((word) => word.isNotEmpty).length} words',
              style: TextStyle(
                fontSize: isTablet ? 12 : 10,
                color: Colors.blue[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(bool isTablet) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _insertTemplate,
            icon: Icon(
              Icons.add_circle_outline,
              size: isTablet ? 20 : 18,
            ),
            label: Text(
              'Add Template',
              style: TextStyle(fontSize: isTablet ? 14 : 12),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        
        SizedBox(width: 12),
        
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _savePlan,
            icon: Icon(
              Icons.save_outlined,
              size: isTablet ? 20 : 18,
            ),
            label: Text(
              'Save Plan',
              style: TextStyle(fontSize: isTablet ? 14 : 12),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _savePlan() {
    HapticFeedback.mediumImpact();
    
    // TODO: Implement save functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plan saved successfully!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _sharePlan() {
    HapticFeedback.lightImpact();
    
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Share functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _insertTemplate() {
    HapticFeedback.lightImpact();
    
    final template = '''
Learning Objectives:
• 

Materials Needed:
• 

Lesson Activities:
1. 

Assessment:
• 

Homework/Follow-up:
• 

Reflection Notes:
• 
''';
    
    final currentText = _planController.text;
    final cursorPosition = _planController.selection.start;
    
    final newText = currentText.substring(0, cursorPosition) + 
                   template + 
                   currentText.substring(cursorPosition);
    
    _planController.text = newText;
    _planController.selection = TextSelection.fromPosition(
      TextPosition(offset: cursorPosition + template.length),
    );
  }

  void _handleMenuAction(String action) {
    HapticFeedback.lightImpact();
    
    switch (action) {
      case 'clear':
        _showClearConfirmation();
        break;
      case 'template':
        _insertTemplate();
        break;
    }
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Content?'),
        content: Text('This will remove all text from your daily plan. This action cannot be undone.'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _planController.clear();
              Navigator.pop(context);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }
}

// Extension to check if keyboard is visible
extension MediaQueryExtension on MediaQueryData {
  bool get isKeyboardVisible => viewInsets.bottom > 0;
}
