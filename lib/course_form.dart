import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseForm extends StatefulWidget {
  const CourseForm({super.key});

  @override
  CourseFormState createState() => CourseFormState();
}

class CourseFormState extends State<CourseForm> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController dayController = TextEditingController();
  final TextEditingController lecturerController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final Map<String, bool> selectedCourses = {};

  final CollectionReference courses =
      FirebaseFirestore.instance.collection('courses');

  void addCourse() async {
    try {
      await courses.add({
        'Day': dayController.text,
        'Lecturer name': lecturerController.text,
        'Time': Timestamp.now(),
        'Title': titleController.text,
        'Deleted': false, // Add a field to mark as deleted, soft delete flag
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course added successfully!')),
        );
        dayController.clear();
        lecturerController.clear();
        timeController.clear();
        titleController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add course: $e')),
        );
      }
    }
  }

  void deleteCourse(String courseId) async {
    try {
      await courses.doc(courseId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete course: $e')),
        );
      }
    }
  }

  void softDeleteCourse(String courseId) async {
    try {
      await courses.doc(courseId).update({'Deleted': true});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course hidden successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to hide course: $e')),
        );
      }
    }
  }

  void softDeleteMultipleCourses() async {
    try {
      for (var courseId in selectedCourses.keys) {
        if (selectedCourses[courseId] == true) {
          await courses.doc(courseId).update({'Deleted': true});
        }
      }
      setState(() {
        selectedCourses.clear(); // Clear selection after deletion
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Selected courses hidden successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to hide selected courses: $e')),
        );
      }
    }
  }

  void markCourseAsDeleted(String courseId) async {
    try {
      await courses.doc(courseId).update({'Deleted': true});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course marked as deleted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark course as deleted: $e')),
        );
      }
    }
  }

  void updateCourse(String courseId) async {
    try {
      await courses.doc(courseId).update({
        'Day': dayController.text,
        'Lecturer name': lecturerController.text,
        'Time': Timestamp.now(),
        'Title': titleController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course updated successfully!')),
        );
        dayController.clear();
        lecturerController.clear();
        timeController.clear();
        titleController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update course: $e')),
        );
      }
    }
  }

  void showDeleteConfirmationDialog(String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this course?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteCourse(courseId);
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void showUpdateDialog(String courseId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: dayController,
                decoration: const InputDecoration(labelText: 'Day'),
              ),
              TextField(
                controller: lecturerController,
                decoration: const InputDecoration(labelText: 'Lecturer Name'),
              ),
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Time'),
              ),
            ],
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
                updateCourse(courseId);
                Navigator.of(context).pop();
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Course Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: dayController,
              decoration: const InputDecoration(labelText: 'Day'),
            ),
            TextField(
              controller: lecturerController,
              decoration: const InputDecoration(labelText: 'Lecturer Name'),
            ),
            TextField(
              controller: timeController,
              decoration: const InputDecoration(labelText: 'Time'),
            ),
            ElevatedButton(
              onPressed: addCourse,
              child: const Text('Add Course'),
            ),
            const SizedBox(height: 16), // Add space between the buttons

            // ✅ Add this Delete Selected button here
            ElevatedButton(
              onPressed: selectedCourses.containsValue(true)
                  ? softDeleteMultipleCourses
                  : null, // Disable if nothing is selected
              child: const Text('Delete Selected'),
            ),

            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: courses.where('Deleted', isEqualTo: false).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final data = snapshot.data!;
                  return ListView.builder(
                    itemCount: data.docs.length,
                    itemBuilder: (context, index) {
                      final course = data.docs[index];
                      return ListTile(
                        leading: Checkbox(
                          value: selectedCourses[course.id] ?? false,
                          onChanged: (bool? value) {
                            setState(() {
                              selectedCourses[course.id] = value ?? false;
                            });
                          },
                        ),
                        title: Text(course['Title']),
                        subtitle: Text(course['Lecturer name']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                titleController.text = course['Title'];
                                dayController.text = course['Day'];
                                lecturerController.text =
                                    course['Lecturer name'];
                                timeController.text =
                                    course['Time'].toDate().toString();
                                showUpdateDialog(course.id);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  showDeleteConfirmationDialog(course.id),
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
