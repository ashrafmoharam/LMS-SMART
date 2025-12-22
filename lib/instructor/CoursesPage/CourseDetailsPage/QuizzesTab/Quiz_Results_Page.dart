// quiz_results_page.dart
import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';


class QuizResultsPage extends StatefulWidget {
  final String quizId;
  const QuizResultsPage({super.key, required this.quizId});

  @override
  State<QuizResultsPage> createState() => _QuizResultsPageState();
}

class _QuizResultsPageState extends State<QuizResultsPage> {
  List<dynamic> results = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchResults();
  }

  void fetchResults() async {
    setState(() => isLoading = true);
    results = await ApiService.getQuizResults(widget.quizId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                final r = results[index];
                return ListTile(
                  title: Text(r['student_name']),
                  subtitle: Text('Score: ${r['score']}/${r['total_points']}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_red_eye),
                    onPressed: () {
                      // عرض التفاصيل إذا لزم
                    },
                  ),
                );
              },
            ),
    );
  }
}
