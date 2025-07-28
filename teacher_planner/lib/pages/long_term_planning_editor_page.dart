// lib/pages/long_term_planning_editor_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:convert';
import '../models/long_term_plan_models.dart';
import '../models/curriculum_models.dart';
import '../utils/responsive_utils.dart';
import '../widgets/curriculum_sidebar.dart';

class LongTermPlanningEditorPage extends StatefulWidget {
  final LongTermPlan plan;

  const LongTermPlanningEditorPage({Key? key, required this.plan}) : super(key: key);

  @override
  _LongTermPlanningEditorPageState createState() => _LongTermPlanningEditorPageState();
}

class _LongTermPlanningEditorPageState extends State<LongTermPlanningEditorPage> {
  late LongTermPlan _currentPlan;
  late TextEditingController _contentController;
  final FocusNode _contentFocusNode = FocusNode();
  
  // Editor state
  bool _isEditing = true;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  bool _showCurriculumSidebar = true; // Show by default when editing a plan
  String _selectedFont = 'Default';
  double _fontSize = 16.0;
  bool _isBold = false;
  bool _isItalic = false;
  bool _isUnderlined = false;
  TextAlign _textAlign = TextAlign.left;
  
  // Content state
  List<DocumentImage> _images = [];
  List<DocumentLink> _hyperlinks = [];
  List<CurriculumOutcome> _selectedOutcomes = [];

  @override
  void initState() {
    super.initState();
    _currentPlan = widget.plan;
    _contentController = TextEditingController(text: _stripHtmlTags(_currentPlan.document.content));
    _images = List.from(_currentPlan.document.images);
    _hyperlinks = List.from(_currentPlan.document.hyperlinks);
    
    _contentController.addListener(() {
      if (!_hasUnsavedChanges) {
        setState(() => _hasUnsavedChanges = true);
      }
    });
  }

