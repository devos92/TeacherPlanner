// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/curriculum_service.dart';

class CurriculumSidebar extends StatefulWidget {
  final List<String> selectedOutcomeIds;
  final Function(List<String>) onOutcomesChanged;
  final double width;

  const CurriculumSidebar({
    Key? key,
    required this.selectedOutcomeIds,
    required this.onOutcomesChanged,
    this.width = 300,
  }) : super(key: key);

  @override
  _CurriculumSidebarState createState() => _CurriculumSidebarState();
}

class _CurriculumSidebarState extends State<CurriculumSidebar> {
  bool _isExpanded = false;
  String? selectedYearId;
  String? selectedSubjectId;
  final CurriculumService _curriculumService = CurriculumService();
  
  // Loading states
  bool _isLoadingYear = false;
  bool _isLoadingSubject = false;
  CurriculumYear? _currentYearData;

  @override
  void initState() {
    super.initState();
    selectedYearId = 'foundation';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final curriculumYears = _curriculumService.getCurriculumYears();

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
                ? _buildExpandedView(theme, curriculumYears)
                : _buildCollapsedView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView(ThemeData theme) {
    final selectedOutcomes = _curriculumService.getSelectedOutcomes(widget.selectedOutcomeIds);
    
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
                _loadYearData();
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

  Widget _buildExpandedView(ThemeData theme, List<CurriculumYear> curriculumYears) {
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
                items: curriculumYears.map((year) {
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
                    _currentYearData = null;
                  });
                  _loadYearData();
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 16),

        // Subject Selection
        if (_currentYearData != null && _currentYearData!.subjects.isNotEmpty)
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
                  items: _currentYearData!.subjects.map((subject) {
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
                    });
                  },
                ),
              ],
            ),
          ),

        SizedBox(height: 16),

        // Loading indicator or content
        if (_isLoadingYear)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading curriculum data...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_currentYearData != null && selectedSubjectId != null)
          Expanded(
            child: _buildStrandsAndOutcomes(_currentYearData!),
          )
        else if (_currentYearData != null)
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select a subject to view outcomes',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select a year level to load curriculum data',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStrandsAndOutcomes(CurriculumYear year) {
    final theme = Theme.of(context);
    final selectedSubject = year.subjects.firstWhere(
      (subject) => subject.id == selectedSubjectId,
    );

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            selectedSubject.name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16),
          ...selectedSubject.strands.map((strand) {
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(
                  strand.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  strand.description,
                  style: theme.textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                children: strand.outcomes.map((outcome) {
                  final isSelected = widget.selectedOutcomeIds.contains(outcome.id);
                  return ListTile(
                    dense: true,
                    leading: Checkbox(
                      value: isSelected,
                      onChanged: (value) {
                        final newSelectedIds = List<String>.from(widget.selectedOutcomeIds);
                        if (value == true) {
                          newSelectedIds.add(outcome.id);
                        } else {
                          newSelectedIds.remove(outcome.id);
                        }
                        widget.onOutcomesChanged(newSelectedIds);
                      },
                    ),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      final newSelectedIds = List<String>.from(widget.selectedOutcomeIds);
                      if (isSelected) {
                        newSelectedIds.remove(outcome.id);
                      } else {
                        newSelectedIds.add(outcome.id);
                      }
                      widget.onOutcomesChanged(newSelectedIds);
                    },
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildOutcomeCard(CurriculumOutcome outcome, ThemeData theme) {
    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: theme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.school,
            size: 16,
            color: theme.primaryColor,
          ),
        ),
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
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
          onPressed: () {
            final newSelectedIds = List<String>.from(widget.selectedOutcomeIds);
            newSelectedIds.remove(outcome.id);
            widget.onOutcomesChanged(newSelectedIds);
          },
        ),
      ),
    );
  }

  Future<void> _loadYearData() async {
    if (selectedYearId == null) return;

    setState(() {
      _isLoadingYear = true;
    });

    try {
      final yearData = await _curriculumService.getCurriculumYear(selectedYearId!);
      setState(() {
        _currentYearData = yearData;
        _isLoadingYear = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingYear = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load curriculum data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
} 