/// A static, hardcoded "database" of all available workout exercises,
/// now organized into main groups.
///
/// The data structure is now a nested Map:
/// - The outer key is the main group (e.g., "UPPER BODY").
/// - The value is another Map, where:
///   - The key is the muscle group (e.g., "Chest").
///   - The value is the list of exercises.
final Map<String, Map<String, List<Map<String, String>>>> workoutData = {
  "UPPER BODY": {
    "Chest": [
      {"name": "Bench Press"},
      {"name": "Incline Bench Press"},
      {"name": "Dumbbell Flyes"},
      {"name": "Push-ups"},
    ],
    "Back": [
      {"name": "Deadlift"},
      {"name": "Pull-ups"},
      {"name": "Bent Over Rows"},
      {"name": "Lat Pulldowns"},
    ],
    "Shoulders": [
      {"name": "Shoulder Press"},
      {"name": "Lateral Raises"},
      {"name": "Front Raises"},
      {"name": "Upright Rows"},
    ],
    "Biceps": [
      {"name": "Bicep Curl"},
      {"name": "Hammer Curl"},
    ],
    "Triceps": [
      {"name": "Tricep Extension"},
      {"name": "Skull Crusher"},
    ],
    "Forearms": [],
    "Traps": [],
  },
  "LOWER BODY": {
    "Quads": [
      {"name": "Squat"},
      {"name": "Leg Press"},
      {"name": "Lunges"},
    ],
    "Hamstrings": [
      {"name": "Romanian Deadlift"},
      {"name": "Leg Curl"},
    ],
    "Glutes": [],
    "Calves": [
      {"name": "Calf Raise"},
    ],
  },
  "FULL BODY & OTHER": {
    "Core": [
      {"name": "Crunches"},
      {"name": "Plank"},
    ],
    "Full Body": [],
    "Olympic Lifts": [],
    "Plyometrics": [],
    "Cardio": [],
  },
};