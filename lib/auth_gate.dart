import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'log_screen.dart';
import 'main.dart'; // Used to navigate to MyHomePage

/// A widget that acts as a gatekeeper for the app's authentication state.
///
/// This widget listens for changes in the user's sign-in status and displays
/// either the main application ([MyHomePage]) if the user is signed in, or the
/// [LoginScreen] if they are not.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // A StreamBuilder rebuilds its UI whenever it receives a new value from the stream.
    return StreamBuilder<User?>(
      // FirebaseAuth.instance.authStateChanges() provides a real-time stream
      // that emits a User object when someone logs in, and null when they log out.
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // While the stream is connecting to Firebase, show a loading indicator.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // `snapshot.hasData` is true if the stream has emitted a non-null User object,
        // which means a user is currently signed in.
        if (snapshot.hasData) {
          // If a user is logged in, show the main application.
          return const MyHomePage();
        } 
        // Otherwise, no user is signed in.
        else {
          // If no user is logged in, show the login screen.
          return const LoginScreen();
        }
      },
    );
  }
}