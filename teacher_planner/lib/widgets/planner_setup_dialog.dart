// lib/widgets/planner_setup_dialog.dart

import 'package:flutter/material.dart';
import '../services/planner_service.dart';
import '../services/auth_service.dart';

class PlannerSetupDialog extends StatefulWidget {
  final bool isNewUser;

  const PlannerSetupDialog({
    Key? key,
    this.isNewUser = false,
  }) : super(key: key);

  @override
  _PlannerSetupDialogState createState() => _PlannerSetupDialogState();
}

class _PlannerSetupDialogState extends State<PlannerSetupDialog> {
  final _formKey = GlobalKey<FormState>();
  final _schoolController = TextEditingController();
  final _roleController = TextEditingController();
  
  int _selectedPeriods = 5;
  bool _isLoading = false;

  @override
  void dispose() {
    _schoolController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isNewUser ? 'Welcome to Teacher Planner!' : 'Planner Setup',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Roboto',
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isNewUser) ...[
                Text(
                  'Let\'s set up your planner with some basic information.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 16),
              ],
              
              // School Name
              TextFormField(
                controller: _schoolController,
                decoration: InputDecoration(
                  labelText: 'School Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.school),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your school name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Teacher Role
              TextFormField(
                controller: _roleController,
                decoration: InputDecoration(
                  labelText: 'Teacher Role/Subject',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                  hintText: 'e.g., Math Teacher, Primary Teacher',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your role';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Number of Periods
              Text(
                'Number of Periods per Day:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedPeriods,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.schedule),
                ),
                items: [4, 5, 6, 7, 8].map((periods) {
                  return DropdownMenuItem(
                    value: periods,
                    child: Text('$periods periods'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPeriods = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              
              // Additional Settings
              ExpansionTile(
                title: Text(
                  'Additional Settings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text('Enable Notifications'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Handle notification setting
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.backup),
                    title: Text('Auto-save'),
                    trailing: Switch(
                      value: true,
                      onChanged: (value) {
                        // Handle auto-save setting
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPlanner,
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('Create Planner'),
        ),
      ],
    );
  }

  Future<void> _createPlanner() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await AuthService.instance.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final success = await PlannerService.instance.createNewPlanner(
        userId: currentUser.id,
        periods: _selectedPeriods,
        schoolName: _schoolController.text.trim(),
        teacherRole: _roleController.text.trim(),
        additionalSettings: {
          'notifications_enabled': true,
          'auto_save_enabled': true,
        },
      );

      if (success) {
        Navigator.of(context).pop(true); // Return success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Planner created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Failed to create planner');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error creating planner: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
} 