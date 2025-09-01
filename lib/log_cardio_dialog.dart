import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A stateful dialog for logging a cardio workout (e.g., running, cycling).
///
/// It provides input fields for duration and speed, and automatically calculates
/// the distance for the user.
class LogCardioDialog extends StatefulWidget {
  final String exerciseName;
  /// A callback function that is triggered when the user hits "Save".
  /// It passes back a map containing the final cardio data.
  final Function(Map<String, dynamic> cardioData) onSave;
  /// Optional initial data to pre-fill the fields when editing an existing entry.
  final Map<String, dynamic>? initialData;

  const LogCardioDialog({
    super.key,
    required this.exerciseName,
    required this.onSave,
    this.initialData,
  });

  @override
  State<LogCardioDialog> createState() => _LogCardioDialogState();
}

class _LogCardioDialogState extends State<LogCardioDialog> {
  // Controllers to manage the text input for each field.
  final _durationController = TextEditingController();
  final _speedController = TextEditingController();

  // A state variable to hold the calculated distance.
  double _distance = 0.0;

  @override
  void initState() {
    super.initState();
    
    // If the dialog is being used to edit an entry, pre-fill the fields.
    if (widget.initialData != null) {
      _durationController.text = widget.initialData!['duration']?.toString() ?? '';
      _speedController.text = widget.initialData!['speed']?.toString() ?? '';
    }

    // Add listeners to both controllers. This will trigger the _calculateDistance
    // method every time the user types in either field.
    _durationController.addListener(_calculateDistance);
    _speedController.addListener(_calculateDistance);
  }

  @override
  void dispose() {
    // It's crucial to dispose of controllers to prevent memory leaks.
    _durationController.dispose();
    _speedController.dispose();
    super.dispose();
  }

  /// Calculates the distance in real-time based on user input.
  void _calculateDistance() {
    final double duration = double.tryParse(_durationController.text) ?? 0;
    final double speed = double.tryParse(_speedController.text) ?? 0;

    // The setState call tells Flutter to rebuild the widget so the user
    // can see the updated distance value.
    setState(() {
      // Formula: Distance = Speed * (Duration in hours)
      _distance = speed * (duration / 60);
    });
  }

  /// Gathers the data and triggers the onSave callback when the user saves.
  void _handleSave() {
    final double duration = double.tryParse(_durationController.text) ?? 0;
    final double speed = double.tryParse(_speedController.text) ?? 0;
    
    // Only save if there is valid data.
    if (duration > 0 && speed > 0) {
      final cardioData = {
        'duration': duration,
        'speed': speed,
        'distance': _distance,
      };
      // Pass the final data back to the parent widget (MyHomePage).
      widget.onSave(cardioData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Log: ${widget.exerciseName}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duration TextField
          TextField(
            controller: _durationController,
            decoration: const InputDecoration(labelText: "Duration (minutes)"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 16),
          // Speed TextField
          TextField(
            controller: _speedController,
            decoration: const InputDecoration(labelText: "Speed (km/h)"),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
          ),
          const SizedBox(height: 24),
          // Display for the automatically calculated distance.
          Text(
            "Distance: ${_distance.toStringAsFixed(2)} km",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
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