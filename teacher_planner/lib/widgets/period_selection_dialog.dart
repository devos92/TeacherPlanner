import 'package:flutter/material.dart';

class PeriodSelectionDialog extends StatefulWidget {
  final int? currentPeriods;

  const PeriodSelectionDialog({
    Key? key,
    this.currentPeriods,
  }) : super(key: key);

  @override
  _PeriodSelectionDialogState createState() => _PeriodSelectionDialogState();
}

class _PeriodSelectionDialogState extends State<PeriodSelectionDialog> {
  int _selectedPeriods = 5;

  @override
  void initState() {
    super.initState();
    _selectedPeriods = widget.currentPeriods ?? 5;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, color: theme.primaryColor),
          SizedBox(width: 8),
          Text('Weekly Planning Setup'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How many periods do you have each day?',
            style: theme.textTheme.bodyLarge,
          ),
          SizedBox(height: 16),
          Text(
            'This will determine how many planning blocks appear in your weekly plan.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [3, 4, 5, 6, 7, 8].map((periods) => ChoiceChip(
              label: Text('$periods periods'),
              selected: _selectedPeriods == periods,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedPeriods = periods;
                  });
                }
              },
              selectedColor: theme.primaryColor.withOpacity(0.2),
              checkmarkColor: theme.primaryColor,
            )).toList(),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, 
                  color: theme.primaryColor, 
                  size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can change this later in settings.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(_selectedPeriods),
          child: Text('Continue'),
        ),
      ],
    );
  }
} 