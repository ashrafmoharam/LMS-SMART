// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';
import 'Quiz_Results_Page.dart';
import 'create_quiz_page.dart';


class QuizzesTab extends StatefulWidget {
  final String courseId;
  const QuizzesTab({super.key, required this.courseId});

  @override
  State<QuizzesTab> createState() => _QuizzesTabState();
}

class _QuizzesTabState extends State<QuizzesTab> {
  List<dynamic> quizzes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchQuizzes();
  }

  void fetchQuizzes() async {
    setState(() => isLoading = true);
    quizzes = await ApiService.getCourseQuizzes(widget.courseId);
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
              MaterialPageRoute(builder: (_) => CreateQuizPage(courseId: widget.courseId)),
            ).then((_) => fetchQuizzes());
          },
          child: const Text('Create Quiz'),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: quizzes.length,
                  itemBuilder: (context, index) {
                    final quiz = quizzes[index];
                    return ListTile(
                      title: Text(quiz['title']),
                      subtitle: Text('Points: ${quiz['points']}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.bar_chart),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => QuizResultsPage(quizId: quiz['id'].toString())),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
