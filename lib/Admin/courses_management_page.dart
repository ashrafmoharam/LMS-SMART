import 'package:flutter/material.dart';
import '../core/api_service.dart';

class CoursesManagementPage extends StatefulWidget {
  const CoursesManagementPage({super.key});

  @override
  State<CoursesManagementPage> createState() =>
      _CoursesManagementPageState();
}

class _CoursesManagementPageState extends State<CoursesManagementPage> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Course')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Course Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await ApiService.addCourse(
                  titleController.text,
                  descController.text,
                );
                // ignore: use_build_context_synchronously
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Course Added')),
                );
              },
              child: const Text('Add Course'),
            ),
          ],
        ),
      ),
    );
  }
}
