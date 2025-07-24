// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/curriculum_service.dart';

/// A sidebar that loads the entire curriculum hierarchy once and then
/// provides cascading dropdowns from the in-memory tree.
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
  bool _isLoading = true;
  String? _selectedYear;
  String? _selectedSubject;
  String? _selectedStrand;
  String? _selectedSubStrand;

  // Full nested tree: year -> subject -> strand -> subStrand -> list of outcomes
  Map<String, Map<String, Map<String, Map<String, List<CurriculumData>>>>> _tree = {};

  List<String> get _years => _tree.keys.toList();
  List<String> get _subjects => _selectedYear != null ? _tree[_selectedYear]!.keys.toList() : [];
  List<String> get _strands => (_selectedYear != null && _selectedSubject != null)
      ? _tree[_selectedYear]![_selectedSubject]!.keys.toList()
      : [];
  List<String> get _subStrands => (_selectedYear != null && _selectedSubject != null && _selectedStrand != null)
      ? _tree[_selectedYear]![_selectedSubject]![_selectedStrand]!.keys.toList()
      : [];
  List<CurriculumData> get _outcomes => (_selectedYear != null
      && _selectedSubject != null
      && _selectedStrand != null
      && _selectedSubStrand != null)
    ? _tree[_selectedYear]![_selectedSubject]![_selectedStrand]![_selectedSubStrand]!
    : [];

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    setState(() => _isLoading = true);
    try {
     final tree = await CurriculumService.getCurriculumTree();
      // pick first values if available
      if (_tree.isNotEmpty) {
        _selectedYear = _tree.keys.first;
        final subs = _subjects;
        if (subs.isNotEmpty) _selectedSubject = subs.first;
        final str = _strands;
        if (str.isNotEmpty) _selectedStrand = str.first;
        final sub = _subStrands;
        if (sub.isNotEmpty) _selectedSubStrand = sub.first;
      }
    } catch (e) {
      _tree = {};
    }
    setState(() => _isLoading = false);
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
          // Body
          Expanded(
            child: _isExpanded
              ? _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : _buildExpandedView(theme)
              : _buildCollapsedView(theme),
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
            label: Text('Add Outcomes'),
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
          // Year
          _buildDropdown(theme, 'Year Level', _years, _selectedYear, (v) {
            setState(() {
              _selectedYear = v;
              _selectedSubject = _selectedStrand = _selectedSubStrand = null;
            });
          }),

          if (_selectedYear != null) _buildDropdown(
            theme, 'Subject', _subjects, _selectedSubject, (v) {
              setState(() {
                _selectedSubject = v;
                _selectedStrand = _selectedSubStrand = null;
              });
            }),

          if (_selectedSubject != null) _buildDropdown(
            theme, 'Strand', _strands, _selectedStrand, (v) {
              setState(() {
                _selectedStrand = v;
                _selectedSubStrand = null;
              });
            }),

          if (_selectedStrand != null) _buildDropdown(
            theme, 'Sub-Strand', _subStrands, _selectedSubStrand, (v) {
              setState(() => _selectedSubStrand = v);
            }),

          Padding(
            padding: EdgeInsets.all(16),
            child: _buildOutcomeList(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    ThemeData theme,
    String label,
    List<String> items,
    String? value,
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildOutcomeList(ThemeData theme) {
    final list = _outcomes;
    return Column(
      children: list.map((o) {
        final selected = widget.selectedOutcomeIds.contains(o.id);
        return CheckboxListTile(
          title: Text(o.code ?? ''),
          subtitle: Text(o.description ?? ''),
          value: selected,
          onChanged: (v) {
            final newList = List<String>.from(widget.selectedOutcomeIds);
            if (v == true) newList.add(o.id); else newList.remove(o.id);
            widget.onOutcomesChanged(newList);
          },
        );
      }).toList(),
    );
  }
}
