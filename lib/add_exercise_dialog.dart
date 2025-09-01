import 'package:flutter/material.dart';

/// A stateful dialog for adding a new exercise to the user's custom list.
///
/// This widget provides a form with a text field for the exercise name and
/// two dropdown menus for selecting the main group and muscle sub-group.
class AddExerciseDialog extends StatefulWidget {
  /// The complete, nested map of all available exercises, used to populate the dropdowns.
  final Map<String, Map<String, List<Map<String, String>>>> exerciseData;
  /// A callback function that is triggered when the user hits "Save".
  /// It passes back the new name, the selected main group, and sub-group.
  final Function(String name, String mainGroup, String subGroup) onSave;

  const AddExerciseDialog({
    super.key,
    required this.exerciseData,
    required this.onSave,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

/// The state class for the [AddExerciseDialog].
class _AddExerciseDialogState extends State<AddExerciseDialog> {
  // A controller to manage the text input for the exercise name.
  late final TextEditingController _nameController;
  // State variables to hold the currently selected values of the dropdowns.
  late String _selectedMainGroup;
  late String _selectedSubGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Set the initial default values for the dropdowns to the first available options.
    _selectedMainGroup = widget.exerciseData.keys.first;
    _selectedSubGroup = widget.exerciseData[_selectedMainGroup]!.keys.first;
  }

  @override
  void dispose() {
    // It's crucial to dispose of the TextEditingController to prevent memory leaks.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the list of available sub-groups based on the currently selected main group.
    // This makes the second dropdown "dependent" on the first one.
    final subGroupOptions = widget.exerciseData[_selectedMainGroup]!.keys.toList();

    return AlertDialog(
      title: const Text("Add New Exercise"),
      content: Column(
        mainAxisSize: MainAxisSize.min, // The dialog should only be as tall as its content.
        children: [
          // Text field for the exercise name.
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Exercise Name"),
            autofocus: true, // Automatically focus this field when the dialog opens.
          ),
          const SizedBox(height: 16),

          // Dropdown 1: Main Group (e.g., "UPPER BODY")
          DropdownButtonFormField<String>(
            value: _selectedMainGroup,
            decoration: const InputDecoration(labelText: "Main Group"),
            items: widget.exerciseData.keys.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedMainGroup = newValue;
                  // IMPORTANT: When the main group changes, we must reset the
                  // sub-group selection to the first available option in the new list.
                  _selectedSubGroup = widget.exerciseData[newValue]!.keys.first;
                });
              }
            },
          ),
          const SizedBox(height: 16),

          // Dropdown 2: Muscle Sub-Group (e.g., "Chest")
          DropdownButtonFormField<String>(
            value: _selectedSubGroup,
            decoration: const InputDecoration(labelText: "Muscle Group"),
            // The items for this dropdown are dynamically generated from subGroupOptions.
            items: subGroupOptions.map((String group) {
              return DropdownMenuItem<String>(
                value: group,
                child: Text(group),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedSubGroup = newValue;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        // The "Cancel" button, which simply closes the dialog.
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        // The "Save" button.
        ElevatedButton(
          onPressed: () {
            // Only save if the name field is not empty.
            if (_nameController.text.trim().isNotEmpty) {
              // Trigger the onSave callback, passing all three pieces of data back to MyHomePage.
              widget.onSave(
                _nameController.text.trim(),
                _selectedMainGroup,
                _selectedSubGroup,
              );
              Navigator.of(context).pop(); // Close the dialog.
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}