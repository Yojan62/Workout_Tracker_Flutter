import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A stateful, expandable card widget for displaying a single workout entry.
///
/// This widget shows a summary of a workout by default. When tapped, it
/// animates to an expanded view showing the full set-by-set details.
class HistoryEntryCard extends StatefulWidget {
  /// The map containing all the data for this specific workout entry.
  final Map<String, dynamic> entry;
  /// A callback function to the parent to handle editing this entry.
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> entry) onEdit;

  const HistoryEntryCard({
    super.key,
    required this.entry,
    required this.onEdit,
  });

  @override
  State<HistoryEntryCard> createState() => _HistoryEntryCardState();
}

/// The state class for the [HistoryEntryCard].
class _HistoryEntryCardState extends State<HistoryEntryCard> {
  /// A boolean that tracks the card's current state (expanded or collapsed).
  bool _isExpanded = false;

  /// A robust helper function to find the best set (by weight) in a list of sets.
  /// This is used for displaying the summary for 'strength' type workouts.
  String _findBestSet(List<dynamic>? sets) {
    if (sets == null || sets.isEmpty) return 'No sets logged';

    Map<String, dynamic>? bestSet;
    double maxWeight = -1;

    for (var item in sets) {
      // Ensure the item is a map before accessing its keys to prevent crashes.
      if (item is Map<String, dynamic>) {
        // Safely get the weight, defaulting to 0.0 if null or missing.
        final weight = (item['weight'] as num?)?.toDouble() ?? 0.0;
        if (weight > maxWeight) {
          maxWeight = weight;
          bestSet = item;
        }
      }
    }

    if (bestSet == null) return 'No valid sets';
    
    // Safely get the final weight and reps, providing default values.
    final weight = (bestSet['weight'] as num?)?.toDouble() ?? 0.0;
    final reps = (bestSet['reps'] as num?)?.toInt() ?? 0;

    return "${weight}kg x ${reps}";
  }

  @override
  Widget build(BuildContext context) {
    // Safely access data from the entry map, providing default values to prevent crashes.
    final exerciseName = widget.entry["exercise"] as String? ?? "Unknown Exercise";
    final timestamp = widget.entry["timestamp"] as DateTime? ?? DateTime.now();
    final sets = (widget.entry["sets"] as List<dynamic>?) ?? [];

    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      // Use a ClipRRect to ensure the InkWell splash honors the border radius.
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: InkWell(
          onTap: () {
            // When the card is tapped, toggle the expanded state and trigger a rebuild.
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          child: Column(
            children: [
              // --- The Summary View (Always Visible) ---
              ListTile(
                title: Text(exerciseName,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(DateFormat('MMMM d, y').format(timestamp)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min, // The row should be only as wide as its children.
                  children: [
                    // --- Smart Stat Display ---
                    // This Text widget checks the workout type and displays the relevant metric.
                    Text(
                      widget.entry['type'] == 'strength'
                          ? _findBestSet(sets)
                          : "${(widget.entry['duration'] as num?)?.toStringAsFixed(0) ?? '0'} min",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey, size: 20),
                      onPressed: () => widget.onEdit(widget.entry),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
              // --- The Detailed View (Animated) ---
              // AnimatedCrossFade smoothly transitions between two child widgets.
              AnimatedCrossFade(
                firstChild: Container(), // An empty container when collapsed.
                secondChild: _buildDetails(sets), // The set details when expanded.
                crossFadeState:
                    _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300), // Animation speed.
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// A helper widget to build the detailed set-by-set view for strength workouts.
  Widget _buildDetails(List<dynamic> sets) {
    // If there are no sets (e.g., for a cardio workout), don't show anything.
    if (sets.isEmpty) return Container();

    // Dynamically generate the "Set 1", "Set 2", etc., headers.
    final headerRow = Row(
      children: List.generate(sets.length, (i) {
        return Expanded(
          child: Text("Set ${i + 1}",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                // Use a theme-aware color for readability in light/dark mode.
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center),
        );
      }),
    );

    // Dynamically generate the "Weight x Reps" values.
    final valueRow = Row(
      children: sets.map((set) {
        // Safely access the set data.
        final weight = set["weight"] ?? 0.0;
        final reps = set["reps"] ?? 0;
        return Expanded(
          child: Text(
            "${weight}kg x ${reps}",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }).toList(),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: [
          const Divider(height: 16),
          headerRow,
          const SizedBox(height: 2),
          valueRow,
        ],
      ),
    );
  }
}