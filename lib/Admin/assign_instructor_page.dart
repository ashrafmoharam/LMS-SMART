import 'package:flutter/material.dart';
import '../core/api_service.dart';

class AssignInstructorPage extends StatefulWidget {
  const AssignInstructorPage({super.key});

  @override
  State<AssignInstructorPage> createState() => _AssignInstructorPageState();
}

class _AssignInstructorPageState extends State<AssignInstructorPage> {
  List instructors = [];
  List courses = [];

  String? selectedInstructorId;
  String? selectedCourseId;
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    instructors = await ApiService.getAllInstructors();
    courses = await ApiService.getAllCourses();


    setState(() => loading = false);
  }

  Future<void> assignInstructor() async {
    if (selectedInstructorId == null || selectedCourseId == null) return;
    setState(() => submitting = true);
    final result = await ApiService.assignInstructorToCourse(
        selectedInstructorId!, selectedCourseId!);
    setState(() => submitting = false);

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? 'Instructor Assigned'),
        backgroundColor:
            result['status'] == 'success' ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assign Instructor')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Instructor'),
                    items: instructors
                        .map((i) => DropdownMenuItem(
                              value: i['id'].toString(),
                              child: Text(i['full_name'] ?? 'Unknown'),
                            ))
                        .toList(),
                    // ignore: deprecated_member_use
                    value: selectedInstructorId,
                    onChanged: (val) => setState(() => selectedInstructorId = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Select Course'),
                    items: courses
                        .map((c) => DropdownMenuItem(
                              value: c['id'].toString(),
                              child: Text(c['title']),
                            ))
                        .toList(),
                    // ignore: deprecated_member_use
                    value: selectedCourseId,
                    onChanged: (val) => setState(() => selectedCourseId = val),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: submitting ? null : assignInstructor,
                    child: submitting
                        ? const CircularProgressIndicator(
                            color: Colors.white)
                        : const Text('Assign'),
                  ),
                ],
              ),
            ),
    );
  }
}
