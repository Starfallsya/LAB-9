import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file exists
import 'login_page.dart'; // Ensure LoginPage exists

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required before async calls in main()

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform, // Ensure firebase_options.dart exists
    );
    debugPrint('✅ Firebase initialized successfully');
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase initialization failed: $e');
    debugPrint('Stack trace: $stackTrace');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Removes debug banner
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(), // Ensure LoginPage exists
    );
  }
}
