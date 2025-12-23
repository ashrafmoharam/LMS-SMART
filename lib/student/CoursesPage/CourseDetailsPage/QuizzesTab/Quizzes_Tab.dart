// ignore_for_file: file_names, prefer_if_null_operators
import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';
import 'quiz_page.dart'; // صفحة إجراء الاختبار

class QuizzesTab extends StatefulWidget {
  final String courseId;
  final String studentId;

  const QuizzesTab({super.key, required this.courseId, required this.studentId});

  @override
  State<QuizzesTab> createState() => _QuizzesTabState();
}

class _QuizzesTabState extends State<QuizzesTab> {
  List<dynamic> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  void loadQuizzes() async {
    setState(() => isLoading = true);
    quizzes = await ApiService.getCourseQuizzes(widget.courseId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (quizzes.isEmpty) return const Center(child: Text('No quizzes yet.'));

    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        final dueDateStr = quiz['due_date'] != null ? quiz['due_date'] : 'Not set';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          elevation: 2,
          child: ListTile(
            title: Text(quiz['title']),
            subtitle: Text('Due: $dueDateStr'),
            trailing: ElevatedButton(
              child: const Text('Take Quiz'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QuizPage(
                      quizId: quiz['id'].toString(),
                      studentId: widget.studentId,
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
