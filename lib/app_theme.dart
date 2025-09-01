import 'package:flutter/material.dart';

/// A central place to define the application's theme data.
///
/// This class holds static [ThemeData] objects for both light and dark modes,
/// ensuring a consistent look and feel across the entire app.
class AppTheme {
  /// The primary seed color used to generate the entire color palette for the app.
  /// Changing this one color will update the app's look and feel everywhere.
  static const Color _seedColor = Color(0xFF00deda);

  // --- Light Theme Definition ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // A ColorScheme is a palette of colors that are designed to work well together.
    // `fromSeed` automatically generates a full, harmonious, and accessible palette
    // from the single `_seedColor`.
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
      background: const Color(0xFFF5F5F5), // A custom, slightly off-white background
    ),
    // Defines the default style for all AppBars in the app.
    appBarTheme: AppBarTheme(
      // Instead of a hardcoded color, we use a color from the generated scheme.
      // `primaryContainer` is a color designed to contain primary elements.
      backgroundColor: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light).primaryContainer,
      elevation: 0,
      // `onPrimaryContainer` is the color designed to be readable on top of `primaryContainer`.
      foregroundColor: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light).onPrimaryContainer,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.light).onPrimaryContainer,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  // --- Dark Theme Definition ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      background: const Color(0xFF121212), // A standard dark mode background
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark).primaryContainer,
      elevation: 0,
      foregroundColor: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark).onPrimaryContainer,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark).onPrimaryContainer,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}