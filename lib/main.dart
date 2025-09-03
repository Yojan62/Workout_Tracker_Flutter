import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'app_theme.dart';
import 'auth_gate.dart';
import 'home_screen.dart';
import 'WorkoutHistoryPage.dart';
import 'account_screen.dart';
import 'log_workout_dialog.dart';
import 'add_exercise_dialog.dart';
import 'workout_data.dart';
import 'log_cardio_dialog.dart';
import 'log_duration_dialog.dart';

/// The main entry point for the application.
/// Initializes Firebase before running the app.
Future<void> main() async {
  // Ensures that the Flutter binding is initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();
  // Initializes the Firebase app with the platform-specific options.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const WorkoutApp());
}

/// The root widget of the application.
///
/// This widget sets up the [MaterialApp], defining the app's title, theme,
/// and the initial route, which is handled by the [AuthGate].
class WorkoutApp extends StatelessWidget {
  const WorkoutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lift Log',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// The main stateful widget that holds the bottom navigation bar and manages
/// the app's core data and state after a user has logged in.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

/// The core state management class for the application.
///
/// This class handles all data fetching from Firestore, state updates,
/// and provides all the logic and callbacks to the UI widgets.
class _MyHomePageState extends State<MyHomePage> {
  // ===========================================================================
  // State Variables
  // ===========================================================================

  /// The master list of all saved workout entries (logs) for the current user.
  List<Map<String, dynamic>> _storedData = [];
  /// The nested map of all available exercises for the current user.
  Map<String, Map<String, List<Map<String, String>>>> _exerciseData = {};
  /// A map to temporarily store data from the strength dialog if the user closes it without saving.
  final Map<String, List<SetEntry>> _tempWorkoutData = {};
  /// The index of the currently active tab in the bottom navigation bar.
  int _selectedIndex = 0;
  /// A flag to track the initial data loading state to show a loading spinner on startup.
  bool _isLoading = true;

  // ===========================================================================
  // Lifecycle & Data Loading
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    // Load all necessary user data from Firestore when the page is first created.
    _loadAllData();
  }

  /// Asynchronously loads both the user's custom exercises and their workout history.
  /// Sets the loading state to false when complete.
  void _loadAllData() async {
    await _loadExercises();
    await _loadWorkouts();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // Data Persistence (Cloud Firestore)
  // ===========================================================================

  /// Loads the user's workout logs from their document in Firestore.
  Future<void> _loadWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    
    if (doc.exists && doc.data()!.containsKey('workouts')) {
      final List<dynamic> workoutData = doc.data()!['workouts'];
      if (mounted) {
        setState(() {
          _storedData = workoutData.map((item) {
            final entry = item as Map<String, dynamic>;
            final setsList = (entry['sets'] as List?) ?? [];
            
            entry['timestamp'] = (entry['timestamp'] as Timestamp).toDate();
            entry['sets'] = setsList
                .map((s) => Map<String, dynamic>.from(s))
                .toList();
            return entry;
          }).toList();
        });
      }
    }
  }

