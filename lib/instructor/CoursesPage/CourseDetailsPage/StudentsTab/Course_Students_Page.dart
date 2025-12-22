import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';

class CourseStudentsPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseStudentsPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseStudentsPage> createState() => _CourseStudentsPageState();
}

class _CourseStudentsPageState extends State<CourseStudentsPage> {
  List<dynamic> students = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final fetchedStudents = await ApiService.getCourseStudents(widget.courseId);
      setState(() => students = fetchedStudents);
    } catch (e) {
      setState(() => errorMessage = 'Failed to load students: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (students.isEmpty) {
      return const Center(child: Text('No students enrolled yet'));
    }

    return RefreshIndicator(
      onRefresh: fetchStudents,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Total Students: ${students.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: students.length,
              itemBuilder: (context, index) {
                final student = students[index];
                final fullName = student['full_name'] ?? 'Student';
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        fullName.isNotEmpty ? fullName[0].toUpperCase() : '?',
                      ),
                    ),
                    title: Text(
                      fullName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      student['university_email'] ??
                          student['personal_email'] ??
                          '',
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
