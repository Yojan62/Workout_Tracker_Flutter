import 'package:flutter/material.dart';
import 'workout_data.dart';

/// The main screen of the app. It displays a list of workout categories and exercises.
///
/// This is a "dumb" widget, meaning it only displays data and passes user actions
/// (like taps) up to its parent widget to handle the logic.
class HomeScreen extends StatelessWidget {
  /// A callback function that is triggered when the user taps on an exercise card.
  final void Function(BuildContext context, String exerciseName) onLogWorkout;
  /// A callback function that is triggered when the user taps the history icon.
  final VoidCallback onViewHistory;

  const HomeScreen({
    super.key,
    required this.onLogWorkout,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    // Get the list of category names (e.g., "Chest", "Legs") from our data map.
    final categories = workoutData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Tracker"),
        backgroundColor: const Color(0xFF00deda),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: onViewHistory,
            tooltip: 'View Workout History',
          ),
        ],
      ),
      // Use ListView.builder for an efficient, scrollable list that only builds
      // the items that are currently visible on screen.
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final exercises = workoutData[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the category title (e.g., "Chest")
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 16.0, bottom: 8.0),
                child: Text(
                  category,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              // Map over the list of exercises for this category and create
              // an ExerciseCard for each one.
              ...exercises.map((exercise) {
                return ExerciseCard(
                  exerciseName: exercise['name']!,
                  onTap: () => onLogWorkout(context, exercise['name']!),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

/// A reusable, tappable card widget to display a single exercise name.
class ExerciseCard extends StatelessWidget {
  final String exerciseName;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exerciseName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // Use clipBehavior to ensure the splash effect from InkWell is rounded.
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.green.withAlpha(50),
        // Since there is only one item (the text), we can simplify the layout
        // by using a Container with padding and alignment.
        child: Container(
          height: 80,
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          alignment: Alignment.centerLeft,
          child: Text(
            exerciseName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}