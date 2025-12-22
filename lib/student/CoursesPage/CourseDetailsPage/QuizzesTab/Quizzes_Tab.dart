import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';


class QuizzesTab extends StatefulWidget {
  final String courseId;
  final String studentId;

  const QuizzesTab({super.key, required this.courseId, required this.studentId});

  @override
  State<QuizzesTab> createState() => _QuizzesTabState();
}

class _QuizzesTabState extends State<QuizzesTab> {
  List<dynamic> quizzes = [];

  @override
  void initState() {
    super.initState();
    loadQuizzes();
  }

  void loadQuizzes() async {
    final data = await ApiService.getCourseQuizzes(widget.courseId);
    setState(() => quizzes = data);
  }

  @override
  Widget build(BuildContext context) {
    if (quizzes.isEmpty) return const Center(child: Text('No quizzes yet.'));
    return ListView.builder(
      itemCount: quizzes.length,
      itemBuilder: (context, index) {
        final quiz = quizzes[index];
        return ListTile(
          title: Text(quiz['title']),
          onTap: () {
            // فتح صفحة إجراء الكويز
          },
        );
      },
    );
  }
}
