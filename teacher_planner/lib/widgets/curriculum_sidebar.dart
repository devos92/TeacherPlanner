// lib/widgets/curriculum_sidebar.dart

import 'package:flutter/material.dart';
import '../models/curriculum_models.dart';
import '../services/curriculum_service.dart';

/// A sidebar that lets users drill down through Year → Subject → Strand → Sub-strand,
/// then pick content or elaboration text to add as outcomes.
class CurriculumSidebar extends StatefulWidget {
  final List<String> selectedOutcomeCodes;
  final ValueChanged<List<String>> onSelectionChanged;
  final double width;

  const CurriculumSidebar({
    Key? key,
    required this.selectedOutcomeCodes,
    required this.onSelectionChanged,
    this.width = 300,
  }) : super(key: key);

  @override
  _CurriculumSidebarState createState() => _CurriculumSidebarState();
}

class _CurriculumSidebarState extends State<CurriculumSidebar> {
  bool _expanded = false;
  bool _loading = true;
  Map<String, dynamic> _tree = {};

  String? _year;
  String? _subject;
  String? _strand;
  String? _subStrand;
  List<Map<String, dynamic>> _outcomes = [];

  bool _showElaboration = false;

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  Future<void> _loadTree() async {
    setState(() => _loading = true);
    final tree = await CurriculumService.getCurriculumTree();
    setState(() {
      _tree = tree;
      if (_tree.isNotEmpty) {
        _year = _tree.keys.first;
        _subject = (_tree[_year] as Map<String, dynamic>).keys.first;
        _strand = (_tree[_year]![_subject] as Map<String, dynamic>).keys.first;
        _subStrand = (_tree[_year]![_subject]![_strand] as Map<String, dynamic>).keys.first;
        _outcomes = List<Map<String, dynamic>>.from(
          _tree[_year]![_subject]![_strand]![_subStrand],
        );
      }
      _loading = false;
    });
  }

  void _updateOutcomes() {
    if (_year != null && _subject != null && _strand != null && _subStrand != null) {
      setState(() {
        _outcomes = List<Map<String, dynamic>>.from(
          _tree[_year]![_subject]![_strand]![_subStrand],
        );
      });
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
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _expanded
                    ? _buildFilterView(theme)
                    : _buildSummaryView(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterView(ThemeData theme) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Year dropdown
          Text('Year', style: theme.textTheme.bodyLarge),
          DropdownButton<String>(
            isExpanded: true,
            value: _year,
            items: _tree.keys.map((y) => DropdownMenuItem(
              value: y,
              child: Text(y),
            )).toList(),
            onChanged: (v) {
              _year = v;
              // reset deeper levels
              _subject = (_tree[_year] as Map<String, dynamic>).keys.first;
              _strand = (_tree[_year]![_subject] as Map<String, dynamic>).keys.first;
              _subStrand = (_tree[_year]![_subject]![_strand] as Map<String, dynamic>).keys.first;
              _updateOutcomes();
              setState(() {});
            },
          ),
          SizedBox(height: 12),

          // Subject dropdown
          Text('Subject', style: theme.textTheme.bodyLarge),
          DropdownButton<String>(
            isExpanded: true,
            value: _subject,
            items: (_tree[_year] as Map<String, dynamic>).keys.map((s) => DropdownMenuItem(
              value: s,
              child: Text(s),
            )).toList(),
            onChanged: (v) {
              _subject = v;
              _strand = (_tree[_year]![_subject] as Map<String, dynamic>).keys.first;
              _subStrand = (_tree[_year]![_subject]![_strand] as Map<String, dynamic>).keys.first;
              _updateOutcomes();
              setState(() {});
            },
          ),
          SizedBox(height: 12),

          // Strand dropdown
          Text('Strand', style: theme.textTheme.bodyLarge),
          DropdownButton<String>(
            isExpanded: true,
            value: _strand,
            items: (_tree[_year]![_subject] as Map<String, dynamic>).keys.map((st) => DropdownMenuItem(
              value: st,
              child: Text(st),
            )).toList(),
            onChanged: (v) {
              _strand = v;
              _subStrand = (_tree[_year]![_subject]![_strand] as Map<String, dynamic>).keys.first;
              _updateOutcomes();
              setState(() {});
            },
          ),
          SizedBox(height: 12),

          // Sub-Strand dropdown
          Text('Sub-Strand', style: theme.textTheme.bodyLarge),
          DropdownButton<String>(
            isExpanded: true,
            value: _subStrand,
            items: (_tree[_year]![_subject]![_strand] as Map<String, dynamic>).keys.map((ss) => DropdownMenuItem(
              value: ss,
              child: Text(ss.isEmpty ? '[none]' : ss),
            )).toList(),
            onChanged: (v) {
              _subStrand = v;
              _updateOutcomes();
              setState(() {});
            },
          ),

          Divider(height: 32),

          // Toggle Description vs Elaboration
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

          Divider(height: 32),

          // Outcomes checkbox list
          ..._outcomes.map((o) {
            final code = o['code'] as String;
            final text = _showElaboration
                ? (o['elaboration'] as String? ?? '')
                : (o['content_description'] as String? ?? '');
            final selected = widget.selectedOutcomeCodes.contains(code);
            return CheckboxListTile(
              title: Text(code, style: theme.textTheme.bodySmall),
              subtitle: Text(text, maxLines: 2, overflow: TextOverflow.ellipsis),
              value: selected,
              onChanged: (v) {
                final list = List<String>.from(widget.selectedOutcomeCodes);
                if (v == true) list.add(code);
                else list.remove(code);
                widget.onSelectionChanged(list);
              },
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSummaryView(ThemeData theme) {
    // show selected outcome codes
    if (widget.selectedOutcomeCodes.isEmpty) {
      return Center(child: Text('No outcomes selected'));
    }
    return ListView(
      padding: EdgeInsets.all(16),
      children: widget.selectedOutcomeCodes.map((c) => ListTile(
        title: Text(c),
        trailing: IconButton(
          icon: Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () {
            final list = List<String>.from(widget.selectedOutcomeCodes)..remove(c);
            widget.onSelectionChanged(list);
          },
        ),
      )).toList(),
    );
  }
}
