// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../services/curriculum_service.dart';
import '../models/curriculum_models.dart';

class CurriculumSidebar extends StatefulWidget {
  final double width;
  final Function(List<CurriculumData>) onSelectionChanged;

  const CurriculumSidebar({
    Key? key,
    required this.width,
    required this.onSelectionChanged,
  }) : super(key: key);

  @override
  _CurriculumSidebarState createState() => _CurriculumSidebarState();
}

class _CurriculumSidebarState extends State<CurriculumSidebar> {
  bool _expanded = true;
  bool _loading = false;
  
  // Data lists
  List<CurriculumData> _years = [];
  List<CurriculumData> _subjects = [];
  List<CurriculumData> _strands = [];
  List<CurriculumData> _subStrands = [];
  List<CurriculumData> _outcomes = [];
  
  // Selected values
  String? _selectedYearId;
  String? _selectedSubjectId;
  String? _selectedStrandId;
  String? _selectedSubStrandId;
  
  // Loading states
  bool _isLoadingYear = false;
  bool _isLoadingSubject = false;
  bool _isLoadingStrands = false;
  bool _isLoadingSubStrands = false;
  bool _isLoadingOutcomes = false;

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    setState(() => _isLoadingYear = true);
    try {
      final years = await CurriculumService.getYears();
      setState(() {
        _years = years;
        _isLoadingYear = false;
      });
    } catch (e) {
      print('Error loading years: $e');
      setState(() => _isLoadingYear = false);
    }
  }

  Future<void> _loadSubjectsForYear(String yearId) async {
    setState(() => _isLoadingSubject = true);
    try {
      final subjects = await CurriculumService.getSubjectsForYear(yearId);
      setState(() {
        _subjects = subjects;
        _isLoadingSubject = false;
      });
    } catch (e) {
      print('Error loading subjects: $e');
      setState(() => _isLoadingSubject = false);
    }
  }

  Future<void> _loadStrandsForSubject(String subjectId, String yearId) async {
    setState(() => _isLoadingStrands = true);
    try {
      final strands = await CurriculumService.getStrandsForSubjectAndYear(subjectId, yearId);
      setState(() {
        _strands = strands;
        _isLoadingStrands = false;
      });
    } catch (e) {
      print('Error loading strands: $e');
      setState(() => _isLoadingStrands = false);
    }
  }

  Future<void> _loadSubStrandsForStrand(String strandId, String yearId) async {
    setState(() => _isLoadingSubStrands = true);
    try {
      final subStrands = await CurriculumService.getSubStrandsForStrandAndYear(strandId, yearId);
      setState(() {
        _subStrands = subStrands;
        _isLoadingSubStrands = false;
      });
    } catch (e) {
      print('Error loading sub-strands: $e');
      setState(() => _isLoadingSubStrands = false);
    }
  }

  Future<void> _loadOutcomesForStrand(String strandId, String yearId) async {
    setState(() => _isLoadingOutcomes = true);
    try {
      final outcomes = await CurriculumService.getOutcomesForStrandAndYear(strandId, yearId);
      setState(() {
        _outcomes = outcomes;
        _isLoadingOutcomes = false;
      });
    } catch (e) {
      print('Error loading outcomes: $e');
      setState(() => _isLoadingOutcomes = false);
    }
  }

  Future<void> _loadOutcomesForSubStrand(String strandId, String subStrandId, String yearId) async {
    setState(() => _isLoadingOutcomes = true);
    try {
      final outcomes = await CurriculumService.getOutcomesForSubStrandAndYear(strandId, subStrandId, yearId);
      setState(() {
        _outcomes = outcomes;
        _isLoadingOutcomes = false;
      });
    } catch (e) {
      print('Error loading sub-strand outcomes: $e');
      setState(() => _isLoadingOutcomes = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sidebarW = widget.width;

    return Container(
      width: sidebarW,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Header with expand/collapse button
          Container(
            color: theme.primaryColor.withOpacity(0.1),
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.school, color: theme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Curriculum Outcomes',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(_expanded ? Icons.close : Icons.filter_list),
                  onPressed: () => setState(() => _expanded = !_expanded),
                ),
              ],
            ),
          ),
          Expanded(
            child: _expanded
                ? _buildFilterView(theme)
                : _buildSummaryView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterView(ThemeData theme) => SingleChildScrollView(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Year Level Dropdown
        Text('Year Level', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        _isLoadingYear
            ? Center(child: CircularProgressIndicator())
            : DropdownButtonFormField<String>(
                value: _selectedYearId,
                decoration: InputDecoration(
                  labelText: 'Select Year Level',
                  border: OutlineInputBorder(),
                ),
                items: _years.map((year) => DropdownMenuItem(
                  value: year.id,
                  child: Text(year.name, overflow: TextOverflow.ellipsis),
                )).toList(),
                onChanged: (value) async {
                  setState(() {
                    _selectedYearId = value;
                    _selectedSubjectId = null;
                    _selectedStrandId = null;
                    _selectedSubStrandId = null;
                    _subjects = [];
                    _strands = [];
                    _subStrands = [];
                    _outcomes = [];
                  });
                  if (value != null) {
                    await _loadSubjectsForYear(value);
                  }
                },
              ),
        SizedBox(height: 16),

        // Subject Dropdown
        if (_selectedYearId != null) ...[
          Text('Subject', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _isLoadingSubject
              ? Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  decoration: InputDecoration(
                    labelText: 'Select Subject',
                    border: OutlineInputBorder(),
                  ),
                  items: _subjects.map((subject) => DropdownMenuItem(
                    value: subject.id,
                    child: Text(subject.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) async {
                    setState(() {
                      _selectedSubjectId = value;
                      _selectedStrandId = null;
                      _selectedSubStrandId = null;
                      _strands = [];
                      _subStrands = [];
                      _outcomes = [];
                    });
                    if (value != null && _selectedYearId != null) {
                      await _loadStrandsForSubject(value, _selectedYearId!);
                    }
                  },
                ),
          SizedBox(height: 16),
        ],

        // Strand Dropdown
        if (_selectedSubjectId != null && _strands.isNotEmpty) ...[
          Text('Strand', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _isLoadingStrands
              ? Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: _selectedStrandId,
                  decoration: InputDecoration(
                    labelText: 'Select Strand',
                    border: OutlineInputBorder(),
                  ),
                  items: _strands.map((strand) => DropdownMenuItem(
                    value: strand.id,
                    child: Text(strand.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) async {
                    setState(() {
                      _selectedStrandId = value;
                      _selectedSubStrandId = null;
                      _subStrands = [];
                      _outcomes = [];
                    });
                    if (value != null && _selectedYearId != null) {
                      await _loadSubStrandsForStrand(value, _selectedYearId!);
                      await _loadOutcomesForStrand(value, _selectedYearId!);
                    }
                  },
                ),
          SizedBox(height: 16),
        ],

        // Sub-Strand Dropdown (optional)
        if (_selectedStrandId != null && _subStrands.isNotEmpty) ...[
          Text('Sub-Strand', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _isLoadingSubStrands
              ? Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: _selectedSubStrandId,
                  decoration: InputDecoration(
                    labelText: 'Select Sub-Strand (Optional)',
                    border: OutlineInputBorder(),
                  ),
                  items: _subStrands.map((subStrand) => DropdownMenuItem(
                    value: subStrand.id,
                    child: Text(subStrand.name, overflow: TextOverflow.ellipsis),
                  )).toList(),
                  onChanged: (value) async {
                    setState(() {
                      _selectedSubStrandId = value;
                      _outcomes = [];
                    });
                    if (value != null && _selectedStrandId != null && _selectedYearId != null) {
                      await _loadOutcomesForSubStrand(_selectedStrandId!, value, _selectedYearId!);
                    }
                  },
                ),
          SizedBox(height: 16),
        ],

        // Outcomes List
        if (_outcomes.isNotEmpty) ...[
          Text('Curriculum Outcomes', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          _isLoadingOutcomes
              ? Center(child: CircularProgressIndicator())
              : Container(
                  height: 400,
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    itemCount: _outcomes.length,
                    itemBuilder: (context, index) {
                      final outcome = _outcomes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        elevation: 1,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Code
                              if (outcome.code != null) ...[
                                Text(
                                  outcome.code!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'monospace',
                                    color: theme.textTheme.bodySmall?.color,
                                  ),
                                ),
                                SizedBox(height: 6),
                              ],
                              // Description
                              Text(
                                outcome.name,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],

        // Add Curriculum Outcomes Button
        if (_selectedYearId != null && _selectedSubjectId != null) ...[
          SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selectedStrandId != null ? () {
                // Handle adding selected outcomes
                if (_outcomes.isNotEmpty) {
                  widget.onSelectionChanged(_outcomes);
                }
              } : null,
              icon: Icon(Icons.add),
              label: Text('Add Curriculum Outcomes'),
            ),
          ),
        ],

        // No data message
        if (_selectedYearId != null && _subjects.isEmpty && !_isLoadingSubject) ...[
          SizedBox(height: 16),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'No subjects found for this year level',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ],
    ),
  );

  Widget _buildSummaryView(ThemeData theme) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.school, size: 48, color: theme.primaryColor.withOpacity(0.5)),
        SizedBox(height: 8),
        Text(
          'Curriculum\nOutcomes',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.primaryColor.withOpacity(0.7),
          ),
        ),
      ],
    ),
  );
}
