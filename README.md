# Lift Log 🏋️

A full-stack workout tracker application built with Flutter and Firebase. This app allows users to create an account, log their workouts with sets and reps, and track their history across multiple devices.

---

## 📸 Screenshots

| Login Screen | Home Screen | History Page |
| :---: | :---: | :---: |
| <img src="assets/LoginPage.jpg" alt="Login screen" width="250" /> | <img src="assets/HomeScreen.jpg" alt="Home screen" width="250" /> | <img src="assets/HistoryPage.jpg" alt="History page" width="250" /> |


---

## ✨ Key Features

- **User Authentication:**
  - Secure sign-up & login with email and password.
  - Email verification to ensure valid users.
  - "Forgot Password" functionality.
- **Cloud Data Storage:**
  - All user data (workout logs, custom exercises) is stored securely in **Cloud Firestore**.
  - Data is tied to the user's account and syncs across devices.
- **Dynamic Exercise Library:**
  - Users start with a comprehensive default list of exercises, grouped by category.
  - Users can add their own custom exercises.
  - Users can delete individual exercises or entire categories.
- **Workout History:**
  - View a complete history of all logged workouts.
  - Edit or delete past workout entries.
  - Intuitive **swipe-to-delete** gesture.

---

## 🛠️ Tech Stack

- **Frontend:** Flutter
- **Backend & Database:** Firebase (Authentication & Cloud Firestore)
- **State Management:** `StatefulWidget` with `setState`
- **Packages:** `firebase_auth`, `cloud_firestore`, `intl`

---

## 🏗️ Architecture

**Data model: one Firestore document per user.** All of a user's data lives in a single document, `users/{uid}`, with two fields:

- `workouts`: an array of logged entries. Each entry has `exercise`, `timestamp` and `type`, plus type-specific fields (`sets` for strength, `duration`/`speed` for cardio, `duration` for duration).
- `exercises`: the user's exercise library, a nested map of main group → muscle group → list of `{name, type}`. New users are seeded from the defaults in `lib/workout_data.dart`.

The app loads the document once at startup and keeps it in state in `lib/main.dart`. Each save writes the whole field back with `set(..., SetOptions(merge: true))`. Saving a workout rewrites the full `workouts` array, and saving exercises rewrites the full `exercises` map.

**Exercise types drive the logging UI.** Every exercise carries a `type` (`strength`, `cardio` or `duration`, defaulting to `strength`). Tapping an exercise opens the matching dialog:

| `type` | Dialog | Records |
| --- | --- | --- |
| `strength` | `LogWorkoutDialog` | sets of weight × reps |
| `cardio` | `LogCardioDialog` | duration and speed |
| `duration` | `LogDurationDialog` | duration (e.g. planks) |

Logged entries store the same `type`, so editing an entry from History reopens the same kind of dialog.
