import 'package:flutter/material.dart';

class AddExerciseDialog extends StatefulWidget {
  // Now accepts the full, nested map of exercise data.
  final Map<String, Map<String, List<Map<String, String>>>> exerciseData;
  // The onSave callback now provides the main group and sub-group.
  final Function(String name, String mainGroup, String subGroup) onSave;

  const AddExerciseDialog({
    super.key,
    required this.exerciseData,
    required this.onSave,
  });

  @override
  State<AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<AddExerciseDialog> {
  late final TextEditingController _nameController;
  // State variables to hold the selected dropdown values.
  late String _selectedMainGroup;
  late String _selectedSubGroup;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();

    // Set the initial default values for the dropdowns.
    _selectedMainGroup = widget.exerciseData.keys.first;
    _selectedSubGroup = widget.exerciseData[_selectedMainGroup]!.keys.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get the list of available sub-groups based on the selected main group.
    final subGroupOptions = widget.exerciseData[_selectedMainGroup]!.keys.toList();

    return AlertDialog(
      title: const Text("Add New Exercise"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Exercise Name"),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          // --- Dropdown 1: Main Group ---
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
                  // IMPORTANT: Reset the sub-group to the first in the new list.
                  _selectedSubGroup = widget.exerciseData[newValue]!.keys.first;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          // --- Dropdown 2: Sub-Group ---
          DropdownButtonFormField<String>(
            value: _selectedSubGroup,
            decoration: const InputDecoration(labelText: "Muscle Group"),
            // The items for this dropdown are dynamically generated.
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
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.isNotEmpty) {
              // Pass all three pieces of data back.
              widget.onSave(
                _nameController.text,
                _selectedMainGroup,
                _selectedSubGroup,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}