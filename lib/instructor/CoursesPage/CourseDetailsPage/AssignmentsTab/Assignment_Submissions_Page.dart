// ignore_for_file: file_names, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/api_service.dart';

class AssignmentSubmissionsPage extends StatefulWidget {
  final String assignmentId;
  final String? dueDate;
  const AssignmentSubmissionsPage({super.key, required this.assignmentId, this.dueDate});

  @override
  State<AssignmentSubmissionsPage> createState() => _AssignmentSubmissionsPageState();
}

class _AssignmentSubmissionsPageState extends State<AssignmentSubmissionsPage> {
  List<dynamic> submissions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  void fetchSubmissions() async {
    setState(() => isLoading = true);
    submissions = await ApiService.getAssignmentSubmissions(widget.assignmentId);
    setState(() => isLoading = false);
  }

  bool isLate(String? submissionDate) {
    if (submissionDate == null || widget.dueDate == null) return false;
    try {
      DateTime sub = DateTime.parse(submissionDate);
      DateTime due = DateTime.parse(widget.dueDate!);
      return sub.isAfter(due);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Submissions')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : submissions.isEmpty
              ? const Center(child: Text('No submissions yet'))
              : ListView.builder(
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    final late = isLate(sub['submitted_at']);

                    // تجهيز التاريخ والوقت للعرض
                    String submittedStr = 'Not available';
                    if (sub['submitted_at'] != null) {
                      try {
                        DateTime dt = DateTime.parse(sub['submitted_at']);
                        submittedStr =
                            '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
                            '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
                      } catch (_) {}
                    }

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      elevation: 2,
                      child: ListTile(
                        title: Text(sub['student_name']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sub['university_email'],
                              style: TextStyle(color: late ? Colors.red : Colors.black),
                            ),
                            Text('Submitted: $submittedStr'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.picture_as_pdf),
                          tooltip: 'View PDF',
                          onPressed: () async {
                            final url = 'http://localhost/SmartLearn_LMS/uploads/assignment_submissions/${sub['submission_file']}';
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cannot open PDF')),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
