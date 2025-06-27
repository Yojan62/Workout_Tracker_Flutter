import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'secondpage.dart';
import 'log_workout_dialog.dart'; // NEW: Import the new dialog file.

void main() {
  runApp(const WorkoutApp());
}

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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Map<String, dynamic>> _storedData = [];
  // NEW: A map to hold unsaved data from the dialog.
  // The key is the exercise name, the value is a list of sets.
  final Map<String, List<SetEntry>> _tempWorkoutData = {};

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? workoutsString = prefs.getString('workout_data');
    if (workoutsString != null) {
      final List<dynamic> decodedData = jsonDecode(workoutsString);
      setState(() {
        _storedData.clear();
        for (var item in decodedData) {
           final entry = item as Map<String, dynamic>;
           entry['timestamp'] = DateTime.parse(entry['timestamp'] as String);
           entry['sets'] = (entry['sets'] as List).map((s) => s as Map<String, dynamic>).toList();
           _storedData.add(entry);
        }
      });
    }
  }

  Future<void> _saveWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> encodableData = _storedData.map((item) {
      final encodableItem = Map<String, dynamic>.from(item);
      encodableItem['timestamp'] = (encodableItem['timestamp'] as DateTime).toIso8601String();
      return encodableItem;
    }).toList();
    final String workoutsString = jsonEncode(encodableData);
    await prefs.setString('workout_data', workoutsString);
  }

  // MODIFIED: This function is now much simpler.
  void _showInputDialogWithPreset(BuildContext context, String selectedExercise) {
    // Get any existing temp data, or default to one empty set if none exists.
    final tempSets = _tempWorkoutData[selectedExercise] ?? [SetEntry("", "")];
    // If the temp data was an empty list (e.g. user removed all sets), ensure there's at least one.
    if (tempSets.isEmpty) {
      tempSets.add(SetEntry("", ""));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogWorkoutDialog(
          exerciseName: selectedExercise,
          initialData: tempSets,
          onDispose: (currentData) {
            // This is called automatically from the dialog's dispose() method.
            // It saves the current text to our temporary map.
            setState(() {
              _tempWorkoutData[selectedExercise] = currentData;
            });
          },
          onSave: (savedSets) {
            // This is called when the user presses "Save" in the dialog.
            final sets = <Map<String, dynamic>>[];
            for (final setEntry in savedSets) {
              final weight = double.tryParse(setEntry.weight) ?? 0.0;
              final reps = int.tryParse(setEntry.reps) ?? 0;
              // Only add sets that have some data
              if(weight > 0 || reps > 0) {
                 sets.add({"weight": weight, "reps": reps});
              }
            }
            
            // Only save if there's at least one valid set
            if(sets.isNotEmpty) {
              setState(() {
                _storedData.add({
                  "exercise": selectedExercise,
                  "sets": sets,
                  "timestamp": DateTime.now(),
                });
                // NEW: Clear the temporary data now that it's been permanently saved.
                _tempWorkoutData.remove(selectedExercise);
                _saveWorkouts();
              });
            } else {
              // If user saves with no data, just clear the temp data
              setState(() {
                 _tempWorkoutData.remove(selectedExercise);
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      onLogWorkout: _showInputDialogWithPreset,
      onViewHistory: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SecondPage(storedData: _storedData),
          ),
        );
      },
    );
  }
}