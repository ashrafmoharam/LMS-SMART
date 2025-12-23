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

  Future<void> loadGrades() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final data =
          await ApiService.getStudentQuizGrades(widget.studentId);

      if (!mounted) return;

      setState(() {
        grades = data;
      });
    } catch (e) {
      debugPrint('loadGrades error: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (grades.isEmpty) {
      return const Center(child: Text('No quiz grades yet.'));
    }

    return ListView.builder(
      itemCount: grades.length,
      itemBuilder: (context, index) {
        final grade = grades[index];

        String submittedAt = 'Not available';
        if (grade['submitted_at'] != null) {
          try {
            final dt = DateTime.parse(grade['submitted_at']);
            submittedAt =
                '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
                '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
          } catch (_) {}
        }

        final score = grade['score'] ?? 0;
        final total = grade['total_marks'] ?? 0;
        final percentage = grade['percentage'] ?? 0;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(
              grade['quiz_title'] ?? 'Unknown Quiz',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Score: $score / $total'),
                Text('Percentage: $percentage%'),
                Text('Submitted at: $submittedAt'),
              ],
            ),
          ),
        );
      },
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
