import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter/services.dart';

/// A simple data class to hold the weight and reps strings from the TextFields.
class SetEntry {
  final String weight;
  final String reps;
  SetEntry(this.weight, this.reps);
}

/// A stateful dialog widget for logging or editing workout sets for a given exercise.
class LogWorkoutDialog extends StatefulWidget {
  final String exerciseName;
  /// The initial data to populate the text fields with. This can be from a
  /// previously saved workout (for editing) or temporary unsaved data.
  final List<SetEntry> initialData;
  /// A callback function that is triggered when the user hits the "Save" button.
  final Function(List<SetEntry>) onSave;
  /// A callback function that is triggered when the dialog is closed without saving.
  /// Used to preserve the user's input.
  final Function(List<SetEntry>) onDispose;
  /// An optional list of recent workouts to display for user reference.
  final List<Map<String, dynamic>>? recentHistory;

  const LogWorkoutDialog({
    super.key,
    required this.exerciseName,
    required this.initialData,
    required this.onSave,
    required this.onDispose,
    required this.recentHistory,
  });

  @override
  State<LogWorkoutDialog> createState() => _LogWorkoutDialogState();
}

class _LogWorkoutDialogState extends State<LogWorkoutDialog> {
  // A list of controllers to manage the text for each weight input field.
  late final List<TextEditingController> _weightControllers;
  // A list of controllers to manage the text for each reps input field.
  late final List<TextEditingController> _repsControllers;
  // A flag to check if the "Save" button was pressed. This prevents us from
  // overwriting a successful save with temporary data when the dialog is disposed.
  bool _wasSaved = false;

  @override
  void initState() {
    super.initState();
    // When the dialog is created, initialize the lists of controllers
    // with the data passed into the widget.
    _weightControllers = widget.initialData
        .map((set) => TextEditingController(text: set.weight))
        .toList();
    _repsControllers = widget.initialData
        .map((set) => TextEditingController(text: set.reps))
        .toList();
  }

  /// This is a critical lifecycle method that runs when the widget is permanently
  /// removed from the screen (e.g., when the dialog is closed).
  @override
  void dispose() {
    // If the dialog was closed without the user pressing "Save"...
    if (!_wasSaved) {
      // ...then we capture the current text from all input fields...
      final currentData = <SetEntry>[];
      for (int i = 0; i < _weightControllers.length; i++) {
        currentData.add(
            SetEntry(_weightControllers[i].text, _repsControllers[i].text));
      }
      // ...and send it back using the onDispose callback to be stored temporarily.
      widget.onDispose(currentData);
    }

    // It's crucial to dispose of every single TextEditingController to prevent
    // memory leaks in the application.
    for (var controller in _weightControllers) {
      controller.dispose();
    }
    for (var controller in _repsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("Log: ${widget.exerciseName}"),
      // Using a SizedBox with a SingleChildScrollView allows the dialog content
      // to scroll if the user adds many sets.
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // The column should only be as tall as its children.
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -- Section 1: Recent History Display (Optional) --
              if (widget.recentHistory != null && widget.recentHistory!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Recent History:",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // Map over the recent history data to create a display row for each entry.
                      ...widget.recentHistory!.map((entry) {
                        final date = entry['timestamp'] as DateTime;
                        final sets = entry['sets'] as List;
                        final setsString = sets
                            .map((s) => "${s['weight']}kg x ${s['reps']}")
                            .join('  |  ');

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                DateFormat('MMM d').format(date),
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  setsString,
                                  style: const TextStyle(fontWeight: FontWeight.w500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      const Divider(height: 20),
                    ],
                  ),
                ),
              
              // -- Section 2: Dynamic Set Input Fields --
              ListView.builder(
                shrinkWrap: true, // Necessary inside a SingleChildScrollView.
                physics: const NeverScrollableScrollPhysics(), // The outer view handles scrolling.
                itemCount: _weightControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      // Weight TextField
                      Expanded(
                        child: TextField(
                          controller: _weightControllers[index],
                          decoration: InputDecoration(
                              labelText: "Set ${index + 1} - Weight (kg)"),
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          // Input formatters restrict what the user can type.
                          inputFormatters: [
                            // Allows numbers and a single decimal point with up to 2 decimal places.
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                            // Limits the total length of the input.
                            LengthLimitingTextInputFormatter(6),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Reps TextField
                      Expanded(
                        child: TextField(
                          controller: _repsControllers[index],
                          decoration:
                              InputDecoration(labelText: "Set ${index + 1} - Reps"),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            // Allows only whole numbers.
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3), // Max 999 reps
                          ],
                        ),
                      ),
                      // Remove Set Button
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          // When removing a set, we must also dispose of its controllers.
                          setState(() {
                            _weightControllers.removeAt(index).dispose();
                            _repsControllers.removeAt(index).dispose();
                          });
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 8),

              // -- Section 3: Add Set Button --
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
                    // Adds new, empty controllers to the lists, which causes the
                    // ListView.builder to create a new input row.
                    setState(() {
                      _weightControllers.add(TextEditingController());
                      _repsControllers.add(TextEditingController());
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Add Set"),
                ),
              ),
            ],
          ),
        ),
      ),
      // -- Section 4: Dialog Action Buttons --
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            // Set the flag to true so we don't save temp data on dispose.
            setState(() => _wasSaved = true);
            // Package up the current data from the controllers.
            final savedData = <SetEntry>[];
            for (int i = 0; i < _weightControllers.length; i++) {
              savedData.add(
                  SetEntry(_weightControllers[i].text, _repsControllers[i].text));
            }
            // Trigger the onSave callback, passing the data back to the parent widget.
            // The parent widget is now responsible for closing the dialog.
            widget.onSave(savedData);
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}