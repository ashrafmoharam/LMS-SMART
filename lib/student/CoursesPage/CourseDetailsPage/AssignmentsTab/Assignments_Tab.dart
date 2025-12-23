// ignore_for_file: file_names, avoid_web_libraries_in_flutter
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:smartlearn_lms/student/CoursesPage/CourseDetailsPage/AssignmentsTab/upload_assignment_page.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import '../../../../core/api_service.dart';
// صفحة رفع الحل

class AssignmentsTab extends StatefulWidget {
  final String courseId;
  final String studentId;

  const AssignmentsTab({super.key, required this.courseId, required this.studentId});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  List<dynamic> assignments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssignments();
  }

  void fetchAssignments() async {
    setState(() => isLoading = true);
    assignments = await ApiService.getCourseAssignments(widget.courseId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (assignments.isEmpty) return const Center(child: Text('No assignments yet.'));

    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        final fileUrl = assignment['file_url'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          child: ListTile(
            title: Text(assignment['title'] ?? 'Untitled Assignment'),
            subtitle: Text(
              'Due: ${assignment['due_date'] ?? 'Not set'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // زر عرض الواجب
                IconButton(
                  icon: const Icon(Icons.picture_as_pdf),
                  tooltip: 'View Assignment',
                  onPressed: () {
                    if (fileUrl.isNotEmpty && kIsWeb) {
                      html.window.open(fileUrl, '_blank');
                    } else if (fileUrl.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No PDF available')),
                      );
                    }
                  },
                ),
                const SizedBox(width: 8),
                // زر رفع الحل
                IconButton(
                  icon: const Icon(Icons.upload_file),
                  tooltip: 'Submit Solution',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => UploadAssignmentPage(
                          courseId: widget.courseId,
                          assignmentId: assignment['id'].toString(),
                          studentId: widget.studentId,
                        ),
                      ),
                    ).then((_) => fetchAssignments());
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
