import 'package:flutter/material.dart';

/// The main screen of the app, displayed on the "Home" tab of the navigation bar.
///
/// This is a [StatefulWidget] because it needs to manage a [TabController] to
/// handle the tab navigation for the main exercise groups.
class HomeScreen extends StatefulWidget {
  final Map<String, Map<String, List<Map<String, String>>>> exerciseData;
  final void Function(BuildContext context, Map<String, String> exercise) onLogWorkout;
  final VoidCallback onAddExercise;
  final Function(String mainGroup, String subGroup) onDeleteCategory;
  final Future<void> Function(String mainGroup, String subGroup, String exerciseName)
      onDeleteExercise;

  const HomeScreen({
    super.key,
    required this.exerciseData,
    required this.onLogWorkout,
    required this.onAddExercise,
    required this.onDeleteCategory,
    required this.onDeleteExercise,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The state class for the [HomeScreen].
///
/// It uses a [TickerProviderStateMixin] to provide the necessary `vsync`
/// for the [TabController]'s animations. We use the multi-ticker version because
/// the controller is recreated when the data changes.
class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  /// The controller that manages the state and animations of the [TabBar] and [TabBarView].
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller with the number of main categories.
    // At this point, exerciseData might be empty, so the length will be 0.
    _tabController =
        TabController(length: widget.exerciseData.keys.length, vsync: this);
  }

  /// This method is called when the parent widget (MyHomePage) rebuilds and provides new data.
  /// It's crucial for handling the asynchronously loaded exercise data.
  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the data has actually changed by comparing the number of categories.
    if (widget.exerciseData.keys.length != oldWidget.exerciseData.keys.length) {
      // If the data has changed, we must recreate the controller with the new, correct length.
      _tabController.dispose();
      _tabController =
          TabController(length: widget.exerciseData.keys.length, vsync: this);
    }
  }

  @override
  void dispose() {
    // It's important to dispose of the controller when the widget is removed to free up resources.
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainGroups = widget.exerciseData.keys.toList();

    // The TabController's index must be valid for its length. If a category is
    // deleted, the index might be out of bounds. This line safely resets it.
    if (_tabController.index >= mainGroups.length && mainGroups.isNotEmpty) {
      _tabController.index = 0;
    }
    
    // While the data is still loading, the mainGroups list will be empty.
    // In this case, we show a loading spinner to prevent errors.
    if (mainGroups.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("Lift Log")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Once the data is loaded, build the main UI with the TabBar.
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lift Log"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add New Exercise',
            onPressed: widget.onAddExercise,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: TabBar(
              controller: _tabController,
              isScrollable: true, // Switched back to true to handle many categories
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
              tabs: mainGroups.map((String title) {
                return Tab(text: title);
              }).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        // Create a separate list view for each tab.
        children: mainGroups.map((mainGroupTitle) {
          final subGroups = widget.exerciseData[mainGroupTitle]!;
          return _ExerciseListView(
            subGroups: subGroups,
            mainGroupTitle: mainGroupTitle,
            onLogWorkout: widget.onLogWorkout,
            onDeleteCategory: widget.onDeleteCategory,
            onDeleteExercise: widget.onDeleteExercise,
          );
        }).toList(),
      ),
    );
  }
}

/// A private, reusable widget to display the list of exercises for a single tab.
class _ExerciseListView extends StatelessWidget {
  const _ExerciseListView({
    required this.subGroups,
    required this.mainGroupTitle,
    required this.onLogWorkout,
    required this.onDeleteCategory,
    required this.onDeleteExercise,
  });

  final Map<String, List<Map<String, String>>> subGroups;
  final String mainGroupTitle;
  final void Function(BuildContext context, Map<String, String> exercise) onLogWorkout;
  final Function(String mainGroup, String subGroup) onDeleteCategory;
  final Future<void> Function(String mainGroup, String subGroup, String exerciseName)
      onDeleteExercise;

  @override
  Widget build(BuildContext context) {
    if (subGroups.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text("No categories in this group yet. Add a new exercise!", textAlign: TextAlign.center),
        ),
      );
    }
    
    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: subGroups.entries.map((subGroupEntry) {
        final subGroupTitle = subGroupEntry.key;
        final exercises = subGroupEntry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sub-Group Title with long-press delete functionality.
            GestureDetector(
              onLongPress: () =>
                  onDeleteCategory(mainGroupTitle, subGroupTitle),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                margin:
                    const EdgeInsets.only(left: 16.0, top: 24.0, bottom: 8.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  subGroupTitle,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
            ),
            // List of exercises within the sub-group.
            ...exercises.map((exercise) {
              final String exerciseName = exercise['name'] ?? 'Unnamed Exercise';
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ExerciseCard(
                  exerciseName: exerciseName,
                  onTap: () => onLogWorkout(context, exercise),
                  onLongPress: () => onDeleteExercise(
                      mainGroupTitle, subGroupTitle, exerciseName),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }
}

/// The ExerciseCard widget for displaying a single exercise.
class ExerciseCard extends StatelessWidget {
  final String exerciseName;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ExerciseCard({
    super.key,
    required this.exerciseName,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          title: Text(
            exerciseName,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}