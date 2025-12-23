// ignore_for_file: file_names, deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';

class QuizPage extends StatefulWidget {
  final String quizId;
  final String studentId;

  const QuizPage({
    super.key,
    required this.quizId,
    required this.studentId,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<dynamic> questions = [];
  Map<int, String> selectedAnswers = {}; // question_id -> A/B/C/D
  bool isLoading = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    if (!mounted) return;

    setState(() => isLoading = true);

    try {
      final result = await ApiService.getQuizQuestions(widget.quizId);
      if (!mounted) return;

      setState(() => questions = result);
    } catch (e) {
      debugPrint('fetchQuestions error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
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

    if (!mounted) return;

    setState(() => isSubmitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Quiz submitted successfully' : 'Submission failed',
        ),
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('No questions available')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz')),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          final int qId = int.parse(q['id'].toString());
          final Map<String, dynamic> options = q['options'];

          return Card(
            margin: const EdgeInsets.all(8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Q${index + 1}: ${q['question_text']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...options.entries.map((entry) {
                    final optionKey = entry.key; // A / B / C / D
                    final optionValue = entry.value.toString();

                    return RadioListTile<String>(
                      title: Text(optionValue),
                      value: optionKey,
                      groupValue: selectedAnswers[qId],
                      onChanged: (val) {
                        setState(() {
                          selectedAnswers[qId] = val!;
                        });
                      },
                    );
                  }),
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
