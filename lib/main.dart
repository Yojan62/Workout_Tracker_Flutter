import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'secondpage.dart';
import 'log_workout_dialog.dart';

// The main entry point for the entire application.
void main() {
  runApp(const WorkoutApp());
}

// The root widget of the application.
// It sets up the MaterialApp, which defines the app's title, theme, and home screen.
class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Tracker',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// The main stateful widget that acts as the "brain" of the app.
// It manages the app's core data and state.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ===========================================================================
  // State Variables
  // ===========================================================================

  /// The master list of all saved workout entries. This is the "source of truth".
  List<Map<String, dynamic>> _storedData = [];

  /// A map to temporarily store data from a dialog if the user closes it
  /// without saving. This prevents them from losing their input.
  final Map<String, List<SetEntry>> _tempWorkoutData = {};

  // ===========================================================================
  // Lifecycle Methods
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    // Load any saved workouts from the device when the app starts.
    _loadWorkouts();
  }

  // ===========================================================================
  // Data Persistence
  // ===========================================================================

  /// Loads workout data from the phone's local storage.
  Future<void> _loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? workoutsString = prefs.getString('workout_data');

    if (workoutsString != null) {
      // If data exists, decode it from a JSON string into a Dart List.
      final List<dynamic> decodedData = jsonDecode(workoutsString);
      setState(() {
        _storedData = decodedData.map((item) {
          final entry = item as Map<String, dynamic>;
          // Convert the stored timestamp string back into a DateTime object.
          entry['timestamp'] = DateTime.parse(entry['timestamp'] as String);
          entry['sets'] = (entry['sets'] as List)
              .map((s) => s as Map<String, dynamic>)
              .toList();
          return entry;
        }).toList();
      });
    } else {
      // If no data is found (e.g., first time running the app), load test data.
      setState(() {
        _storedData = _generateTestData();
      });
    }
  }

  /// Saves the current workout data to the phone's local storage.
  Future<void> _saveWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    // Create a copy of the data that can be safely encoded into JSON.
    final List<Map<String, dynamic>> encodableData = _storedData.map((item) {
      final encodableItem = Map<String, dynamic>.from(item);
      // Convert DateTime objects into a string format for JSON compatibility.
      encodableItem['timestamp'] =
          (encodableItem['timestamp'] as DateTime).toIso8601String();
      return encodableItem;
    }).toList();

    // Encode the list into a JSON string and save it.
    final String workoutsString = jsonEncode(encodableData);
    await prefs.setString('workout_data', workoutsString);
  }

  // ===========================================================================
  // Dialog and Action Handlers
  // ===========================================================================

  /// Shows the dialog for logging a NEW workout.
  void _showInputDialogWithPreset(
      BuildContext context, String selectedExercise) {
    // Find the 3 most recent entries for this exercise to show as history.
    final recentEntries = _storedData
        .where((entry) => entry['exercise'] == selectedExercise)
        .take(3)
        .toList();

    // Get any temporary (unsaved) data for this exercise.
    final tempSets = _tempWorkoutData[selectedExercise] ?? [SetEntry("", "")];
    if (tempSets.isEmpty) {
      tempSets.add(SetEntry("", ""));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogWorkoutDialog(
          exerciseName: selectedExercise,
          initialData: tempSets,
          recentHistory: recentEntries,
          onDispose: (currentData) {
            // If the dialog is closed without saving, store the input temporarily.
            setState(() {
              _tempWorkoutData[selectedExercise] = currentData;
            });
          },
          onSave: (savedSets) {
            // When the user saves, process the sets and add a new entry.
            final sets = <Map<String, dynamic>>[];
            for (final setEntry in savedSets) {
              final weight = double.tryParse(setEntry.weight) ?? 0.0;
              final reps = int.tryParse(setEntry.reps) ?? 0;
              if (weight > 0 || reps > 0) {
                sets.add({"weight": weight, "reps": reps});
              }
            }

            if (sets.isNotEmpty) {
              setState(() {
                // Create a new list to ensure the state change is detected by other widgets.
                final newList = List<Map<String, dynamic>>.from(_storedData);
                newList.add({
                  "exercise": selectedExercise,
                  "sets": sets,
                  "timestamp": DateTime.now(),
                });
                _storedData = newList;
                _tempWorkoutData.remove(selectedExercise);
                _saveWorkouts();
              });
            } else {
              // If the user saved with no data, just clear the temp data.
              setState(() {
                _tempWorkoutData.remove(selectedExercise);
              });
            }
            // Close the dialog after saving.
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /// Shows the dialog for EDITING a saved workout.
  /// Returns the updated entry so the history page UI can refresh instantly.
  Future<Map<String, dynamic>?> _showEditDialog(Map<String, dynamic> entryToEdit) async {
    final int indexToEdit = _storedData.indexOf(entryToEdit);
    if (indexToEdit == -1) return null;

    final String exerciseName = entryToEdit['exercise'] as String;
    // Convert the stored data back into a format the dialog can use.
    final List<SetEntry> initialSets = (entryToEdit['sets'] as List)
        .map((s) => SetEntry(s['weight'].toString(), s['reps'].toString()))
        .toList();

    final Map<String, dynamic>? updatedEntry = await showDialog(
      context: context,
      builder: (context) {
        return LogWorkoutDialog(
          exerciseName: exerciseName,
          initialData: initialSets,
          recentHistory: null,
          onDispose: (data) {}, // No need to save temp data on edit.
          onSave: (savedSets) {
            final sets = <Map<String, dynamic>>[];
            for (final setEntry in savedSets) {
              final weight = double.tryParse(setEntry.weight) ?? 0.0;
              final reps = int.tryParse(setEntry.reps) ?? 0;
              if (weight > 0 || reps > 0) {
                sets.add({"weight": weight, "reps": reps});
              }
            }

            if (sets.isNotEmpty) {
              final newEntry = {
                "exercise": exerciseName,
                "sets": sets,
                "timestamp": entryToEdit['timestamp'], // Keep original timestamp
              };

              setState(() {
                // Replace the item at its index in a new list.
                final newList = List<Map<String, dynamic>>.from(_storedData);
                newList[indexToEdit] = newEntry;
                _storedData = newList;
                _saveWorkouts();
              });

              // Return the updated data and close the dialog.
              Navigator.of(context).pop(newEntry);
            } else {
              Navigator.of(context).pop(null);
            }
          },
        );
      },
    );
    return updatedEntry;
  }

  /// Shows a confirmation dialog for DELETING a workout.
  /// Returns true/false so the history page knows whether to update its UI.
  Future<bool> _confirmDelete(Map<String, dynamic> entryToDelete) async {
    final bool? wasConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this workout entry?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false); // Return false
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  // Create a new list without the deleted item.
                  _storedData = List.from(_storedData)..remove(entryToDelete);
                  _saveWorkouts();
                });
                Navigator.of(context).pop(true); // Return true
              },
            ),
          ],
        );
      },
    );
    return wasConfirmed ?? false;
  }

  // ===========================================================================
  // Build Method
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // The main UI is delegated to the HomeScreen widget.
    // This keeps the state management logic separate from the UI code.
    return HomeScreen(
      onLogWorkout: _showInputDialogWithPreset,
      onViewHistory: () {
        // Navigate to the history page, passing the current data and action handlers.
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SecondPage(
              storedData: _storedData,
              onEdit: _showEditDialog,
              onDelete: _confirmDelete,
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Test Data Generator
  // ===========================================================================

  /// A helper function for development to provide initial data.
  List<Map<String, dynamic>> _generateTestData() {
    final now = DateTime.now();
    return [
      {
        "exercise": "Bench Press",
        "timestamp": now.subtract(const Duration(days: 14)),
        "sets": [
          {"weight": 70.0, "reps": 8},
          {"weight": 70.0, "reps": 8},
        ],
      },
      {
        "exercise": "Bench Press",
        "timestamp": now.subtract(const Duration(days: 7)),
        "sets": [
          {"weight": 75.0, "reps": 6},
          {"weight": 75.0, "reps": 6},
          {"weight": 75.0, "reps": 5},
        ],
      },
      {
        "exercise": "Squat",
        "timestamp": now.subtract(const Duration(days: 5)),
        "sets": [
          {"weight": 100.0, "reps": 5},
          {"weight": 100.0, "reps": 5},
        ],
      },
      {
        "exercise": "Bench Press",
        "timestamp": now.subtract(const Duration(days: 1)),
        "sets": [
          {"weight": 80.0, "reps": 5},
          {"weight": 80.0, "reps": 4},
          {"weight": 80.0, "reps": 4},
        ],
      },
      {
        "exercise": "Pull-ups",
        "timestamp": now,
        "sets": [
          {"weight": 0.0, "reps": 10},
          {"weight": 0.0, "reps": 8},
        ],
      },
    ];
  }
}