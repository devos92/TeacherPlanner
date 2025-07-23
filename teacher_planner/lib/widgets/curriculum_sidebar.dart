// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/supabase_curriculum_service.dart';

class CurriculumSidebar extends StatefulWidget {
  final List<String> selectedOutcomeIds;
  final Function(List<String>) onOutcomesChanged;
  final double width;

  const CurriculumSidebar({
    Key? key,
    required this.selectedOutcomeIds,
    required this.onOutcomesChanged,
    this.width = 400, // Increased default from 300 to 400
  }) : super(key: key);

  @override
  _CurriculumSidebarState createState() => _CurriculumSidebarState();
}

class _CurriculumSidebarState extends State<CurriculumSidebar> {
  bool _isExpanded = false;
  String? selectedYearId;
  String? selectedSubjectId;
  String? selectedStrandId;
  
  // Loading states
  bool _isLoadingYear = false;
  bool _isLoadingSubject = false;
  bool _isLoadingStrands = false;
  bool _isLoadingOutcomes = false;
  
  // Data
  List<CurriculumData> _years = [];
  List<CurriculumData> _subjects = [];
  List<CurriculumData> _strands = [];
  List<CurriculumData> _outcomes = [];

  @override
  void initState() {
    super.initState();
    selectedYearId = 'foundation';
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadYears();
    await _loadSubjects();
  }

  Future<void> _loadYears() async {
    setState(() {
      _isLoadingYear = true;
    });

    try {
      final years = await SupabaseCurriculumService.getYears();
      setState(() {
        _years = years;
        _isLoadingYear = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingYear = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load years: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadSubjects() async {
    setState(() {
      _isLoadingSubject = true;
    });

    try {
      final subjects = await SupabaseCurriculumService.getSubjects();
      setState(() {
        _subjects = subjects;
        _isLoadingSubject = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingSubject = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load subjects: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadStrands() async {
    if (selectedSubjectId == null) return;

    setState(() {
      _isLoadingStrands = true;
    });

    try {
      final strands = await SupabaseCurriculumService.getStrandsForSubject(selectedSubjectId!);
      setState(() {
        _strands = strands;
        _isLoadingStrands = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingStrands = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load strands: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadOutcomes() async {
    if (selectedStrandId == null || selectedYearId == null) return;

    setState(() {
      _isLoadingOutcomes = true;
    });

    try {
      final outcomes = await SupabaseCurriculumService.getOutcomesForStrandAndYear(
        selectedStrandId!, 
        selectedYearId!
      );
      setState(() {
        _outcomes = outcomes;
        _isLoadingOutcomes = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingOutcomes = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load outcomes: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<CurriculumData> _getSelectedOutcomes() {
    return _outcomes.where((outcome) => 
      widget.selectedOutcomeIds.contains(outcome.id)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          right: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              border: Border(
                bottom: BorderSide(color: theme.dividerColor),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: theme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Australian Curriculum',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (widget.selectedOutcomeIds.isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${widget.selectedOutcomeIds.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: _isExpanded 
                ? _buildExpandedView(theme)
                : _buildCollapsedView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView(ThemeData theme) {
    final selectedOutcomes = _getSelectedOutcomes();
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Add Curriculum Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isExpanded = true;
                });
              },
              icon: Icon(Icons.add, size: 20),
              label: Text('Add Curriculum Outcomes'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          if (selectedOutcomes.isNotEmpty) ...[
            SizedBox(height: 24),
            Text(
              'Selected Outcomes',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            ...selectedOutcomes.map((outcome) => _buildOutcomeCard(outcome, theme)).toList(),
          ] else ...[
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No curriculum outcomes selected',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tap the button above to add outcomes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExpandedView(ThemeData theme) {
    return Column(
      children: [
        // Minimize Button
        Container(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'Select Curriculum Outcomes',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                icon: Icon(Icons.minimize),
                tooltip: 'Minimize',
              ),
            ],
          ),
        ),

        // Year Selection
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Year Level',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: selectedYearId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: _years.map((year) {
                  return DropdownMenuItem(
                    value: year.id,
                    child: Text(
                      year.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedYearId = value;
                    selectedSubjectId = null;
                    selectedStrandId = null;
                    _strands = [];
                    _outcomes = [];
                  });
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Subject Selection
        if (_subjects.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subject',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedSubjectId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _subjects.map((subject) {
                    return DropdownMenuItem(
                      value: subject.id,
                      child: Text(
                        subject.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSubjectId = value;
                      selectedStrandId = null;
                      _strands = [];
                      _outcomes = [];
                    });
                    _loadStrands();
                  },
                ),
              ],
            ),
          ),

        SizedBox(height: 16),

        // Strand Selection
        if (_strands.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Strand',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedStrandId,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _strands.map((strand) {
                    return DropdownMenuItem(
                      value: strand.id,
                      child: Text(
                        strand.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStrandId = value;
                      _outcomes = [];
                    });
                    _loadOutcomes();
                  },
                ),
              ],
            ),
          ),

        SizedBox(height: 16),

        // Outcomes List
        if (_outcomes.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Outcomes',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _outcomes.length,
                    itemBuilder: (context, index) {
                      final outcome = _outcomes[index];
                      final isSelected = widget.selectedOutcomeIds.contains(outcome.id);
                      
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: CheckboxListTile(
                          title: Text(
                            outcome.code ?? 'No Code',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          subtitle: Text(
                            outcome.description ?? 'No description',
                            style: TextStyle(fontSize: 11),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          value: isSelected,
                          onChanged: (bool? value) {
                            final newSelection = List<String>.from(widget.selectedOutcomeIds);
                            if (value == true) {
                              newSelection.add(outcome.id);
                            } else {
                              newSelection.remove(outcome.id);
                            }
                            widget.onOutcomesChanged(newSelection);
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        else if (_isLoadingOutcomes)
          Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        else if (selectedStrandId != null)
          Expanded(
            child: Center(
              child: Text(
                'No outcomes found for this strand and year level',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOutcomeCard(CurriculumData outcome, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    outcome.code ?? 'No Code',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final newSelection = List<String>.from(widget.selectedOutcomeIds);
                    newSelection.remove(outcome.id);
                    widget.onOutcomesChanged(newSelection);
                  },
                  icon: Icon(Icons.remove_circle_outline, size: 20),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              outcome.description ?? 'No description',
              style: theme.textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 