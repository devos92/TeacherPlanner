// lib/pages/long_term_planning_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/long_term_plan_models.dart';
import '../models/curriculum_models.dart';
import '../utils/responsive_utils.dart';
import '../widgets/curriculum_sidebar.dart';
import 'long_term_planning_editor_page.dart';

class LongTermPlanningPage extends StatefulWidget {
  const LongTermPlanningPage({Key? key}) : super(key: key);

  @override
  _LongTermPlanningPageState createState() => _LongTermPlanningPageState();
}

class _LongTermPlanningPageState extends State<LongTermPlanningPage> {
  List<LongTermPlan> _plans = [];
  bool _isLoading = false;
  String _searchQuery = '';
  bool _showCurriculumSidebar = false;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);
    
    // TODO: Load from database
    // For now, create sample data
    await Future.delayed(Duration(milliseconds: 500));
    
    setState(() {
      _plans = [
        // Sample plans will be added here
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Long-Term Planning',
          style: TextStyle(
            fontSize: context.isTablet ? 20 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 2,
        actions: [
          IconButton(
            icon: Icon(Icons.school),
            onPressed: _toggleCurriculumSidebar,
            tooltip: 'Curriculum Outcomes',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showSearchDialog,
            tooltip: 'Search plans',
          ),
          IconButton(
            icon: Icon(Icons.sort),
            onPressed: _showSortOptions,
            tooltip: 'Sort plans',
          ),
        ],
      ),
      
      body: SafeArea(
        child: Row(
          children: [
            // Main content
            Expanded(
              child: _isLoading ? _buildLoadingView() : _buildMainContent(),
            ),
            
            // Curriculum sidebar
            if (_showCurriculumSidebar)
              SizedBox(
                width: context.isTablet ? 350 : 300,
                child: CurriculumSidebar(
                  width: context.isTablet ? 350 : 300,
                  onSelectionChanged: _onCurriculumOutcomesChanged,
                ),
              ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreatePlanDialog(),
        icon: Icon(Icons.add),
        label: Text('New Plan'),
        tooltip: 'Create a new long-term plan',
      ),
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
      // For now, just show a message. This will be connected to plan creation later
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected ${newOutcomes.length} curriculum outcomes')),
      );
    });
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your planning documents...'),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (_plans.isEmpty) {
      return _buildEmptyState();
    }

    final filteredPlans = _searchQuery.isEmpty 
        ? _plans 
        : _plans.where((plan) => 
            plan.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            plan.subject.toLowerCase().contains(_searchQuery.toLowerCase())
          ).toList();

    return Column(
      children: [
        if (_searchQuery.isNotEmpty) _buildSearchHeader(),
        Expanded(
          child: ResponsiveBuilder(
            mobile: _buildMobileList(filteredPlans),
            tablet: _buildTabletGrid(filteredPlans),
            desktop: _buildDesktopGrid(filteredPlans),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: ResponsiveUtils.getAdaptivePadding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: context.isTablet ? 120 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24),
            Text(
              'No Planning Documents Yet',
              style: TextStyle(
                fontSize: context.isTablet ? 24 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Create your first long-term planning document to get started. Choose from templates or start from scratch.',
              style: TextStyle(
                fontSize: context.isTablet ? 16 : 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreatePlanDialog(),
              icon: Icon(Icons.add),
              label: Text('Create Your First Plan'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isTablet ? 32 : 24,
                  vertical: context.isTablet ? 16 : 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.blue[50],
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.blue[700]),
          SizedBox(width: 8),
          Text(
            'Searching for "$_searchQuery"',
            style: TextStyle(
              color: Colors.blue[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          Spacer(),
          TextButton(
            onPressed: () {
              setState(() => _searchQuery = '');
            },
            child: Text('Clear'),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList(List<LongTermPlan> plans) {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(plans[index], isMobile: true);
      },
    );
  }

  Widget _buildTabletGrid(List<LongTermPlan> plans) {
    return GridView.builder(
      padding: EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(plans[index]);
      },
    );
  }

  Widget _buildDesktopGrid(List<LongTermPlan> plans) {
    return GridView.builder(
      padding: EdgeInsets.all(32),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
      ),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        return _buildPlanCard(plans[index]);
      },
    );
  }

  Widget _buildPlanCard(LongTermPlan plan, {bool isMobile = false}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _openPlan(plan),
        onLongPress: () => _showPlanOptions(plan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with subject and color indicator
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: plan.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      plan.subject,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, size: 18),
                    onSelected: (action) => _handlePlanAction(action, plan),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 18),
                            SizedBox(width: 8),
                            Text('Duplicate'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Title
              Text(
                plan.title,
                style: TextStyle(
                  fontSize: isMobile ? 18 : 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: 8),
              
              // Description
              if (plan.description.isNotEmpty) ...[
                Text(
                  plan.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: isMobile ? 2 : 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
              ],
              
              if (!isMobile) Spacer(),
              
              // Footer with metadata
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 4),
                  Text(
                    _formatDate(plan.updatedAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: plan.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      plan.yearLevel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: plan.color,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCreatePlanDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreatePlanDialog(
        onPlanCreated: (plan) {
          setState(() {
            _plans.add(plan);
          });
          _openPlan(plan);
        },
        onShowCurriculumSidebar: () {
          setState(() {
            _showCurriculumSidebar = true;
          });
        },
      ),
    );
  }

  void _openPlan(LongTermPlan plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LongTermPlanningEditorPage(plan: plan),
      ),
    ).then((updatedPlan) {
      if (updatedPlan != null && updatedPlan is LongTermPlan) {
        setState(() {
          final index = _plans.indexWhere((p) => p.id == updatedPlan.id);
          if (index != -1) {
            _plans[index] = updatedPlan;
          }
        });
      }
    });
  }

  void _showPlanOptions(LongTermPlan plan) {
    HapticFeedback.mediumImpact();
    
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Plan'),
              onTap: () {
                Navigator.pop(context);
                _openPlan(plan);
              },
            ),
            ListTile(
              leading: Icon(Icons.copy),
              title: Text('Duplicate Plan'),
              onTap: () {
                Navigator.pop(context);
                _duplicatePlan(plan);
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Plan', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deletePlan(plan);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handlePlanAction(String action, LongTermPlan plan) {
    switch (action) {
      case 'edit':
        _openPlan(plan);
        break;
      case 'duplicate':
        _duplicatePlan(plan);
        break;
      case 'delete':
        _deletePlan(plan);
        break;
    }
  }

  void _duplicatePlan(LongTermPlan plan) {
    // TODO: Implement duplication
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plan duplication coming soon!')),
    );
  }

  void _deletePlan(LongTermPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _plans.removeWhere((p) => p.id == plan.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Plan deleted')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String query = _searchQuery;
        return AlertDialog(
          title: Text('Search Plans'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Enter search terms...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => query = value,
            onSubmitted: (value) {
              setState(() => _searchQuery = value);
              Navigator.pop(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() => _searchQuery = query);
                Navigator.pop(context);
              },
              child: Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showSortOptions() {
    // TODO: Implement sorting options
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sort options coming soon!')),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;
    
    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

// Create Plan Dialog
class _CreatePlanDialog extends StatefulWidget {
  final Function(LongTermPlan) onPlanCreated;
  final Function() onShowCurriculumSidebar;

  const _CreatePlanDialog({required this.onPlanCreated, required this.onShowCurriculumSidebar});

  @override
  State<_CreatePlanDialog> createState() => _CreatePlanDialogState();
}

class _CreatePlanDialogState extends State<_CreatePlanDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedSubject = '';
  String _selectedYearLevel = '';
  PlanningTemplate _selectedTemplate = PlanningTemplate.blank;
  Color _selectedColor = const Color(0xFFA36361); // Default to first lesson color
  List<String> _selectedOutcomes = [];

  final List<String> _subjects = [
    'Mathematics',
    'English',
    'Science', 
    'History',
    'Geography',
    'Art',
    'Music',
    'Physical Education',
    'Technology',
    'Languages',
  ];

  final List<String> _yearLevels = [
    'Foundation',
    'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6',
    'Year 7', 'Year 8', 'Year 9', 'Year 10', 'Year 11', 'Year 12',
  ];

  // Use the same color palette as lessons and events
  static const List<Color> _planColors = [
    Color(0xFFA36361), 
    Color(0xFF88895B), 
    Color(0xFF558E9B), 
    Color(0xFFA386A9), 
    Color(0xFFC96349),
    Color(0xFF84A48B), 
    Color(0xFF7BB2BA), 
    Color(0xFFE89B88), 
    Color(0xFFF79E70), 
    Color(0xFFAECBB8), 
    Color(0xFFC1D8DF), 
    Color(0xFFF9D0CD),
    Color(0xFFE7C878), 
    Color(0xFFF6D487),
    Color(0xFFC6B3CA), 
    Color(0xFFD1A996),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = context.isTablet;
    
    return AlertDialog(
      title: Text('Create New Plan'),
      content: Container(
        width: isTablet ? 600 : double.maxFinite,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Plan Title *',
                  hintText: 'e.g., Year 3 Mathematics Unit 1',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              
              SizedBox(height: 16),
              
              // Subject and Year Level Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSubject.isEmpty ? null : _selectedSubject,
                      decoration: InputDecoration(
                        labelText: 'Subject *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _subjects.map((subject) => 
                        DropdownMenuItem(value: subject, child: Text(subject))
                      ).toList(),
                      onChanged: (value) => setState(() => _selectedSubject = value ?? ''),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedYearLevel.isEmpty ? null : _selectedYearLevel,
                      decoration: InputDecoration(
                        labelText: 'Year Level *',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: _yearLevels.map((level) => 
                        DropdownMenuItem(value: level, child: Text(level))
                      ).toList(),
                      onChanged: (value) => setState(() => _selectedYearLevel = value ?? ''),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Description
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  hintText: 'Brief description of this planning document...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
              
              SizedBox(height: 16),
              
              // Template Selection
              Text(
                'Choose Template',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              _buildTemplateSelector(),
              
              SizedBox(height: 16),
              
              // Color Selection
              Text(
                'Plan Color',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              _buildColorSelector(),
              
              SizedBox(height: 16),
              
              // Curriculum Outcomes Button
              OutlinedButton.icon(
                onPressed: widget.onShowCurriculumSidebar,
                icon: Icon(Icons.school),
                label: Text('Add Curriculum Outcomes (${_selectedOutcomes.length})'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canCreate() ? _createPlan : null,
          child: Text('Create Plan'),
        ),
      ],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildTemplateSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PlanningTemplate.values.map((template) {
        final isSelected = _selectedTemplate == template;
        return ChoiceChip(
          label: Text(template.displayName),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              setState(() => _selectedTemplate = template);
            }
          },
          avatar: isSelected ? null : Icon(template.icon, size: 18),
          selectedColor: template.color.withOpacity(0.2),
        );
      }).toList(),
    );
  }

  Widget _buildColorSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _planColors.map((color) {
        final isSelected = _selectedColor == color;
        return GestureDetector(
          onTap: () => setState(() => _selectedColor = color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected ? Icon(Icons.check, color: Colors.white) : null,
          ),
        );
      }).toList(),
    );
  }

  bool _canCreate() {
    return _titleController.text.trim().isNotEmpty &&
           _selectedSubject.isNotEmpty &&
           _selectedYearLevel.isNotEmpty;
  }

  void _createPlan() {
    final now = DateTime.now();
    final plan = LongTermPlan(
      id: now.millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      subject: _selectedSubject,
      yearLevel: _selectedYearLevel,
      description: _descriptionController.text.trim(),
      createdAt: now,
      updatedAt: now,
      teacherId: 'current_teacher', // TODO: Get from auth
      color: _selectedColor,
      curriculumOutcomeIds: _selectedOutcomes,
      document: PlanningDocument(
        id: '${now.millisecondsSinceEpoch}_doc',
        content: _selectedTemplate.templateContent,
        lastModified: now,
      ),
    );

    widget.onPlanCreated(plan);
    Navigator.pop(context);
  }
} 