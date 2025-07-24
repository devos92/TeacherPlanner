// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../services/curriculum_service.dart';
import '../models/curriculum_models.dart';

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
  Map<String, dynamic> _tree = {};
  List<String> _years = [];
  List<String> _subjects = [];
  List<String> _strands = [];
  List<String> _subStrands = [];
  List<dynamic> _outcomes = [];

  String? _selectedYear;
  String? _selectedSubject;
  String? _selectedStrand;
  String? _selectedSubStrand;

  bool _loading = true;
  bool _showElaboration = false;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    final tree = await CurriculumService.getCurriculumTree();
    setState(() {
      _tree = tree;
      _years = tree.keys.toList()..sort();
      _selectedYear = _years.isNotEmpty ? _years.first : null;
      _loading = false;
    });
    _updateSubjectList();
  }

  void _updateSubjectList() {
    if (_selectedYear == null) return;
    final subjMap = Map<String, dynamic>.from(_tree[_selectedYear]!);
    setState(() {
      _subjects = subjMap.keys.toList()..sort();
      _selectedSubject = _subjects.isNotEmpty ? _subjects.first : null;
    });
    _updateStrandList();
  }

  void _updateStrandList() {
    if (_selectedYear == null || _selectedSubject == null) return;
    final subjMap = Map<String, dynamic>.from(_tree[_selectedYear]![_selectedSubject]!);
    setState(() {
      _strands = subjMap.keys.toList()..sort();
      _selectedStrand = _strands.isNotEmpty ? _strands.first : null;
    });
    _updateSubStrandList();
  }

  void _updateSubStrandList() {
    if (_selectedYear == null || _selectedSubject == null || _selectedStrand == null) return;
    final strandMap = Map<String, dynamic>.from(
      _tree[_selectedYear]![_selectedSubject]![_selectedStrand]!);
    setState(() {
      _subStrands = strandMap.keys.toList()..sort();
      _selectedSubStrand = _subStrands.isNotEmpty ? _subStrands.first : null;
    });
    _updateOutcomeList();
  }

  void _updateOutcomeList() {
    if (_selectedYear == null || _selectedSubject == null || _selectedStrand == null) return;
    final list = _tree[_selectedYear]![_selectedSubject]![_selectedStrand]!;
    if (_selectedSubStrand != null && list is Map<String, dynamic>) {
      _outcomes = list[_selectedSubStrand!] as List<dynamic>;
    } else if (list is List<dynamic>) {
      _outcomes = list;
    } else {
      _outcomes = [];
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: widget.width,
      color: theme.cardColor,
      child: _loading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Curriculum', style: theme.textTheme.titleMedium),
                  SizedBox(height: 12),
                  _buildDropdown(
                    label: 'Year',
                    items: _years,
                    value: _selectedYear,
                    onChanged: (v) => setState(() {
                      _selectedYear = v;
                      _updateSubjectList();
                    }),
                  ),
                  if (_subjects.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Subject',
                      items: _subjects,
                      value: _selectedSubject,
                      onChanged: (v) => setState(() {
                        _selectedSubject = v;
                        _updateStrandList();
                      }),
                    ),
                  ],
                  if (_strands.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Strand',
                      items: _strands,
                      value: _selectedStrand,
                      onChanged: (v) => setState(() {
                        _selectedStrand = v;
                        _updateSubStrandList();
                      }),
                    ),
                  ],
                  if (_subStrands.isNotEmpty) ...[
                    SizedBox(height: 12),
                    _buildDropdown(
                      label: 'Sub-strand',
                      items: _subStrands,
                      value: _selectedSubStrand,
                      onChanged: (v) => setState(() {
                        _selectedSubStrand = v;
                        _updateOutcomeList();
                      }),
                    ),
                  ],
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ChoiceChip(
                        label: Text('Description'),
                        selected: !_showElaboration,
                        onSelected: (_) => setState(() => _showElaboration = false),
                      ),
                      SizedBox(width: 8),
                      ChoiceChip(
                        label: Text('Elaboration'),
                        selected: _showElaboration,
                        onSelected: (_) => setState(() => _showElaboration = true),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _outcomes.length,
                      itemBuilder: (_, i) {
                        final data = _outcomes[i] as Map<String, dynamic>;
                        final id = data['code'] as String;
                        final desc = data[_showElaboration ? 'elaboration' : 'content_description'] as String? ?? '';
                        final selected = widget.selectedOutcomeIds.contains(id);
                        return CheckboxListTile(
                          title: Text(id),
                          subtitle: Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis),
                          value: selected,
                          onChanged: (v) {
                            final list = List<String>.from(widget.selectedOutcomeIds);
                            if (v == true) list.add(id); else list.remove(id);
                            widget.onOutcomesChanged(list);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      value: value,
      onChanged: onChanged,
    );
  }
}
