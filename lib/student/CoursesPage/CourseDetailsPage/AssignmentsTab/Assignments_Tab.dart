import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';


class AssignmentsTab extends StatefulWidget {
  final String courseId;
  final String studentId;

  const AssignmentsTab({super.key, required this.courseId, required this.studentId});

  @override
  State<AssignmentsTab> createState() => _AssignmentsTabState();
}

class _AssignmentsTabState extends State<AssignmentsTab> {
  List<dynamic> assignments = [];

  @override
  void initState() {
    super.initState();
    loadAssignments();
  }

  void loadAssignments() async {
    final data = await ApiService.getCourseAssignments(widget.courseId);
    setState(() => assignments = data);
  }

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) return const Center(child: Text('No assignments yet.'));
    return ListView.builder(
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        final assignment = assignments[index];
        return ListTile(
          title: Text(assignment['title']),
          onTap: () {
            // فتح صفحة رفع الحل PDF
          },
        );
      },
    );
  }
}
