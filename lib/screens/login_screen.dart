import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../google_auth_service.dart';
import '../home_page.dart'; // If it's one level up
import 'package:logger/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final GoogleAuthService _authService = GoogleAuthService();
  final Logger _logger = Logger();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Google Sign-In")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                User? user = await _authService.signInWithGoogle();
                if (user != null) {
                  _logger.i("Logged in as ${user.displayName}");
                  // Ensure the user is fully authenticated
                  if (FirebaseAuth.instance.currentUser != null) {
                    _logger.i("User is authenticated, navigating to HomePage");
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    }
                  } else {
                    _logger.e("Authentication failed or user is null");
                    // Optionally show a dialog or an error message if authentication fails
                  }
                } else {
                  _logger.e("Google sign-in failed");
                  // Optionally show a failure message or a retry button
                }
              },
              child: const Text("Sign in with Google"),
            ),
          ],
        ),
      ),
    );
  }
}
