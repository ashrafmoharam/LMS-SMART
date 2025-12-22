// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';
import 'Upload_Assignment_Page.dart';
import 'Assignment_Submissions_Page.dart';

class AssignmentsTab extends StatefulWidget {
  final String courseId;
  const AssignmentsTab({super.key, required this.courseId});

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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      UploadAssignmentPage(courseId: widget.courseId)),
            ).then((_) => fetchAssignments());
          },
          child: const Text('Upload Assignment'),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = assignments[index];

                    // التأكد من due_date
                    String dueDateStr = 'Not set';
                    if (assignment['due_date'] != null) {
                      try {
                        DateTime dt = DateTime.parse(assignment['due_date']);
                        dueDateStr =
                            '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
                            '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
                      } catch (_) {}
                    }

                    return Card(
                      margin:
                          const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      elevation: 2,
                      child: ListTile(
                        title: Text(assignment['title']),
                        subtitle: Text(
                          'Due: $dueDateStr',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.folder_open),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AssignmentSubmissionsPage(
                                    assignmentId: assignment['id'].toString()),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
