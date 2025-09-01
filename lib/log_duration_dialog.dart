import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A stateful dialog for logging a duration-based workout (e.g., plank, jump rope).
///
/// It provides a single input field for the user to enter the duration in minutes.
class LogDurationDialog extends StatefulWidget {
  final String exerciseName;
  /// A callback function that is triggered when the user hits "Save".
  /// It passes back the final duration value.
  final Function(double duration) onSave;
  /// Optional initial duration to pre-fill the field when editing an existing entry.
  final double? initialDuration;

  const LogDurationDialog({
    super.key,
    required this.exerciseName,
    required this.onSave,
    this.initialDuration,
  });

  @override
  State<LogDurationDialog> createState() => _LogDurationDialogState();
}

class _LogDurationDialogState extends State<LogDurationDialog> {
  // A controller to manage the text input for the duration field.
  final _durationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // If the dialog is being used to edit an entry, pre-fill the text field.
    if (widget.initialDuration != null) {
      _durationController.text = widget.initialDuration.toString();
    }
  }

  @override
  void dispose() {
    // It's crucial to dispose of the controller to prevent memory leaks.
    _durationController.dispose();
    super.dispose();
  }

  /// Gathers the data and triggers the onSave callback when the user saves.
  void _handleSave() {
    // Safely parse the text input into a double.
    final double duration = double.tryParse(_durationController.text) ?? 0;
    
    // Only save if the duration is a positive number.
    if (duration > 0) {
      // Pass the final duration back to the parent widget (MyHomePage).
      widget.onSave(duration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Log: ${widget.exerciseName}"),
      // The content is a single TextField for duration input.
      content: TextField(
        controller: _durationController,
        decoration: const InputDecoration(labelText: "Duration (minutes)"),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        // Input formatters restrict what the user can type.
        inputFormatters: [
          // Allows numbers and a single decimal point with up to 2 decimal places.
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        autofocus: true, // Automatically focus this field when the dialog opens.
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          // The parent (MyHomePage) is responsible for closing the dialog on save.
          onPressed: _handleSave,
          child: const Text("Save"),
        ),
      ],
    );
  }
}