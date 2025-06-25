import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SecondPage extends StatelessWidget {
  final List<Map<String, dynamic>> storedData;

  const SecondPage({super.key, required this.storedData});

  @override
  Widget build(BuildContext context) {
    final sortedData = List<Map<String, dynamic>>.from(storedData)
      ..sort((a, b) => b["timestamp"].compareTo(a["timestamp"]));

    final totalReps = sortedData.fold<int>(
      0,
      (sum, entry) {
        final sets = entry["sets"] as List<dynamic>? ?? [];
        return sum + sets.fold<int>(0, (setSum, s) => setSum + (s["reps"] as int? ?? 0));
      },
    );

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var entry in sortedData) {
      final date = entry["timestamp"] as DateTime;
      final label = _relativeDateLabel(date);
      grouped.putIfAbsent(label, () => []).add(entry);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
        backgroundColor: Colors.green.shade600,
        centerTitle: true,
      ),
      body: sortedData.isEmpty
          ? const Center(
              child: Text("No workout data added yet.", style: TextStyle(fontSize: 18)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  color: const Color(0xFFE8F5E9),
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.insights, size: 32, color: Colors.green),
                    title: Text(
                      "Entries: ${sortedData.length}",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Total Reps: $totalReps"),
                  ),
                ),
                const SizedBox(height: 20),
                ...grouped.entries.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.key,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ...group.value.map((entry) {
                        final sets = entry["sets"] as List<dynamic>;

                        final headerRow = Row(
                          children: List.generate(sets.length, (i) {
                            return Expanded(
                              child: Text(
                                "Set ${i + 1}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            );
                          }),
                        );

                        final valueRow = Row(
                          children: sets.map((set) {
                            return Expanded(
                              child: Text(
                                "${set["weight"]}kg x ${set["reps"]}",
                                textAlign: TextAlign.center,
                              ),
                            );
                          }).toList(),
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(entry["exercise"], style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              headerRow,
                              valueRow,
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  String _relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference < 7) return DateFormat('EEEE').format(date);
    if (difference < 14) return "Last Week ${DateFormat('EEEE').format(date)}";
    return DateFormat('EEE, MMM d').format(date);
  }
}