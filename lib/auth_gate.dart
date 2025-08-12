import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/verify_email_screen.dart';
import 'log_screen.dart';
import 'main.dart';

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // If no user is logged in, show the login screen.
          return const LoginScreen();
        } else {
          // If a user IS logged in...
          // Check if their email is verified.
          if (snapshot.data!.emailVerified) {
            // If yes, show the main app.
            return const MyHomePage();
          } else {
            // If no, show them a screen telling them to verify their email.
            return const VerifyEmailScreen();
          }
        }
      },
    );
  }
}