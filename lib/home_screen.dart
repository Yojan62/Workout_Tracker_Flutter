import 'package:flutter/material.dart';

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
    final exercises = [
      "Bench Press",
      "Leg Press",
      "Shoulder Press",
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout Tracker"),
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: onViewHistory,
            tooltip: 'View Workout History',
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: exercises.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 3 / 2,
        ),
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return InkWell(
            onTap: () => onLogWorkout(context, exercise),
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/placeholder.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.black45,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    exercise,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}