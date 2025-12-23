// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String studentId;

  const QuizPage({super.key, required this.quizId, required this.studentId});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> questions = [];
  Map<int, String> selectedAnswers = {}; // quiz_question_id -> selected_option
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  void fetchQuestions() async {
    setState(() => isLoading = true);
    questions = await ApiService.getQuizQuestions(widget.quizId);
    setState(() => isLoading = false);
  }

  void submitQuiz() async {
    if (selectedAnswers.length != questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer all questions')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    final success = await ApiService.submitQuiz(
      quizId: widget.quizId,
      studentId: widget.studentId,
      answers: selectedAnswers,
    );

    setState(() => isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? 'Quiz submitted successfully' : 'Submission failed')),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (questions.isEmpty) return const Center(child: Text('No questions available'));

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          final qId = q['id'];
          final options = q['options'] as List<dynamic>;

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Q${index + 1}: ${q['question']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ...options.map((opt) {
                    final optStr = opt.toString();
                    return RadioListTile<String>(
                      title: Text(optStr),
                      value: optStr,
                      groupValue: selectedAnswers[qId],
                      onChanged: (val) {
                        setState(() => selectedAnswers[qId] = val!);
                      },
                    );
                  // ignore: unnecessary_to_list_in_spreads
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: isSubmitting ? null : submitQuiz,
          child: isSubmitting
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Submit Quiz'),
        ),
      ),
    );
  }
}
