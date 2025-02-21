import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_information_form.dart';

class ManageUserAccountsPage extends StatefulWidget {
  const ManageUserAccountsPage({super.key});

  @override
  ManageUserAccountsPageState createState() => ManageUserAccountsPageState();
}

class ManageUserAccountsPageState extends State<ManageUserAccountsPage> {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  void deleteUser(String userId) async {
    try {
      await users.doc(userId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: $e')),
        );
      }
    }
  }

  void showUpdateDialog(
      String userId, String currentEmail, String currentRole) {
    final TextEditingController emailController =
        TextEditingController(text: currentEmail);
    final TextEditingController roleController =
        TextEditingController(text: currentRole);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update User'),
          content: UserInformationForm(
            emailController: emailController,
            roleController: roleController,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                updateUser(userId, emailController.text, roleController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void updateUser(String userId, String email, String role) async {
    try {
      await users.doc(userId).update({
        'email': email,
        'role': role,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update user: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage User Accounts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No users found'),
            );
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.docs.length,
            itemBuilder: (context, index) {
              final user = data.docs[index];
              return ListTile(
                title: Text(user['email'] ?? 'No Email'),
                subtitle: Text(user['role'] ?? 'No Role'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        showUpdateDialog(user.id, user['email'], user['role']);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => deleteUser(user.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
