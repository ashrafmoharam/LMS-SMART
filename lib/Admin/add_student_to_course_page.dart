// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../core/api_service.dart';

class AddStudentToCoursePage extends StatefulWidget {
  const AddStudentToCoursePage({super.key});

  @override
  State<AddStudentToCoursePage> createState() => _AddStudentToCoursePageState();
}

class _AddStudentToCoursePageState extends State<AddStudentToCoursePage> {
  List students = [];
  List courses = [];

  String? selectedStudentId;
  String? selectedCourseId;
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    students = await ApiService.getAllStudents();
    courses = await ApiService.getAllCourses();

    

    setState(() => loading = false);
  }

  Future<void> addStudentToCourse() async {
    if (selectedStudentId == null || selectedCourseId == null) return;

    setState(() => submitting = true);
    final result = await ApiService.addStudentToCourse(
        selectedStudentId!, selectedCourseId!);
    setState(() => submitting = false);

    // عرض رسالة النجاح أو الخطأ
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Student Added'),
        backgroundColor:
            result['status'] == 'success' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Student to Course')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Student'),
                    items: students
                        .map((s) => DropdownMenuItem(
                              value: s['id'].toString(),
                              child: Text(s['full_name'] ?? 'Unknown'),
                            ))
                        .toList(),
                    // ignore: deprecated_member_use
                    value: selectedStudentId,
                    onChanged: (val) => setState(() => selectedStudentId = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Course'),
                    items: courses
                        .map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['title'] ?? 'Unknown'),
                            ))
                        .toList(),
                    // ignore: deprecated_member_use
                    value: selectedCourseId,
                    onChanged: (val) => setState(() => selectedCourseId = val),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submitting ? null : addStudentToCourse,
                    child: submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Add'),
                  ),
                ],
              ),
            ),
    );
  }
}
