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

    // جلب نتائج جميع الطلاب للكويز
    results = await ApiService.getQuizResults(widget.quizId);

    setState(() => isLoading = false);
  }

  String formatDate(String? dateStr) {
    if (dateStr == null) return 'Not submitted';
    try {
      DateTime dt = DateTime.parse(dateStr);
      return '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
          '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
    } catch (_) {
      return 'Invalid date';
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Results')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : results.isEmpty
              ? const Center(child: Text('No results yet'))
              : ListView.builder(
                  itemCount: results.length,
                  itemBuilder: (context, index) {
                    final r = results[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                      elevation: 2,
                      child: ListTile(
                        title: Text(r['student_name'] ?? 'Unnamed'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('University Email: ${r['university_email'] ?? 'N/A'}'),
                            Text('Score: ${r['score']}/${r['total_points']}'),
                            Text('Submitted at: ${formatDate(r['submitted_at'])}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_red_eye),
                          tooltip: 'View Answers',
                          onPressed: () {
                            // هنا يمكن فتح صفحة تفاصيل إجابات الطالب
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
