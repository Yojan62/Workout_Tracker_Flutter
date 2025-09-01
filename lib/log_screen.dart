import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// The LoginScreen provides a UI for users to sign up or log in.
///
/// It's a [StatefulWidget] because it needs to manage the state of the input fields,
/// a loading indicator, and any error messages.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // A GlobalKey to uniquely identify the Form widget and allow validation.
  final _formKey = GlobalKey<FormState>();
  // Controllers to manage the text being entered in the TextFields.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables to control the UI.
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    // It's crucial to dispose of controllers to prevent memory leaks.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handles the user sign-up process with Firebase.
  Future<void> _signUp() async {
    // First, validate the form to ensure the email and password are valid.
    if (!_formKey.currentState!.validate()) return;

    // Show the loading indicator and clear any old error messages.
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use Firebase to create a new user with the provided email and password.
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Send a verification email to the newly created user.
      await userCredential.user?.sendEmailVerification();

      // Show a confirmation message to the user.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A verification email has been sent. Please check your inbox.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      // If Firebase returns an error, display a user-friendly message.
      setState(() {
        if (e.code == 'weak-password') {
          _errorMessage = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          _errorMessage = 'An account already exists for that email.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    } finally {
      // Always hide the loading indicator, even if there was an error.
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles the user login process with Firebase.
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use Firebase to sign in the user.
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // The AuthGate will handle navigation on successful login.
    } on FirebaseAuthException catch (e) {
      // Handle common login errors with a generic message for security.
      setState(() {
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          _errorMessage = 'Invalid email or password.';
        } else {
          _errorMessage = 'An error occurred. Please try again.';
        }
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Handles the "Forgot Password" process.
  Future<void> _forgotPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email to reset your password.')),
      );
      return;
    }

    try {
      // Tell Firebase to send a password reset email to the given address.
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A password reset link has been sent to your email.')),
      );
    } on FirebaseAuthException catch (e) {
      // Handle errors, e.g., if the user doesn't exist.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'An error occurred.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Email TextField
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || !value.contains('@')) {
                      return 'Please enter a valid email.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12.0),
                // Password TextField
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true, // Hides the password text.
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                // Forgot Password Button (Correct Placement)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _forgotPassword,
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: 12.0),
                // Show a loading indicator if an action is in progress.
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  // Login and Sign Up Buttons
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _login,
                        child: const Text('Login'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: _signUp,
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                
                // Display an error message if one exists.
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}