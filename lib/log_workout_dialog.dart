import 'package:flutter/material.dart';

// A data class to hold the text from the controllers.
class SetEntry {
  final String weight;
  final String reps;
  SetEntry(this.weight, this.reps);
}

class LogWorkoutDialog extends StatefulWidget {
  final String exerciseName;
  // The data that was previously typed but not saved.
  final List<SetEntry> initialData;
  // Callback function for when the user hits "Save".
  final Function(List<SetEntry>) onSave;
  // Callback function for when the dialog is closed without saving.
  final Function(List<SetEntry>) onDispose;

  const LogWorkoutDialog({
    super.key,
    required this.exerciseName,
    required this.initialData,
    required this.onSave,
    required this.onDispose,
  });

  @override
  State<LogWorkoutDialog> createState() => _LogWorkoutDialogState();
}

class _LogWorkoutDialogState extends State<LogWorkoutDialog> {
  late final List<TextEditingController> _weightControllers;
  late final List<TextEditingController> _repsControllers;
  // A flag to check if data was saved, to prevent saving temp data on dispose.
  bool _wasSaved = false;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the temporary data passed to the widget.
    _weightControllers = widget.initialData
        .map((set) => TextEditingController(text: set.weight))
        .toList();
    _repsControllers = widget.initialData
        .map((set) => TextEditingController(text: set.reps))
        .toList();
  }

  @override
  void dispose() {
    // If the dialog was closed without hitting "Save"...
    if (!_wasSaved) {
      //...capture the current text from the controllers.
      final currentData = <SetEntry>[];
      for (int i = 0; i < _weightControllers.length; i++) {
        currentData.add(
            SetEntry(_weightControllers[i].text, _repsControllers[i].text));
      }
      //...and send it back to be stored as temporary data.
      widget.onDispose(currentData);
    }

    // Clean up all controllers
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
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _weightControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightControllers[index],
                          decoration: InputDecoration(
                              labelText: "Set ${index + 1} - Weight (kg)"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _repsControllers[index],
                          decoration:
                              InputDecoration(labelText: "Set ${index + 1} - Reps"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
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
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () {
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() => _wasSaved = true); // Mark as saved
            final savedData = <SetEntry>[];
            for (int i = 0; i < _weightControllers.length; i++) {
              savedData.add(
                  SetEntry(_weightControllers[i].text, _repsControllers[i].text));
            }
            widget.onSave(savedData); // Trigger the save callback
            Navigator.of(context).pop();
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}