// lib/widgets/save_indicator.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auto_save_service.dart';

/// Widget that shows save status and provides manual save functionality
class SaveIndicator extends StatefulWidget {
  final String saveKey;
  final Map<String, dynamic> data;
  final String userId;
  final String? tableName;
  final VoidCallback? onSaveSuccess;
  final VoidCallback? onSaveError;

  const SaveIndicator({
    Key? key,
    required this.saveKey,
    required this.data,
    required this.userId,
    this.tableName,
    this.onSaveSuccess,
    this.onSaveError,
  }) : super(key: key);

  @override
  State<SaveIndicator> createState() => _SaveIndicatorState();
}

class _SaveIndicatorState extends State<SaveIndicator> {
  bool _isSaving = false;
  bool _hasPendingChanges = false;
  String _lastSaveStatus = '';

  @override
  void initState() {
    super.initState();
    _checkPendingChanges();
  }

  void _checkPendingChanges() {
    final hasChanges = AutoSaveService.instance.hasPendingChanges(widget.saveKey);
    if (mounted) {
      setState(() {
        _hasPendingChanges = hasChanges;
      });
    }
  }

  Future<void> _manualSave() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await AutoSaveService.instance.manualSave(
        key: widget.saveKey,
        data: widget.data,
        userId: widget.userId,
        tableName: widget.tableName,
      );

      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasPendingChanges = false;
          _lastSaveStatus = success ? 'Saved' : 'Save failed';
        });

        if (success) {
          widget.onSaveSuccess?.call();
          _showSnackBar('✅ Changes saved successfully!', Colors.green);
        } else {
          widget.onSaveError?.call();
          _showSnackBar('❌ Failed to save changes', Colors.red);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _lastSaveStatus = 'Save error';
        });
        widget.onSaveError?.call();
        _showSnackBar('❌ Error saving changes: $e', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Auto-save indicator
        if (_hasPendingChanges)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Saving...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.orange[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        // Manual save button
        if (_hasPendingChanges || _isSaving)
          SizedBox(width: 8),

        // Manual save button
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _manualSave,
          icon: _isSaving
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(Icons.save, size: 16),
          label: Text(_isSaving ? 'Saving...' : 'Save Now'),
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasPendingChanges ? Colors.orange[600] : Colors.blue[600],
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        // Save status
        if (_lastSaveStatus.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(left: 8),
            child: Text(
              _lastSaveStatus,
              style: TextStyle(
                fontSize: 12,
                color: _lastSaveStatus == 'Saved' ? Colors.green[600] : Colors.red[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}

/// Auto-save enabled text field
class AutoSaveTextField extends StatefulWidget {
  final String saveKey;
  final String userId;
  final String? tableName;
  final String initialValue;
  final String label;
  final String? hint;
  final int? maxLines;
  final TextInputType? keyboardType;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;

  const AutoSaveTextField({
    Key? key,
    required this.saveKey,
    required this.userId,
    this.tableName,
    required this.initialValue,
    required this.label,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.onChanged,
    this.validator,
  }) : super(key: key);

  @override
  State<AutoSaveTextField> createState() => _AutoSaveTextFieldState();
}

class _AutoSaveTextFieldState extends State<AutoSaveTextField> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    // Cancel existing timer
    _debounceTimer?.cancel();

    // Create new timer for auto-save
    _debounceTimer = Timer(Duration(milliseconds: 500), () {
      AutoSaveService.instance.autoSave(
        key: widget.saveKey,
        data: {'content': value},
        userId: widget.userId,
        tableName: widget.tableName,
      );
    });

    widget.onChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            suffixIcon: SaveIndicator(
              saveKey: widget.saveKey,
              data: {'content': _controller.text},
              userId: widget.userId,
              tableName: widget.tableName,
            ),
          ),
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          onChanged: _onChanged,
          validator: widget.validator,
        ),
      ],
    );
  }
} 