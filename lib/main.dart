import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'auth_gate.dart';
import 'home_screen.dart';
import 'WorkoutHistoryPage.dart';
import 'log_workout_dialog.dart';
import 'add_exercise_dialog.dart';
import 'workout_data.dart';

/// The main entry point for the entire application.
Future<void> main() async {
  // This ensures that all Flutter bindings are initialized before any Flutter code runs.
  WidgetsFlutterBinding.ensureInitialized();
  // This initializes the Firebase app using the keys from your firebase_options.dart file.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const WorkoutApp());
}

/// The root widget of the application.
/// It sets up the MaterialApp, which defines the app's title, theme, and home screen.
class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lift Log',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      // The AuthGate handles showing either the LoginScreen or MyHomePage.
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// The main stateful widget that acts as the "brain" of the app.
/// It manages the app's core data and state after a user has logged in.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ===========================================================================
  // State Variables
  // ===========================================================================

  /// The master list of all saved workout entries for the current user.
  List<Map<String, dynamic>> _storedData = [];
  /// The nested map of all available exercises for the current user.
  Map<String, Map<String, List<Map<String, String>>>> _exerciseData = {};
  /// A map to temporarily store data from a dialog if the user closes it without saving.
  final Map<String, List<SetEntry>> _tempWorkoutData = {};

  // ===========================================================================
  // Lifecycle Methods
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    // Load the user's data from Firestore when the app starts.
    _loadExercises();
    _loadWorkouts();
  }

  // ===========================================================================
  // Data Persistence (Cloud Firestore)
  // ===========================================================================

  /// Loads the user's workout logs from Firestore.
  Future<void> _loadWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    
    if (doc.exists && doc.data()!.containsKey('workouts')) {
      final List<dynamic> workoutData = doc.data()!['workouts'];
      setState(() {
        _storedData = workoutData.map((item) {
          final entry = item as Map<String, dynamic>;
          entry['timestamp'] = (entry['timestamp'] as Timestamp).toDate();
          entry['sets'] = (entry['sets'] as List)
              .map((s) => s as Map<String, dynamic>)
              .toList();
          return entry;
        }).toList();
      });
    } else {
      // If no data exists, load the mock data as a starting point.
      setState(() {
      });
    }
  }

  /// Saves the user's workout logs to Firestore.
  Future<void> _saveWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'workouts': _storedData,
    }, SetOptions(merge: true));
  }

  /// Loads the user's custom exercise list from Firestore.
  Future<void> _loadExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    setState(() {
      if (doc.exists && doc.data()!.containsKey('exercises')) {
        final Map<String, dynamic> decodedData = doc.data()!['exercises'];
        _exerciseData = decodedData.map((mainGroup, subGroups) {
          final subGroupMap = (subGroups as Map<String, dynamic>).map((subGroup, exercises) {
            final exerciseList = (exercises as List)
                .map((e) => Map<String, String>.from(e))
                .toList();
            return MapEntry(subGroup, exerciseList);
          });
          return MapEntry(mainGroup, subGroupMap);
        });
      } else {
        // If no saved list exists, load the default and save it.
        _exerciseData = workoutData;
        _saveExercises();
      }
    });
  }

  /// Saves the user's custom exercise list to Firestore.
  Future<void> _saveExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'exercises': _exerciseData,
    }, SetOptions(merge: true));
  }

  // ===========================================================================
  // Dialog and Action Handlers
  // ===========================================================================

  /// Signs the current user out.
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }
  
  /// Shows the dialog for logging a NEW workout.
  void _showInputDialogWithPreset(
      BuildContext context, String selectedExercise) {
    final recentEntries = _storedData
        .where((entry) => entry['exercise'] == selectedExercise)
        .take(3)
        .toList();

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
            setState(() {
              _tempWorkoutData[selectedExercise] = currentData;
            });
          },
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
              setState(() {
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
              setState(() {
                _tempWorkoutData.remove(selectedExercise);
              });
            }
            Navigator.of(context).pop();
          },
        );
      },
    );
  }

  /// Shows the dialog for EDITING a saved workout.
  Future<Map<String, dynamic>?> _showEditDialog(Map<String, dynamic> entryToEdit) async {
    final int indexToEdit = _storedData.indexOf(entryToEdit);
    if (indexToEdit == -1) return null;

    final String exerciseName = entryToEdit['exercise'] as String;
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
          onDispose: (data) {},
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
                "timestamp": entryToEdit['timestamp'],
              };

              setState(() {
                final newList = List<Map<String, dynamic>>.from(_storedData);
                newList[indexToEdit] = newEntry;
                _storedData = newList;
                _saveWorkouts();
              });
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
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _storedData = List.from(_storedData)..remove(entryToDelete);
                  _saveWorkouts();
                });
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    return wasConfirmed ?? false;
  }

  /// Shows the "Add Exercise" dialog.
  void _showAddExerciseDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AddExerciseDialog(
          exerciseData: _exerciseData,
          onSave: _addExercise,
        );
      },
    );
  }

  /// Adds a new custom exercise to the user's list.
  void _addExercise(String name, String mainGroup, String subGroup) {
    setState(() {
      final newExerciseData = Map<String, Map<String, List<Map<String, String>>>>.from(_exerciseData);
      newExerciseData[mainGroup]?[subGroup]?.add({'name': name});
      _exerciseData = newExerciseData;
      _saveExercises();
    });
  }

  /// Deletes a single exercise from the user's list.
  void _deleteExercise(String mainGroup, String subGroup, String exerciseName) {
    setState(() {
      final newExerciseData = Map<String, Map<String, List<Map<String, String>>>>.from(_exerciseData);
      final exerciseList = newExerciseData[mainGroup]?[subGroup];
      exerciseList?.removeWhere((exercise) => exercise['name'] == exerciseName);
      _exerciseData = newExerciseData;
      _saveExercises();
    });
  }

  /// Shows a confirmation dialog for deleting an entire category.
  Future<void> _confirmDeleteCategory(String mainGroup, String subGroup) async {
    final bool? wasConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "$subGroup"?'),
          content: Text(
              'Are you sure you want to delete the "$subGroup" category and all of its exercises? This cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (wasConfirmed == true) {
      setState(() {
        final newExerciseData = Map<String, Map<String, List<Map<String, String>>>>.from(_exerciseData);
        newExerciseData[mainGroup]?.remove(subGroup);
        _exerciseData = newExerciseData;
        _saveExercises();
      });
    }
  }

  // ===========================================================================
  // Build Method
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    // The main UI is delegated to the HomeScreen widget.
    // This keeps the state management logic separate from the UI code.
    return HomeScreen(
      exerciseData: _exerciseData,
      onLogWorkout: _showInputDialogWithPreset,
      onViewHistory: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => WorkoutHistoryPage(
              storedData: _storedData,
              onEdit: _showEditDialog,
              onDelete: _confirmDelete,
            ),
          ),
        );
      },
      onAddExercise: _showAddExerciseDialog,
      onDeleteCategory: _confirmDeleteCategory,
      onDeleteExercise: _deleteExercise,
      onSignOut: _signOut,
    );
  }
}