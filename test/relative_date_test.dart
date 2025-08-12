import 'package:flutter_application_1/relative_date.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  // Group tests related to the relativeDateLabel function
  group('relativeDateLabel', () {
    
    test('should return "Today" for the current date', () {
      // Arrange
      final date = DateTime.now();
      
      // Act
      final result = relativeDateLabel(date);
      
      // Assert
      expect(result, 'Today');
    });

    test('should return "Yesterday" for the previous day', () {
      final date = DateTime.now().subtract(const Duration(days: 1));
      final result = relativeDateLabel(date);
      expect(result, 'Yesterday');
    });

    test('should return the day of the week for a date 3 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 3));
      // Expected result will be the name of the day, e.g., "Monday"
      final expectedDay = DateFormat('EEEE').format(date); 
      
      final result = relativeDateLabel(date);
      expect(result, expectedDay);
    });

    test('should return the formatted date for a date 10 days ago', () {
      final date = DateTime.now().subtract(const Duration(days: 10));
      // Expected result will be a format like "Mon, Jul 21"
      final expectedFormat = DateFormat('EEE, MMM d').format(date);
      
      final result = relativeDateLabel(date);
      expect(result, expectedFormat);
    });
  });
}