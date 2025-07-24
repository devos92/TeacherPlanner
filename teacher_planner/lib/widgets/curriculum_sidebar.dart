// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/curriculum_service.dart';

/// Sidebar widget allowing users to select curriculum outcomes via cascading dropdowns.
class CurriculumSidebar extends StatefulWidget {
  final List<String> selectedOutcomeIds;
  final ValueChanged<List<String>> onOutcomesChanged;
  final double width;

  const CurriculumSidebar({
    Key? key,
    required this.selectedOutcomeIds,
    required this.onOutcomesChanged,
    this.width = 400,
  }) : super(key: key);

  @override
  _CurriculumSidebarState createState() => _CurriculumSidebarState();
}

class _CurriculumSidebarState extends State<CurriculumSidebar> {
  bool _isExpanded = false;

  // Selected IDs
  String? selectedYearId;
  String? selectedSubjectId;
  String? selectedStrandId;
  String? selectedSubStrandId;

  // Loading flags
  bool _isLoadingYear = false;
  bool _isLoadingSubject = false;
  bool _isLoadingStrands = false;
  bool _isLoadingSubStrands = false;
  bool _isLoadingOutcomes = false;

  // Data lists
  List<CurriculumData> _years = [];
  List<CurriculumData> _subjects = [];
  List<CurriculumData> _strands = [];
  List<CurriculumData> _subStrands = [];
  List<CurriculumData> _outcomes = [];

  @override
  void initState() {
    super.initState();
    _loadYears();
  }

  Future<void> _loadYears() async {
    setState(() { _isLoadingYear = true; });
    try {
      _years = await CurriculumService.getYears();
      selectedYearId = _years.isNotEmpty ? _years.first.id : null;
      if (selectedYearId != null) _loadSubjects();
    } catch (_) {
      _years = [];
    }
    setState(() { _isLoadingYear = false; });
  }

  Future<void> _loadSubjects() async {
    if (selectedYearId == null) return;
    setState(() { _isLoadingSubject = true; });
    try {
      final yearName = _years.firstWhere((y) => y.id == selectedYearId).name;
      _subjects = await CurriculumService.getSubjectsForYear(yearName);
      selectedSubjectId = _subjects.isNotEmpty ? _subjects.first.id : null;
      if (selectedSubjectId != null) _loadStrands();
    } catch (_) {
      _subjects = [];
    }
    setState(() { _isLoadingSubject = false; });
  }

  Future<void> _loadStrands() async {
    if (selectedSubjectId == null || selectedYearId == null) return;
    setState(() { _isLoadingStrands = true; });
    try {
      final yearName = _years.firstWhere((y) => y.id == selectedYearId).name;
      _strands = await CurriculumService.getStrandsForSubjectAndYear(selectedSubjectId!, yearName);
      selectedStrandId = _strands.isNotEmpty ? _strands.first.id : null;
      if (selectedStrandId != null) _loadSubStrands();
      else _loadOutcomes();
    } catch (_) {
      _strands = [];
    }
    setState(() { _isLoadingStrands = false; });
  }

  Future<void> _loadSubStrands() async {
    if (selectedStrandId == null || selectedYearId == null) return;
    setState(() { _isLoadingSubStrands = true; });
    try {
      final yearName = _years.firstWhere((y) => y.id == selectedYearId).name;
      _subStrands = await CurriculumService.getSubStrandsForStrandAndYear(selectedStrandId!, yearName);
      selectedSubStrandId = _subStrands.isNotEmpty ? _subStrands.first.id : null;
      _loadOutcomes();
    } catch (_) {
      _subStrands = [];
    }
    setState(() { _isLoadingSubStrands = false; });
  }

