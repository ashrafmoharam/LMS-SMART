import 'package:flutter/material.dart';
import '../core/api_service.dart';

class GradesPage extends StatefulWidget {
  final String studentId;

  const GradesPage({super.key, required this.studentId});

  @override
  State<GradesPage> createState() => _GradesPageState();
}

class _GradesPageState extends State<GradesPage> {
  List<dynamic> grades = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadGrades();
  }

  void loadGrades() async {
    setState(() => isLoading = true);
    final data = await ApiService.getStudentQuizGrades(widget.studentId);
    setState(() {
      grades = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (grades.isEmpty) return const Center(child: Text('No quiz grades yet.'));

    return ListView.builder(
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];
        String submittedAt = 'Not available';
        if (grade['submitted_at'] != null) {
          try {
            DateTime dt = DateTime.parse(grade['submitted_at']);
            submittedAt =
                '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
                '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
          } catch (_) {}
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(grade['quiz_title'] ?? 'Unknown Quiz'), // هنا اسم الكويز
            subtitle: Text('Submitted at: $submittedAt'),
            trailing: Text('${grade['score'] ?? 0}'),
          ),
        );
      },
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
