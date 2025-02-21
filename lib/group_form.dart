import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupsForm extends StatefulWidget {
  const GroupsForm({super.key});

  @override
  GroupsFormState createState() => GroupsFormState();
}

class GroupsFormState extends State<GroupsForm> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController partController = TextEditingController();
  final CollectionReference groups =
      FirebaseFirestore.instance.collection('groups');

  void addGroup() async {
    try {
      await groups.add({
        'groupName': groupNameController.text,
        'part': int.parse(partController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group added successfully!')),
        );
        groupNameController.clear();
        partController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void updateGroup(String id) async {
    try {
      await groups.doc(id).update({
        'groupName': groupNameController.text,
        'part': int.parse(partController.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void deleteGroup(String id) async {
    try {
      await groups.doc(id).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Group deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void showEditDialog(String id, String currentGroupName, int currentPart) {
    groupNameController.text = currentGroupName;
    partController.text = currentPart.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Group"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(labelText: "Group Name"),
            ),
            TextField(
              controller: partController,
              decoration: const InputDecoration(labelText: "Part Number"),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              updateGroup(id);
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: groupNameController,
              decoration: const InputDecoration(labelText: "Group Name"),
            ),
            TextField(
              controller: partController,
              decoration: const InputDecoration(labelText: "Part"),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: addGroup,
              child: const Text("Add Group"),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: groups.snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index];
                      return ListTile(
                        title: Text(data['groupName']),
                        subtitle: Text('Part: ${data['part']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                showEditDialog(
                                  data.id,
                                  data['groupName'],
                                  data['part'],
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => deleteGroup(data.id),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
