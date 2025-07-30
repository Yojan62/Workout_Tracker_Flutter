import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A stateful page that displays the history of all logged workouts.
///
/// It's a StatefulWidget so it can manage a local copy of the data (`_displayData`)
/// and update its own UI instantly when an item is edited or deleted, providing a
/// smooth user experience.
class SecondPage extends StatefulWidget {
  final List<Map<String, dynamic>> storedData;
  /// Callback to the parent to handle editing an entry. It returns the updated
  /// entry so the UI can refresh instantly.
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> entry) onEdit;
  /// Callback to the parent to handle deleting an entry. It returns a boolean
  /// to confirm if the deletion was successful.
  final Future<bool> Function(Map<String, dynamic> entry) onDelete;

  const SecondPage({
    super.key,
    required this.storedData,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  /// A local copy of the workout data. The UI is built from this list,
  /// allowing us to make instant visual changes (like removing an item)
  /// without waiting for the parent widget.
  late List<Map<String, dynamic>> _displayData;

  @override
  void initState() {
    super.initState();
    // When the widget is first created, initialize our local display data
    // with the master list from the parent.
    _displayData = List.from(widget.storedData);
  }

  /// This lifecycle method is called when the parent widget rebuilds and provides
  /// new data to this widget. It's a way for a child to react to state
  /// changes in its parent.
  @override
  void didUpdateWidget(covariant SecondPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the master list of data from the parent has changed, we update our
    // local copy to match.
    if (widget.storedData != oldWidget.storedData) {
      setState(() {
        _displayData = List.from(widget.storedData);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- Data Processing ---
    // All UI logic is derived from the local _displayData variable.

    // 1. Create a sorted copy of the data for display (newest first).
    final sortedData = List<Map<String, dynamic>>.from(_displayData)
      ..sort((a, b) =>
          (b["timestamp"] as DateTime).compareTo(a["timestamp"] as DateTime));

    // 2. Calculate total reps for the summary card.
    final totalReps = sortedData.fold<int>(
      0,
      (sum, entry) {
        final sets = entry["sets"] as List<dynamic>? ?? [];
        return sum +
            sets.fold<int>(0, (setSum, s) => setSum + (s["reps"] as int? ?? 0));
      },
    );

    // 3. Group the sorted data by date labels (e.g., "Today", "Yesterday").
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var entry in sortedData) {
      final date = entry["timestamp"] as DateTime;
      final label = _relativeDateLabel(date);
      grouped.putIfAbsent(label, () => []).add(entry);
    }

    // --- UI Building ---
    return Scaffold(
      appBar: AppBar(
        title: const Text("Workout History"),
        backgroundColor: const Color(0xFF00deda),
        centerTitle: true,
        titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        ),
      ),
      body: sortedData.isEmpty
          ? const Center(
              child: Text("No workout data added yet.",
                  style: TextStyle(fontSize: 18)),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // -- Section 1: Summary Card --
                Card(
                  color: const Color(0xFF00deda),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.insights, size: 32, color: Colors.black),
                    title: Text(
                      "Entries: ${sortedData.length}",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("Total Reps: $totalReps"),
                  ),
                ),
                const SizedBox(height: 20),

                // -- Section 2: Grouped Workout List --
                // Map over the date groups to create a section for each.
                ...grouped.entries.map((group) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                        child: Text(
                          group.key,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      // Map over the workouts within each group to create an entry card.
                      ...group.value.map((entry) {
                        final sets = entry["sets"] as List<dynamic>;
                        final headerRow = Row(
                          children: List.generate(sets.length, (i) {
                            return Expanded(
                              child: Text(
                                "Set ${i + 1}",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black54),
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

                        // Each entry is wrapped in a Dismissible for swipe-to-delete.
                        return Dismissible(
                          key: ValueKey(entry['timestamp']),
                          background: Container(
                            color: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            alignment: Alignment.centerRight,
                            child: const Icon(Icons.delete_forever,
                                color: Colors.white),
                          ),
                          // Shows a confirmation dialog before dismissing.
                          confirmDismiss: (direction) {
                            return widget.onDelete(entry);
                          },
                          // Updates the local UI instantly after a successful dismiss.
                          onDismissed: (direction) {
                            setState(() {
                              _displayData.remove(entry);
                            });
                          },
                          // The actual card the user sees and interacts with.
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 12, 4, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(entry["exercise"],
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 8),
                                        headerRow,
                                        const SizedBox(height: 2),
                                        valueRow,
                                      ],
                                    ),
                                  ),
                                  // Edit Button
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.grey),
                                    onPressed: () async {
                                      // Wait for the edit dialog to close and get the updated data back.
                                      final updatedEntry =
                                          await widget.onEdit(entry);
                                      // If the edit was successful, update the local list and refresh the UI.
                                      if (updatedEntry != null && mounted) {
                                        setState(() {
                                          final index =
                                              _displayData.indexOf(entry);
                                          if (index != -1) {
                                            _displayData[index] = updatedEntry;
                                          }
                                        });
                                      }
                                    },
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                }),
              ],
            ),
    );
  }

  /// A helper function to create user-friendly date labels.
  String _relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference < 7) return DateFormat('EEEE').format(date); // e.g., "Tuesday"
    return DateFormat('EEE, MMM d').format(date); // e.g., "Tue, Jul 15"
  }
}