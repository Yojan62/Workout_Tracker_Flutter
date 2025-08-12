import 'package:intl/intl.dart' show DateFormat;

/// A helper function to create user-friendly date labels.
  String relativeDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(entryDate).inDays;

    if (difference == 0) return "Today";
    if (difference == 1) return "Yesterday";
    if (difference < 7) return DateFormat('EEEE').format(date); // e.g., "Tuesday"
    return DateFormat('EEE, MMM d').format(date); // e.g., "Tue, Jul 15"
  }