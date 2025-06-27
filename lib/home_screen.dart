import 'package:flutter/material.dart';
import 'workout_data.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <--- ADD THIS CORRECT LINE

class HomeScreen extends StatelessWidget {
  final void Function(BuildContext context, String exerciseName) onLogWorkout;
  final VoidCallback onViewHistory;

  const HomeScreen({
    super.key,
    required this.onLogWorkout,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    // Get the list of category names from our data map
    final categories = workoutData.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Tracker"),
        backgroundColor: const Color.fromARGB(255, 67, 127, 160),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: onViewHistory,
            tooltip: 'View Workout History',
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final exercises = workoutData[category]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Title
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
              // List of exercises in this category
              ...exercises.map((exercise) {
                return ExerciseCard(
                  exerciseName: exercise['name']!,
                  imagePath: exercise['image']!,
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

class ExerciseCard extends StatelessWidget {
  final String exerciseName;
  final String imagePath;
  final VoidCallback onTap;

  const ExerciseCard({
    super.key,
    required this.exerciseName,
    required this.imagePath,
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
          height: 90,
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left side: Exercise Name
              Expanded(
                child: Text(
                  exerciseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Right side: Image
              SizedBox(
                // MODIFIED: Increased from 100 to 120 to make the icon bigger.
                // Feel free to experiment with this value!
                width: 120,
                child: SvgPicture.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  colorFilter: const ColorFilter.mode(Colors.black, BlendMode.srcIn),
                  placeholderBuilder: (context) {
                    return const Icon(Icons.fitness_center, color: Colors.grey, size: 40);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}