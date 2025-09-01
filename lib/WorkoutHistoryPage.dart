import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'history_entry_card.dart';

/// A stateful page that displays the history of all logged workouts.
///
/// It's a StatefulWidget so it can manage a local copy of the data (`_displayData`)
/// and update its own UI instantly when an item is edited or deleted.
class WorkoutHistoryPage extends StatefulWidget {
  /// The master list of workout logs, passed from MyHomePage.
  final List<Map<String, dynamic>> storedData;
  /// Callback to the parent to handle editing an entry.
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> entry) onEdit;
  /// Callback to the parent to handle deleting an entry.
  final Future<bool> Function(Map<String, dynamic> entry) onDelete;

  const WorkoutHistoryPage({
    super.key,
    required this.storedData,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<WorkoutHistoryPage> createState() => _WorkoutHistoryPageState();
}

class _WorkoutHistoryPageState extends State<WorkoutHistoryPage> {
  /// A local copy of the workout data. The UI is built from this list,
  /// allowing us to make instant visual changes (like removing an item)
  /// without waiting for the parent widget to rebuild.
  late List<Map<String, dynamic>> _displayData;

  @override
  void initState() {
    super.initState();
    // When the widget is first created, initialize our local display data
    // with the master list passed from the parent.
    _displayData = List.from(widget.storedData);
  }

  /// This lifecycle method is called when the parent widget rebuilds and provides
  /// new data to this widget. It's how we keep our local `_displayData` in sync.
  @override
  void didUpdateWidget(covariant WorkoutHistoryPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the master list of data from the parent has changed, we update our
    // local copy to match.
    if (widget.storedData != oldWidget.storedData) {
      setState(() {
        _displayData = List.from(widget.storedData);
      });
    }
  }

  /// A helper function to create user-friendly date labels (e.g., "Today").
  String _relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference < 7) return DateFormat('EEEE').format(date);
    return DateFormat('EEE, MMM d').format(date);
  }

  @override
  Widget build(BuildContext context) {
    // --- Data Processing ---
    // All UI logic is derived from the local _displayData variable.

    // 1. Create a sorted copy of the data for display (newest first).
    final sortedData = List<Map<String, dynamic>>.from(_displayData)
      ..sort((a, b) {
        // Safely compare timestamps, providing a default to prevent crashes from bad data.
        final dateA = a["timestamp"] as DateTime? ?? DateTime(1970);
        final dateB = b["timestamp"] as DateTime? ?? DateTime(1970);
        return dateB.compareTo(dateA);
      });

    // 2. Calculate total volume for the summary card.
    final double totalVolume = sortedData.fold(0.0, (sum, entry) {
      // Safely get the 'sets' list, defaulting to an empty list if null.
      final sets = (entry["sets"] as List<dynamic>?) ?? [];
      // Calculate the volume for this single entry.
      final double entryVolume = sets.fold(0.0, (setSum, s) {
        if (s is Map) {
          final weight = (s["weight"] as num?)?.toDouble() ?? 0.0;
          final reps = (s["reps"] as num?)?.toInt() ?? 0;
          return setSum + (weight * reps);
        }
        return setSum;
      });
      return sum + entryVolume;
    });

    // 3. Group the sorted data by date labels.
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var entry in sortedData) {
      final date = entry["timestamp"] as DateTime?;
      if (date != null) {
        final label = _relativeDateLabel(date);
        grouped.putIfAbsent(label, () => []).add(entry);
      }
    }

    // --- UI Building ---
    return Scaffold(
      appBar: AppBar(title: const Text("Workout History")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Section 1: Summary Card (Always Visible) --
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.insights, size: 32),
              title: Text(
                "Total Workouts: ${sortedData.length}",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Total Volume: ${totalVolume.toStringAsFixed(1)} kg"),
            ),
          ),
          const SizedBox(height: 20),

          // -- Section 2: Conditional Workout List --
          // Use a "collection if" to decide what to show in the list.
          if (sortedData.isEmpty)
            // If there's no data, show a helpful message.
            const Padding(
              padding: EdgeInsets.only(top: 50.0),
              child: Center(
                  child: Text("Your workout history will appear here!",
                      textAlign: TextAlign.center)),
            )
          else
            // If there IS data, show the list of workout groups.
            ...grouped.entries.map((group) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                    child: Text(group.key,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  ...group.value.map((entry) {
                    // Each entry is a Dismissible for swipe-to-delete.
                    return Dismissible(
                      key: ValueKey(entry['timestamp']),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete_forever, color: Colors.white)
                      ),
                      confirmDismiss: (direction) => widget.onDelete(entry),
                      onDismissed: (direction) {
                        setState(() {
                          _displayData.remove(entry);
                        });
                      },
                      // The child is our custom, self-contained, expandable card widget.
                      child: HistoryEntryCard(
                        entry: entry,
                        onEdit: widget.onEdit,
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
}