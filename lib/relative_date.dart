import 'package:intl/intl.dart' show DateFormat;

/// A utility function that converts a [DateTime] object into a user-friendly,
/// relative date string (e.g., "Today", "Yesterday", "Tuesday").
///
/// [date]: The date to be formatted.
/// Returns a formatted [String].
String relativeDateLabel(DateTime date) {
  // Get the current date and time.
  final now = DateTime.now();
  // Create a DateTime object for today at midnight to ensure a clean day-to-day comparison.
  final today = DateTime(now.year, now.month, now.day);
  // Do the same for the input date to ignore the time part.
  final entryDate = DateTime(date.year, date.month, date.day);

  // Calculate the difference in whole days between today and the entry date.
  final difference = today.difference(entryDate).inDays;

  // Use a series of checks to return the most appropriate label.
  if (difference == 0) return "Today";
  if (difference == 1) return "Yesterday";
  // If the date was within the last week, return the full day name (e.g., "Tuesday").
  if (difference < 7) return DateFormat('EEEE').format(date);
  
  // For any date older than a week, return a standard formatted date (e.g., "Tue, Aug 05").
  return DateFormat('EEE, MMM d').format(date);
}