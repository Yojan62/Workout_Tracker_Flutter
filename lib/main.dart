import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'secondpage.dart'; // Replace with your actual filename

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

  void _showInputDialogWithPreset(BuildContext context, String selectedExercise) {

    final List<TextEditingController> weightControllers = [TextEditingController()];
    final List<TextEditingController> repsControllers = [TextEditingController()];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: Text("Log: $selectedExercise"),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: weightControllers.length,
                      itemBuilder: (context, index) {
                        return Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: weightControllers[index],
                                decoration: InputDecoration(labelText: "Set ${index + 1} - Weight (kg)"),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: repsControllers[index],
                                decoration: InputDecoration(labelText: "Set ${index + 1} - Reps"),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  weightControllers.removeAt(index);
                                  repsControllers.removeAt(index);
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            weightControllers.add(TextEditingController());
                            repsControllers.add(TextEditingController());
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Set"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  final sets = <Map<String, dynamic>>[];
                  for (int i = 0; i < weightControllers.length; i++) {
                    final weight = double.tryParse(weightControllers[i].text) ?? 0.0;
                    final reps = int.tryParse(repsControllers[i].text) ?? 0;
                    sets.add({"weight": weight, "reps": reps});
                  }
                  setState(() {
                    _storedData.add({
                      "exercise": selectedExercise,
                      "sets": sets,
                      "timestamp": DateTime.now(),
                    });
                  });
                  Navigator.of(context).pop();
                },
                child: const Text("Save"),
              ),
            ],
          ),
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