  @override
  void dispose() {
    _contentController.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  String _stripHtmlTags(String htmlText) {
    // Simple HTML tag removal for basic editing
    return htmlText
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&');
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: _buildAppBar(isTablet),
        body: SafeArea(
          child: Row(
            children: [
              // Curriculum sidebar on the left
              if (_showCurriculumSidebar)
                SizedBox(
                  width: context.isTablet ? 350 : 300,
                  child: CurriculumSidebar(
                    width: context.isTablet ? 350 : 300,
                    onSelectionChanged: _onCurriculumOutcomesChanged,
                  ),
                ),
              
              // Main editor content
              Expanded(
                child: _buildEditorContent(isTablet),
              ),
            ],
          ),
        ),
        bottomNavigationBar: _isEditing ? _buildToolbar(isTablet) : null,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isTablet) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _currentPlan.title,
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${_currentPlan.subject} • ${_currentPlan.yearLevel}',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      elevation: 2,
      actions: [
        IconButton(
          icon: Icon(Icons.school),
          onPressed: _toggleCurriculumSidebar,
          tooltip: 'Curriculum Outcomes',
        ),
        if (_hasUnsavedChanges)
          IconButton(
            icon: _isSaving 
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(Icons.save),
            onPressed: _isSaving ? null : _savePlan,
            tooltip: 'Save changes',
          ),
        IconButton(
          icon: Icon(_isEditing ? Icons.visibility : Icons.edit),
          onPressed: _toggleEditMode,
          tooltip: _isEditing ? 'Preview' : 'Edit',
        ),
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'export',
              child: Row(
                children: [
                  Icon(Icons.share, size: 18),
                  SizedBox(width: 8),
                  Text('Export/Share'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'print',
              child: Row(
                children: [
                  Icon(Icons.print, size: 18),
                  SizedBox(width: 8),
                  Text('Print'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, size: 18),
                  SizedBox(width: 8),
                  Text('Plan Settings'),
                ],
              ),
            ),
          ],
          onSelected: _handleMenuAction,
        ),
      ],
    );
  }

  Widget _buildEditorContent(bool isTablet) {
    return Column(
      children: [
        // Document header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _currentPlan.color.withOpacity(0.1),
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _currentPlan.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPlan.title,
                          style: TextStyle(
                            fontSize: isTablet ? 24 : 20,
                            fontWeight: FontWeight.w700,
                            color: _currentPlan.color,
                          ),
                        ),
                        if (_currentPlan.description.isNotEmpty) ...[
                          SizedBox(height: 4),
                          Text(
                            _currentPlan.description,
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (_currentPlan.curriculumOutcomeIds.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _currentPlan.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '${_currentPlan.curriculumOutcomeIds.length} Outcomes',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: _currentPlan.color,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        
        // Editor content
        Expanded(
          child: _isEditing ? _buildEditor(isTablet) : _buildPreview(isTablet),
        ),
      ],
    );
  }

  Widget _buildEditor(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: Column(
        children: [
          // Media sections
          if (_images.isNotEmpty || _hyperlinks.isNotEmpty) ...[
            _buildMediaSection(isTablet),
            SizedBox(height: 16),
          ],
          
          // Text editor
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _contentController,
                focusNode: _contentFocusNode,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                style: TextStyle(
                  fontFamily: _selectedFont == 'Default' ? null : _selectedFont,
                  fontSize: _fontSize,
                  fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                  fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                  decoration: _isUnderlined ? TextDecoration.underline : TextDecoration.none,
                ),
                textAlign: _textAlign,
                decoration: InputDecoration(
                  hintText: 'Start writing your planning document...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: _fontSize,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                ),
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media sections
            if (_images.isNotEmpty) ...[
              _buildImageGallery(isTablet),
              SizedBox(height: 24),
            ],
            if (_hyperlinks.isNotEmpty) ...[
              _buildLinksSection(isTablet),
              SizedBox(height: 24),
            ],
            
            // Content preview
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _contentController.text.isEmpty 
                    ? 'No content yet. Tap edit to start writing.'
                    : _contentController.text,
                style: TextStyle(
                  fontSize: _fontSize,
                  height: 1.5,
                  color: _contentController.text.isEmpty ? Colors.grey[500] : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Media & Links',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          
          // Images
          if (_images.isNotEmpty) ...[
            _buildImageGallery(isTablet),
            SizedBox(height: 12),
          ],
          
          // Links
          if (_hyperlinks.isNotEmpty) ...[
            _buildLinksSection(isTablet),
            SizedBox(height: 12),
          ],
          
          // Add media buttons
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _addImage,
                icon: Icon(Icons.image, size: 18),
                label: Text('Add Image'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
              SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: _addHyperlink,
                icon: Icon(Icons.link, size: 18),
                label: Text('Add Link'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageGallery(bool isTablet) {
    if (_images.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (${_images.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _images.map((image) => _buildImageThumbnail(image, isTablet)).toList(),
        ),
      ],
    );
  }

  Widget _buildImageThumbnail(DocumentImage image, bool isTablet) {
    return Container(
      width: isTablet ? 120 : 80,
      height: isTablet ? 120 : 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: Colors.grey[200],
            ),
            child: Icon(
              Icons.image,
              size: isTablet ? 40 : 30,
              color: Colors.grey[500],
            ),
          ),
          if (_isEditing)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removeImage(image),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLinksSection(bool isTablet) {
    if (_hyperlinks.isEmpty) return SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Links (${_hyperlinks.length})',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 8),
        ...(_hyperlinks.map((link) => _buildLinkItem(link, isTablet)).toList()),
      ],
    );
  }

  Widget _buildLinkItem(DocumentLink link, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.link, size: 18, color: Colors.blue[700]),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  link.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (link.description.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    link.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          if (_isEditing)
            IconButton(
              onPressed: () => _removeHyperlink(link),
              icon: Icon(Icons.delete, size: 18, color: Colors.red),
              tooltip: 'Remove link',
            ),
        ],
      ),
    );
  }

  Widget _buildToolbar(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Text formatting
                _buildToolbarButton(
                  icon: Icons.format_bold,
                  isActive: _isBold,
                  onPressed: () => _toggleBold(),
                  tooltip: 'Bold',
                ),
                _buildToolbarButton(
                  icon: Icons.format_italic,
                  isActive: _isItalic,
                  onPressed: () => _toggleItalic(),
                  tooltip: 'Italic',
                ),
                _buildToolbarButton(
                  icon: Icons.format_underlined,
                  isActive: _isUnderlined,
                  onPressed: () => _toggleUnderline(),
                  tooltip: 'Underline',
                ),
                
                SizedBox(width: 16),
                
                // Text alignment
                _buildToolbarButton(
                  icon: Icons.format_align_left,
                  isActive: _textAlign == TextAlign.left,
                  onPressed: () => setState(() => _textAlign = TextAlign.left),
                  tooltip: 'Align Left',
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_center,
                  isActive: _textAlign == TextAlign.center,
                  onPressed: () => setState(() => _textAlign = TextAlign.center),
                  tooltip: 'Align Center',
                ),
                _buildToolbarButton(
                  icon: Icons.format_align_right,
                  isActive: _textAlign == TextAlign.right,
                  onPressed: () => setState(() => _textAlign = TextAlign.right),
                  tooltip: 'Align Right',
                ),
                
                SizedBox(width: 16),
                
                // Font size
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButton<double>(
                    value: _fontSize,
                    underline: SizedBox.shrink(),
                    items: [12.0, 14.0, 16.0, 18.0, 20.0, 24.0, 28.0, 32.0]
                        .map((size) => DropdownMenuItem(
                              value: size,
                              child: Text('${size.toInt()}'),
                            ))
                        .toList(),
                    onChanged: (size) => setState(() => _fontSize = size ?? 16.0),
                  ),
                ),
                
                SizedBox(width: 16),
                
                // Media buttons
                _buildToolbarButton(
                  icon: Icons.image,
                  onPressed: _addImage,
                  tooltip: 'Add Image',
                ),
                _buildToolbarButton(
                  icon: Icons.link,
                  onPressed: _addHyperlink,
                  tooltip: 'Add Link',
                ),
                _buildToolbarButton(
                  icon: Icons.school,
                  onPressed: _addCurriculumOutcome,
                  tooltip: 'Add Curriculum Outcome',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool isActive = false,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: EdgeInsets.all(8),
          margin: EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue[100] : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isActive ? Colors.blue[700] : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  // Action methods
  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Unsaved Changes'),
        content: Text('You have unsaved changes. Do you want to save before leaving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // Don't leave, stay on page
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // Leave without saving
            child: Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _savePlan();
              Navigator.pop(context, true); // Leave after saving
            },
            child: Text('Save & Exit'),
          ),
        ],
      ),
    );
    
    return result ?? false; // If dialog is dismissed, stay on page
  }

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _contentFocusNode.requestFocus();
      }
    });
    HapticFeedback.lightImpact();
  }

  Future<void> _savePlan() async {
    setState(() => _isSaving = true);
    
    try {
      // Simulate save delay
      await Future.delayed(Duration(milliseconds: 800));
      
      final updatedDocument = _currentPlan.document.copyWith(
        content: _contentController.text,
        images: _images,
        hyperlinks: _hyperlinks,
        lastModified: DateTime.now(),
      );
      
      final updatedPlan = _currentPlan.copyWith(
        document: updatedDocument,
        updatedAt: DateTime.now(),
      );
      
      setState(() {
        _currentPlan = updatedPlan;
        _hasUnsavedChanges = false;
        _isSaving = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Plan saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Return updated plan to previous screen
      Navigator.pop(context, updatedPlan);
      
    } catch (e) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save plan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _addImage() {
    // TODO: Implement image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Image picker will be implemented with file system integration')),
    );
  }

  void _addHyperlink() {
    showDialog(
      context: context,
      builder: (context) => _AddLinkDialog(
        onLinkAdded: (link) {
          setState(() {
            _images.add(DocumentImage(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              url: '',
              fileName: 'placeholder.jpg',
              fileSize: 0,
              position: _hyperlinks.length,
            ));
            _hyperlinks.add(link);
            _hasUnsavedChanges = true;
          });
        },
      ),
    );
  }

  void _addCurriculumOutcome() {
    setState(() {
      _showCurriculumSidebar = true;
    });
    HapticFeedback.lightImpact();
  }

  void _removeImage(DocumentImage image) {
    setState(() {
      _images.removeWhere((img) => img.id == image.id);
      _hasUnsavedChanges = true;
    });
  }

  void _removeHyperlink(DocumentLink link) {
    setState(() {
      _hyperlinks.removeWhere((l) => l.id == link.id);
      _hasUnsavedChanges = true;
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'export':
        _exportPlan();
        break;
      case 'print':
        _printPlan();
        break;
      case 'settings':
        _showPlanSettings();
        break;
    }
  }

  void _exportPlan() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _printPlan() {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Print functionality coming soon!')),
    );
  }

  void _showPlanSettings() {
    // TODO: Implement plan settings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan settings coming soon!')),
    );
  }

  void _toggleCurriculumSidebar() {
    setState(() {
      _showCurriculumSidebar = !_showCurriculumSidebar;
    });
    HapticFeedback.lightImpact();
  }

  void _onCurriculumOutcomesChanged(List<CurriculumData> outcomes) {
    // Convert CurriculumData to CurriculumOutcome for consistency with the rest of the app
    final newOutcomes = outcomes.map((outcome) => CurriculumOutcome(
      id: outcome.id,
      code: outcome.code ?? '',
      description: outcome.description ?? '',
      elaboration: outcome.elaboration ?? '',
    )).toList();
    
    setState(() {
      _selectedOutcomes = newOutcomes;
      _hasUnsavedChanges = true;
    });
  }

  void _toggleBold() {
    final selection = _contentController.selection;
    if (selection.isValid) {
      // Apply formatting only to selected text
      final text = _contentController.text;
      final selectedText = text.substring(selection.start, selection.end);
      
      if (selectedText.isNotEmpty) {
        // For now, just toggle the global state and let user know
        setState(() {
          _isBold = !_isBold;
          _hasUnsavedChanges = true;
        });
        
        // Show info about formatting
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bold formatting will apply to new text you type'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // No selection, apply to future typing
      setState(() {
        _isBold = !_isBold;
        _hasUnsavedChanges = true;
      });
    }
  }

  void _toggleItalic() {
    final selection = _contentController.selection;
    setState(() {
      _isItalic = !_isItalic;
      _hasUnsavedChanges = true;
    });
    
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Italic formatting will apply to new text you type'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _toggleUnderline() {
    final selection = _contentController.selection;
    setState(() {
      _isUnderlined = !_isUnderlined;
      _hasUnsavedChanges = true;
    });
    
    if (!selection.isValid || selection.isCollapsed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Underline formatting will apply to new text you type'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

// Add Link Dialog
class _AddLinkDialog extends StatefulWidget {
  final Function(DocumentLink) onLinkAdded;

  const _AddLinkDialog({required this.onLinkAdded});

  @override
  State<_AddLinkDialog> createState() => _AddLinkDialogState();
}

class _AddLinkDialogState extends State<_AddLinkDialog> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Hyperlink'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Link Title *',
              hintText: 'e.g., Australian Curriculum',
              border: OutlineInputBorder(),
            ),
            textCapitalization: TextCapitalization.words,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'URL *',
              hintText: 'https://...',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.url,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Brief description (optional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canAddLink() ? _addLink : null,
          child: Text('Add Link'),
        ),
      ],
    );
  }

  bool _canAddLink() {
    return _titleController.text.trim().isNotEmpty &&
           _urlController.text.trim().isNotEmpty;
  }

  void _addLink() {
    final link = DocumentLink(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      url: _urlController.text.trim(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      position: 0,
    );

    widget.onLinkAdded(link);
    Navigator.pop(context);
  }
} 