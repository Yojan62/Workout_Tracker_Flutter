/// A static, hardcoded "database" of all available workout exercises.
///
/// This file acts as the master list that the HomeScreen reads to build its UI.
/// Separating this data from the UI code makes it easy to add, remove, or
/// rename exercises without touching any other files.
///
/// The data structure is a Map where:
/// - The key is a String representing the workout category (e.g., "Chest").
/// - The value is a List of Maps, where each inner Map represents a single exercise.
final Map<String, List<Map<String, String>>> workoutData = {
  "Chest": [
    {
      "name": "Bench Press",
    },
    {
      "name": "Incline Bench Press",
    },
    {
      "name": "Dumbbell Flyes",
    },
    {
      "name": "Push-ups",
    },
  ],
  "Legs": [
    {
      "name": "Squat",
    },
    {
      "name": "Leg Press",
    },
    {
      "name": "Lunges",
    },
    {
      "name": "Leg Curls",
    },
    {
      "name": "Calf Raises",
    },
  ],
  "Shoulders": [
    {
      "name": "Shoulder Press",
    },
    {
      "name": "Lateral Raises",
    },
    {
      "name": "Front Raises",
    },
    {
      "name": "Upright Rows",
    },
  ],
  "Back": [
    {
      "name": "Deadlift",
    },
    {
      "name": "Pull-ups",
    },
    {
      "name": "Bent Over Rows",
    },
    {
      "name": "Lat Pulldowns",
    },
  ],
};