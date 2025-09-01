import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// The AccountScreen displays user information and provides a sign-out option.
///
/// This is a [StatelessWidget] because it only displays information and does not
/// need to manage any internal state that changes over time.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently authenticated user from the FirebaseAuth instance.
    // This will be null if no user is signed in.
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        // The title for this screen.
        title: const Text("Account"),
      ),
      body: Center(
        // Center the content both horizontally and vertically.
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "You are logged in as:",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),

              // Display the user's email.
              // The `user?.email` is a null-safe way to access the email.
              // If the user or their email is null, it provides a default message.
              Text(
                user?.email ?? 'No email found',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              // The sign-out button.
              ElevatedButton.icon(
                onPressed: () {
                  // Calling signOut() will clear the user's session.
                  // The AuthGate widget will automatically detect this state change
                  // and navigate the user back to the LoginScreen.
                  FirebaseAuth.instance.signOut();
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}