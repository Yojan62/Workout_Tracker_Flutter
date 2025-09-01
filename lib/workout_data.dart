/// A static, hardcoded "database" of all available workout exercises.
///
/// This file provides the INITIAL set of categories and exercises for a new user.
/// When a new user signs up, this list is loaded and saved to their personal
/// account in Firestore, which they can then customize by adding or deleting
/// exercises and categories.
///
/// The data structure is a nested Map:
/// - The outer key is the main group (e.g., "UPPER BODY").
/// - The value is another Map, where:
///   - The key is the muscle group (e.g., "Chest").
///   - The value is the list of exercises, each with a 'name' and a 'type'.
final Map<String, Map<String, List<Map<String, String>>>> workoutData = {
  // ===========================================================================
  // UPPER BODY
  // ===========================================================================
  "UPPER BODY": {
    "Chest": [
      {"name": "Bench Press", "type": "strength"},
      {"name": "Incline Dumbbell Press", "type": "strength"},
      {"name": "Dumbbell Flyes", "type": "strength"},
      {"name": "Dips", "type": "strength"},
      {"name": "Push-ups", "type": "strength"},
    ],
    "Back": [
      {"name": "Deadlift", "type": "strength"},
      {"name": "Pull-ups", "type": "strength"},
      {"name": "Bent Over Row", "type": "strength"},
      {"name": "Lat Pulldown", "type": "strength"},
      {"name": "T-Bar Row", "type": "strength"},
    ],
    "Shoulders": [
      {"name": "Overhead Press", "type": "strength"},
      {"name": "Dumbbell Lateral Raise", "type": "strength"},
      {"name": "Face Pull", "type": "strength"},
      {"name": "Front Raise", "type": "strength"},
      {"name": "Arnold Press", "type": "strength"},
    ],
    "Biceps": [
      {"name": "Barbell Curl", "type": "strength"},
      {"name": "Dumbbell Curl", "type": "strength"},
      {"name": "Hammer Curl", "type": "strength"},
      {"name": "Preacher Curl", "type": "strength"},
      {"name": "Chin-ups", "type": "strength"},
    ],
    "Triceps": [
      {"name": "Tricep Dips", "type": "strength"},
      {"name": "Skull Crusher", "type": "strength"},
      {"name": "Tricep Pushdown", "type": "strength"},
      {"name": "Overhead Tricep Extension", "type": "strength"},
      {"name": "Close-Grip Bench Press", "type": "strength"},
    ],
  },
  // ===========================================================================
  // LOWER BODY
  // ===========================================================================
  "LOWER BODY": {
    "Quads": [
      {"name": "Barbell Squat", "type": "strength"},
      {"name": "Leg Press", "type": "strength"},
      {"name": "Lunges", "type": "strength"},
      {"name": "Leg Extension", "type": "strength"},
      {"name": "Goblet Squat", "type": "strength"},
    ],
    "Hamstrings": [
      {"name": "Romanian Deadlift", "type": "strength"},
      {"name": "Lying Leg Curl", "type": "strength"},
      {"name": "Good Mornings", "type": "strength"},
      {"name": "Kettlebell Swing", "type": "strength"},
      {"name": "Glute-Ham Raise", "type": "strength"},
    ],
    "Glutes": [
      {"name": "Hip Thrust", "type": "strength"},
      {"name": "Glute Bridge", "type": "strength"},
      {"name": "Cable Kickback", "type": "strength"},
      {"name": "Bulgarian Split Squat", "type": "strength"},
      {"name": "Sumo Deadlift", "type": "strength"},
    ],
    "Calves": [
      {"name": "Standing Calf Raise", "type": "strength"},
      {"name": "Seated Calf Raise", "type": "strength"},
      {"name": "Leg Press Calf Raise", "type": "strength"},
      {"name": "Jump Rope", "type": "duration"},
      {"name": "Box Jumps", "type": "strength"},
    ],
  },
  // ===========================================================================
  // FULL BODY & OTHER
  // ===========================================================================
  "OTHER": {
    "Core": [
      {"name": "Plank", "type": "duration"},
      {"name": "Crunches", "type": "strength"},
      {"name": "Leg Raises", "type": "strength"},
      {"name": "Russian Twist", "type": "strength"},
      {"name": "Cable Crunch", "type": "strength"},
    ],
    "Cardio": [
      {"name": "Running", "type": "cardio"},
      {"name": "Cycling", "type": "cardio"},
      {"name": "Rowing Machine", "type": "cardio"},
      {"name": "Stair Climber", "type": "cardio"},
      {"name": "Elliptical", "type": "cardio"},
    ],
    "Olympic Lifts": [
      {"name": "Snatch", "type": "strength"},
      {"name": "Clean and Jerk", "type": "strength"},
      {"name": "Power Clean", "type": "strength"},
      {"name": "Hang Clean", "type": "strength"},
      {"name": "Jerk", "type": "strength"},
    ],
  },
};