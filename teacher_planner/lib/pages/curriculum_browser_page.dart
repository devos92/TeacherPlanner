// lib/pages/curriculum_browser_page.dart

import 'package:flutter/material.dart';
import '../services/supabase_curriculum_service.dart';

class CurriculumBrowserPage extends StatefulWidget {
  @override
  _CurriculumBrowserPageState createState() => _CurriculumBrowserPageState();
}

class _CurriculumBrowserPageState extends State<CurriculumBrowserPage> {
  List<CurriculumData> _years = [];
  List<CurriculumData> _subjects = [];
  Map<String, List<CurriculumData>> _strands = {};
  Map<String, List<CurriculumData>> _outcomes = {};
  
  CurriculumData? _selectedYear;
  CurriculumData? _selectedSubject;
  CurriculumData? _selectedStrand;
  
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurriculumData();
  }

  Future<void> _loadCurriculumData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final structure = await SupabaseCurriculumService.getCurriculumStructure();
      
      setState(() {
        _years = (structure['years'] as List<dynamic>).cast<CurriculumData>();
        _subjects = (structure['subjects'] as List<dynamic>).cast<CurriculumData>();
        
        // Cast the strands map properly
        final strandsMap = structure['strands'] as Map<String, dynamic>;
        _strands = {};
        strandsMap.forEach((key, value) {
          _strands[key] = (value as List<dynamic>).cast<CurriculumData>();
        });
        
        // Cast the outcomes map properly
        final outcomesMap = structure['outcomes'] as Map<String, dynamic>;
        _outcomes = {};
        outcomesMap.forEach((key, value) {
          _outcomes[key] = (value as List<dynamic>).cast<CurriculumData>();
        });
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load curriculum data: $e';
        _isLoading = false;
      });
    }
  }

  void _selectYear(CurriculumData year) {
    setState(() {
      _selectedYear = year;
      _selectedSubject = null;
      _selectedStrand = null;
    });
  }

  void _selectSubject(CurriculumData subject) {
    setState(() {
      _selectedSubject = subject;
      _selectedStrand = null;
    });
  }

  void _selectStrand(CurriculumData strand) {
    setState(() {
      _selectedStrand = strand;
    });
  }

  List<CurriculumData> _getFilteredOutcomes() {
    if (_selectedYear == null) return [];
    
    var outcomes = _outcomes[_selectedYear!.id] ?? [];
    
    if (_selectedStrand != null) {
      outcomes = outcomes.where((outcome) => 
        outcome.strandId == _selectedStrand!.id
      ).toList();
    } else if (_selectedSubject != null) {
      final subjectStrands = _strands[_selectedSubject!.id] ?? [];
      final strandIds = subjectStrands.map((s) => s.id).toSet();
      outcomes = outcomes.where((outcome) => 
        strandIds.contains(outcome.strandId)
      ).toList();
    }
    
    return outcomes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Curriculum Browser'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCurriculumData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator())
        : _error != null
          ? _buildErrorWidget()
          : _buildCurriculumBrowser(),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 16),
          Text(
            'Error Loading Curriculum Data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCurriculumData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurriculumBrowser() {
    return Row(
      children: [
        // Left panel - Navigation
        Container(
          width: 300,
          decoration: BoxDecoration(
            border: Border(right: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              // Years section
              _buildSectionHeader('Year Levels'),
              Expanded(
                child: ListView.builder(
                  itemCount: _years.length,
                  itemBuilder: (context, index) {
                    final year = _years[index];
                    final isSelected = _selectedYear?.id == year.id;
                    return ListTile(
                      title: Text(year.name),
                      selected: isSelected,
                      onTap: () => _selectYear(year),
                      tileColor: isSelected ? Colors.blue.withOpacity(0.1) : null,
                    );
                  },
                ),
              ),
              
              Divider(),
              
              // Subjects section
              _buildSectionHeader('Subjects'),
              Expanded(
                child: ListView.builder(
                  itemCount: _subjects.length,
                  itemBuilder: (context, index) {
                    final subject = _subjects[index];
                    final isSelected = _selectedSubject?.id == subject.id;
                    return ListTile(
                      title: Text(subject.name),
                      subtitle: Text(subject.code ?? ''),
                      selected: isSelected,
                      onTap: () => _selectSubject(subject),
                      tileColor: isSelected ? Colors.green.withOpacity(0.1) : null,
                    );
                  },
                ),
              ),
              
              if (_selectedSubject != null) ...[
                Divider(),
                
                // Strands section
                _buildSectionHeader('Strands'),
                Expanded(
                  child: ListView.builder(
                    itemCount: (_strands[_selectedSubject!.id] ?? []).length,
                    itemBuilder: (context, index) {
                      final strand = _strands[_selectedSubject!.id]![index];
                      final isSelected = _selectedStrand?.id == strand.id;
                      return ListTile(
                        title: Text(strand.name),
                        subtitle: Text(strand.description ?? ''),
                        selected: isSelected,
                        onTap: () => _selectStrand(strand),
                        tileColor: isSelected ? Colors.orange.withOpacity(0.1) : null,
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Right panel - Outcomes
        Expanded(
          child: _buildOutcomesPanel(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      padding: EdgeInsets.all(12),
      color: Colors.grey[100],
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomesPanel() {
    final outcomes = _getFilteredOutcomes();
    
    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(16),
          color: Colors.grey[50],
          child: Row(
            children: [
              Icon(Icons.school, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                'Curriculum Outcomes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                '${outcomes.length} outcomes',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        
        // Filter info
        if (_selectedYear != null || _selectedSubject != null || _selectedStrand != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue.withOpacity(0.05),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 16, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Filtered by: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                if (_selectedYear != null)
                  Chip(
                    label: Text(_selectedYear!.name),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                if (_selectedSubject != null) ...[
                  SizedBox(width: 4),
                  Chip(
                    label: Text(_selectedSubject!.name),
                    backgroundColor: Colors.green.withOpacity(0.1),
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                ],
                if (_selectedStrand != null) ...[
                  SizedBox(width: 4),
                  Chip(
                    label: Text(_selectedStrand!.name),
                    backgroundColor: Colors.orange.withOpacity(0.1),
                    labelStyle: TextStyle(fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
        
        // Outcomes list
        Expanded(
          child: outcomes.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search, size: 64, color: Colors.grey[400]),
                    SizedBox(height: 16),
                    Text(
                      'No outcomes found',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Select a year level, subject, or strand to view outcomes',
                      style: TextStyle(
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: outcomes.length,
                itemBuilder: (context, index) {
                  final outcome = outcomes[index];
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: ExpansionTile(
                      title: Text(
                        outcome.code ?? 'No Code',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      subtitle: Text(
                        outcome.description ?? 'No description',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (outcome.description != null) ...[
                                Text(
                                  'Description:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(outcome.description!),
                                SizedBox(height: 12),
                              ],
                              if (outcome.elaboration != null) ...[
                                Text(
                                  'Elaboration:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  outcome.elaboration!,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }
} 