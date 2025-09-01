import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// A screen that informs the user they need to verify their email address.
///
/// This screen is shown by the [AuthGate] after a user signs up but before
/// their email has been verified. It provides instructions and actions for the user.
class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Your Email"),
        actions: [
          // Provides a way for the user to sign out and return to the login screen.
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Informational text explaining the next step to the user.
            const Text(
              "A verification link has been sent to your email. Please click the link to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // A button to allow the user to resend the verification email if needed.
            ElevatedButton(
              onPressed: () {
                // The `?` is a null-safe operator. The email is only sent if a user is logged in.
                FirebaseAuth.instance.currentUser?.sendEmailVerification();
                // Show a SnackBar to confirm to the user that the action was performed.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification email resent!')),
                );
              },
              child: const Text("Resend Email"),
            ),
          ],
        ),
      ),
    );
  }
}