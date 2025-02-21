import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_information_form.dart';
import 'group_form.dart';
import 'course_form.dart';
import 'product_form.dart';
import 'transaction_form.dart';
import 'google_auth_service.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final GoogleAuthService _googleAuthService = GoogleAuthService();

  // Sign out method
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate to the login page or home page after sign out
    } catch (e) {
      // Handle error (you can log it or show a message)
      // Optionally, use logger here if needed
    }
  }

  // Handle Google Sign-In and store user data in Firestore
  Future<void> signInWithGoogle() async {
    final user = await _googleAuthService.signInWithGoogle();
    if (user != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        // Store user information if not already stored
        await userRef.set({
          'name': user.displayName,
          'email': user.email,
          'isAdmin': false, // Set user as non-admin by default
        });
      }
    } else {
      // Handle Google sign-in failure (if any)
      // Optionally, show an error or try again prompt
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Welcome to the App!",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.count(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  _buildGridCard(
                    "User Info",
                    Colors.deepPurple.shade200,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserInformationForm(
                          emailController: TextEditingController(),
                          roleController: TextEditingController(),
                        ),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Courses",
                    Colors.green.shade200,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Groups",
                    Colors.blue.shade200,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupsForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Products",
                    Colors.orange.shade200,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Transactions",
                    Colors.red.shade200,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionForm(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: signOut,
        backgroundColor: Colors.red,
        tooltip: "Sign Out",
        child: const Icon(Icons.logout, color: Colors.white),
      ),
    );
  }

  Widget _buildGridCard(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        width: 60,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
