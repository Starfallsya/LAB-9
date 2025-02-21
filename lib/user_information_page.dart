import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';
import 'user_information_form.dart';
import 'course_form.dart';
import 'group_form.dart';
import 'product_form.dart';
import 'transaction_form.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (e) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: e,
        library: 'app',
        context: DiagnosticsNode.message('Error during sign-out'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Home Page"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: signOut,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Welcome to the App!",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _buildGridCard(
                    "User Info Form",
                    Colors.purple.shade100,
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
                    "User Info Page",
                    Colors.indigo.shade100,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const UserInformationDisplayPage(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Courses",
                    Colors.green.shade100,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CourseForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Groups",
                    Colors.blue.shade100,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GroupsForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Products",
                    Colors.orange.shade100,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Transactions",
                    Colors.red.shade100,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TransactionForm(),
                      ),
                    ),
                  ),
                  _buildGridCard(
                    "Sign Out",
                    Colors.grey.shade300,
                    signOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(String title, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: color,
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
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

class UserInformationDisplayPage extends StatefulWidget {
  const UserInformationDisplayPage({super.key});

  @override
  UserInformationDisplayPageState createState() =>
      UserInformationDisplayPageState();
}

class UserInformationDisplayPageState
    extends State<UserInformationDisplayPage> {
  // _getUserData method that fetches user data from Firestore
  Future<Map<String, dynamic>> _getUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final users = FirebaseFirestore.instance.collection('users');
      final userSnapshot = await users
          .doc(currentUser.uid)
          .get(); // Use UID for fetching user data

      if (userSnapshot.exists) {
        return userSnapshot.data()!;
      }
    }
    // Return a default value or redirect to a form if data is not found
    throw Exception("User data not found");
  }

  // This method checks if the current user is an admin
  Future<bool> _isUserAdmin() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      return userDoc['isAdmin'] ?? false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("User Information"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }

            if (!snapshot.hasData) {
              return const Center(
                child: Text('No user information available.'),
              );
            }

            final userData = snapshot.data!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "Name: ${userData['name'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 10),
                Text(
                  "Email: ${userData['email'] ?? 'N/A'}",
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _handleEditUserInfo(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 202, 185, 231),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Edit Information"),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _handleDeleteUser(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 196, 133, 132),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Delete User"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _handleEditUserInfo() async {
    final isAdmin = await _isUserAdmin();

    if (!mounted) {
      return; // Ensure the widget is still in the tree before accessing context.
    }

    if (isAdmin) {
      if (!mounted) return; // Double-check before accessing context.
      Navigator.pushNamed(context, '/editUserInfo');
    } else {
      if (!mounted) return; // Double-check before showing the Snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You do not have permission to edit user information."),
        ),
      );
    }
  }

  void _handleDeleteUser() async {
    final isAdmin = await _isUserAdmin();

    if (!mounted) {
      return; // Ensure the widget is still in the tree before accessing context.
    }

    if (isAdmin) {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        final users = FirebaseFirestore.instance.collection('users');
        await users.doc(currentUser.uid).delete();

        if (!mounted) return; // Double-check before accessing context.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User deleted successfully.")),
        );

        if (!mounted) return; // Double-check before accessing context.
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      if (!mounted) return; // Double-check before showing the Snackbar.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You do not have permission to delete user."),
        ),
      );
    }
  }
}
