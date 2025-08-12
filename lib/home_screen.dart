import 'package:flutter/material.dart';

/// The main screen of the app. It displays a list of workout categories and exercises.
///
/// This is a "dumb" widget, meaning it only displays data and passes user actions
/// (like taps) up to its parent widget to handle the logic.
class HomeScreen extends StatelessWidget {
  /// The nested map of all available exercises.
  final Map<String, Map<String, List<Map<String, String>>>> exerciseData;
  /// A callback function that is triggered when the user taps on an exercise card.
  final void Function(BuildContext context, String exerciseName) onLogWorkout;
  /// A callback function that is triggered when the user taps the history icon.
  final VoidCallback onViewHistory;
  /// A callback function that is triggered when the user taps the add exercise icon.
  final VoidCallback onAddExercise;
  /// A callback function for deleting an entire sub-category.
  final Function(String mainGroup, String subGroup) onDeleteCategory;
  /// A callback function for deleting a single exercise.
  final Function(String mainGroup, String subGroup, String exerciseName) onDeleteExercise;
  final VoidCallback onSignOut;

  const HomeScreen({
    super.key,
    required this.exerciseData,
    required this.onLogWorkout,
    required this.onViewHistory,
    required this.onAddExercise,
    required this.onDeleteCategory,
    required this.onDeleteExercise,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    // Get the list of main group names (e.g., "UPPER BODY", "LOWER BODY")
    final mainGroups = exerciseData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: onSignOut,
        ),
        title: const Text("Lift Log"),
        backgroundColor: const Color(0xFF00deda),
        centerTitle: true,
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 21,
          fontWeight: FontWeight.bold,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Exercise',
            onPressed: onAddExercise,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View Workout History',
            onPressed: onViewHistory,
          ),
        ],
      ),
      // The main list now builds one item for each main group.
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: mainGroups.length,
        itemBuilder: (context, index) {
          final mainGroupTitle = mainGroups[index];
          final subGroups = exerciseData[mainGroupTitle]!;

          // Each item in the list is a Column containing the main title
          // and all of its sub-groups and exercises.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Main Group Title ---
              Padding(
                padding:
                    const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
                child: Text(
                  mainGroupTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                    letterSpacing: 2,
                  ),
                ),
              ),

              // --- Sub-Group List ---
              // We map over the sub-groups (e.g., "Chest", "Back") within this main group.
              ...subGroups.entries.map((subGroupEntry) {
                final subGroupTitle = subGroupEntry.key;
                final exercises = subGroupEntry.value;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sub-Group Title with Delete Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 24.0, top: 8.0, bottom: 8.0),
                          child: Text(
                            subGroupTitle,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.grey),
                          onPressed: () =>
                              onDeleteCategory(mainGroupTitle, subGroupTitle),
                          tooltip: 'Delete Category',
                        ),
                      ],
                    ),
                    // List of exercises in this sub-group
                    ...exercises.map((exercise) {
                      return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ExerciseCard(
                                exerciseName: exercise['name']!,
                                onTap: () =>
                                    onLogWorkout(context, exercise['name']!),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                size: 20, color: Colors.grey),
                            onPressed: () => onDeleteExercise(
                                mainGroupTitle, subGroupTitle, exercise['name']!),
                            tooltip: 'Delete Exercise',
                          ),
                        ],
                      );
                    }),
                  ],
                );
              }),
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.green.withAlpha(50),
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