  /// Saves the current list of workout logs to the user's document in Firestore.
  Future<void> _saveWorkouts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'workouts': _storedData,
    }, SetOptions(merge: true));
  }

  /// Loads the user's custom exercise list from Firestore.
  /// If no list exists (new user), it loads the default list from [workout_data.dart].
  Future<void> _loadExercises() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (mounted) {
      setState(() {
        if (doc.exists && doc.data()!.containsKey('exercises')) {
          final Map<String, dynamic> loadedData = doc.data()!['exercises'];
          final Map<String, Map<String, List<Map<String, String>>>> tempExerciseData = {};
          loadedData.forEach((mainGroupKey, subGroupValue) {
            final subGroups = Map<String, dynamic>.from(subGroupValue);
            final Map<String, List<Map<String, String>>> tempSubGroupMap = {};
            subGroups.forEach((subGroupKey, exerciseListValue) {
              final exercises = List<Map<String, String>>.from(
                (exerciseListValue as List).map((e) => Map<String, String>.from(e))
              );
              tempSubGroupMap[subGroupKey] = exercises;
            });
            tempExerciseData[mainGroupKey] = tempSubGroupMap;
          });
          _exerciseData = tempExerciseData;
        } else {
          _exerciseData = workoutData;
          _saveExercises();
        }
      });
    }
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

  /// Determines which logging dialog to show based on the exercise type.
  void _showInputDialogWithPreset(BuildContext context, Map<String, String> exercise) {
    final String exerciseName = exercise['name'] ?? 'Unknown Exercise';
    final String exerciseType = exercise['type'] ?? 'strength';

    if (exerciseType == 'strength') {
      _showLogStrengthDialog(context, exerciseName);
    } else if (exerciseType == 'cardio') {
      _showLogCardioDialog(context, exerciseName);
    } else if (exerciseType == 'duration') {
      _showLogDurationDialog(context, exerciseName);
    }
  }
  
  /// Shows the dialog for logging a STRENGTH workout (sets, reps, weight).
  void _showLogStrengthDialog(BuildContext context, String exerciseName) {
    final recentEntries = _storedData
        .where((entry) => entry['exercise'] == exerciseName)
        .take(3)
        .toList();

    final tempSets = _tempWorkoutData[exerciseName] ?? [SetEntry("", "")];
    if (tempSets.isEmpty) {
      tempSets.add(SetEntry("", ""));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogWorkoutDialog(
          exerciseName: exerciseName,
          initialData: tempSets,
          recentHistory: recentEntries,
          onDispose: (currentData) {
            setState(() {
              _tempWorkoutData[exerciseName] = currentData;
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
                  "exercise": exerciseName,
                  "sets": sets,
                  "timestamp": DateTime.now(),
                  "type": "strength",
                });
                _storedData = newList;
                _tempWorkoutData.remove(exerciseName);
                _saveWorkouts();
              });
              Navigator.of(context).pop();
            }
          },
        );
      },
    );
  }

  /// Shows the dialog for logging a CARDIO workout (duration, speed).
  void _showLogCardioDialog(BuildContext context, String exerciseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogCardioDialog(
          exerciseName: exerciseName,
          onSave: (cardioData) {
            setState(() {
              final newList = List<Map<String, dynamic>>.from(_storedData);
              newList.add({
                "exercise": exerciseName,
                ...cardioData,
                "timestamp": DateTime.now(),
                "type": "cardio",
              });
              _storedData = newList;
              _saveWorkouts();
            });
          },
        );
      },
    );
  }
  
  /// Shows the dialog for logging a DURATION workout (e.g., plank).
  void _showLogDurationDialog(BuildContext context, String exerciseName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogDurationDialog(
          exerciseName: exerciseName,
          onSave: (double duration) {
            setState(() {
              final newList = List<Map<String, dynamic>>.from(_storedData);
              newList.add({
                "exercise": exerciseName,
                "duration": duration,
                "timestamp": DateTime.now(),
                "type": "duration",
              });
              _storedData = newList;
              _saveWorkouts();
            });
          },
        );
      },
    );
  }

  /// Shows the correct dialog for EDITING any type of saved workout log.
  Future<Map<String, dynamic>?> _showEditDialog(Map<String, dynamic> entryToEdit) async {
    final int indexToEdit = _storedData.indexOf(entryToEdit);
    if (indexToEdit == -1) return null;

    final String exerciseName = entryToEdit['exercise'] as String;
    final String exerciseType = entryToEdit['type'] ?? 'strength';
    
    if (exerciseType == 'strength') {
      final List<SetEntry> initialSets = (entryToEdit['sets'] as List)
          .map((s) => SetEntry(s['weight'].toString(), s['reps'].toString()))
          .toList();
          
      return await showDialog(
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
                  "type": "strength",
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
    } else if (exerciseType == 'cardio') {
      return await showDialog(
        context: context,
        builder: (context) {
          return LogCardioDialog(
            exerciseName: exerciseName,
            initialData: {
              'duration': entryToEdit['duration'],
              'speed': entryToEdit['speed'],
            },
            onSave: (cardioData) {
              final newEntry = {
                "exercise": exerciseName,
                ...cardioData,
                "timestamp": entryToEdit['timestamp'],
                "type": "cardio",
              };
              setState(() {
                final newList = List<Map<String, dynamic>>.from(_storedData);
                newList[indexToEdit] = newEntry;
                _storedData = newList;
                _saveWorkouts();
              });
              Navigator.of(context).pop(newEntry);
            },
          );
        },
      );
    } else if (exerciseType == 'duration') {
      return await showDialog(
        context: context,
        builder: (context) {
          return LogDurationDialog(
            exerciseName: exerciseName,
            initialDuration: entryToEdit['duration'],
            onSave: (double duration) {
              final newEntry = {
                "exercise": exerciseName,
                "duration": duration,
                "timestamp": entryToEdit['timestamp'],
                "type": "duration",
              };
              setState(() {
                final newList = List<Map<String, dynamic>>.from(_storedData);
                newList[indexToEdit] = newEntry;
                _storedData = newList;
                _saveWorkouts();
              });
              Navigator.of(context).pop(newEntry);
            },
          );
        },
      );
    }
    return null;
  }

  /// Shows a confirmation dialog for DELETING a workout log.
  Future<bool> _confirmDelete(Map<String, dynamic> entryToDelete) async {
    final bool? wasConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this workout entry?'),
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
      newExerciseData[mainGroup]?[subGroup]?.add({'name': name, 'type': 'strength'});
      _exerciseData = newExerciseData;
      _saveExercises();
    });
  }

  /// Shows a confirmation dialog for deleting a single exercise.
  Future<void> _confirmDeleteExercise(String mainGroup, String subGroup, String exerciseName) async {
    final bool? wasConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete "$exerciseName"?'),
          content: const Text('Are you sure you want to delete this exercise? This cannot be undone.'),
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
        final exerciseList = newExerciseData[mainGroup]?[subGroup];
        exerciseList?.removeWhere((exercise) => exercise['name'] == exerciseName);
        _exerciseData = newExerciseData;
        _saveExercises();
      });
    }
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
  // Build Method and Navigation
  // ===========================================================================

  /// Handles taps on the BottomNavigationBar.
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // While data is loading from Firestore, show a loading spinner.
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    // Once loading is complete, define the pages for the navigation bar.
    final List<Widget> pages = [
      HomeScreen(
        exerciseData: _exerciseData,
        onLogWorkout: _showInputDialogWithPreset,
        onAddExercise: _showAddExerciseDialog,
        onDeleteCategory: _confirmDeleteCategory,
        onDeleteExercise: _confirmDeleteExercise,
      ),
      WorkoutHistoryPage(
        storedData: _storedData,
        onEdit: _showEditDialog,
        onDelete: _confirmDelete,
      ),
      const AccountScreen(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}