  Future<void> _loadOutcomes() async {
    if (selectedYearId == null) return;
    setState(() { _isLoadingOutcomes = true; });
    try {
      final yearName = _years.firstWhere((y) => y.id == selectedYearId).name;
      if (selectedSubStrandId != null) {
        _outcomes = await CurriculumService.getOutcomesForSubStrandAndYear(
          selectedStrandId!, selectedSubStrandId!, yearName);
      } else if (selectedStrandId != null) {
        _outcomes = await CurriculumService.getOutcomesForSubStrandAndYear(
          selectedStrandId!, '', yearName);
      } else if (selectedSubjectId != null) {
        _outcomes = await CurriculumService.getOutcomesBySubjectAndYear(
          selectedSubjectId!, yearName);
      } else {
        _outcomes = [];
      }
    } catch (_) {
      _outcomes = [];
    }
    setState(() { _isLoadingOutcomes = false; });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: widget.width,
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(right: BorderSide(color: theme.dividerColor)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              border: Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Icon(Icons.school, color: theme.primaryColor),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Curriculum Outcomes',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(_isExpanded ? Icons.close : Icons.add),
                  onPressed: () => setState(() => _isExpanded = !_isExpanded),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isExpanded ? _buildExpandedView(theme) : _buildCollapsedView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView(ThemeData theme) {
    final selected = _outcomes.where((o) => widget.selectedOutcomeIds.contains(o.id)).toList();
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ElevatedButton.icon(
            onPressed: () => setState(() => _isExpanded = true),
            icon: Icon(Icons.add),
            label: Text('Add Curriculum Outcomes'),
          ),
          SizedBox(height: 16),
          if (selected.isEmpty)
            Text('No outcomes selected', style: theme.textTheme.bodyMedium)
          else
            ...selected.map((o) => ListTile(
              title: Text(o.description ?? ''),
              trailing: IconButton(
                icon: Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  final list = List<String>.from(widget.selectedOutcomeIds)..remove(o.id);
                  widget.onOutcomesChanged(list);
                },
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildExpandedView(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildDropdown(
            label: 'Year Level',
            isLoading: _isLoadingYear,
            value: selectedYearId,
            items: _years,
            onChanged: (v) => setState(() {
              selectedYearId = v;
              selectedSubjectId = selectedStrandId = selectedSubStrandId = null;
              _subjects.clear(); _strands.clear(); _subStrands.clear(); _outcomes.clear();
              _loadSubjects();
            }),
          ),
          _buildDropdown(
            label: 'Subject',
            isLoading: _isLoadingSubject,
            value: selectedSubjectId,
            items: _subjects,
            onChanged: (v) => setState(() {
              selectedSubjectId = v;
              selectedStrandId = selectedSubStrandId = null;
              _strands.clear(); _subStrands.clear(); _outcomes.clear();
              _loadStrands();
            }),
          ),
          _buildDropdown(
            label: 'Strand',
            isLoading: _isLoadingStrands,
            value: selectedStrandId,
            items: _strands,
            onChanged: (v) => setState(() {
              selectedStrandId = v;
              selectedSubStrandId = null;
              _subStrands.clear(); _outcomes.clear();
              _loadSubStrands();
            }),
          ),
          _buildDropdown(
            label: 'Sub‐Strand',
            isLoading: _isLoadingSubStrands,
            value: selectedSubStrandId,
            items: _subStrands,
            onChanged: (v) => setState(() {
              selectedSubStrandId = v;
              _outcomes.clear();
              _loadOutcomes();
            }),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: _isLoadingOutcomes
              ? Center(child: CircularProgressIndicator())
              : _buildOutcomeList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required bool isLoading,
    required String? value,
    required List<CurriculumData> items,
    required ValueChanged<String?> onChanged,
  }) {
    if (isLoading) return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Center(child: CircularProgressIndicator()),
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        items: items.map((d) => DropdownMenuItem(
          value: d.id,
          child: Text(d.name, overflow: TextOverflow.ellipsis),
        )).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildOutcomeList(ThemeData theme) {
    return Column(
      children: _outcomes.map((o) {
        final selected = widget.selectedOutcomeIds.contains(o.id);
        return CheckboxListTile(
          title: Text(o.code ?? ''),
          subtitle: Text(o.description ?? ''),
          value: selected,
          onChanged: (v) {
            final list = List<String>.from(widget.selectedOutcomeIds);
            if (v == true) list.add(o.id); else list.remove(o.id);
            widget.onOutcomesChanged(list);
          },
        );
      }).toList(),
    );
  }
}