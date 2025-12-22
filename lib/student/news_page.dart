// ignore_for_file: file_names

import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';

class NewsPage extends StatefulWidget {
  final String studentId;

  const NewsPage({super.key, required this.studentId});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List news = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  void fetchNews() async {
    setState(() => loading = true);
    // جلب كل الأخبار لجميع المعلمين
    news = await ApiService.getAllNews(); 
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (news.isEmpty) return const Center(child: Text('No news found'));

    return ListView.builder(
      itemCount: news.length,
      itemBuilder: (_, index) {
        final item = news[index];
        String dateStr = '';
        if (item['created_at'] != null) {
          try {
            DateTime dt = DateTime.parse(item['created_at']);
            dateStr = '${dt.year}-${_twoDigits(dt.month)}-${_twoDigits(dt.day)} '
                      '${_twoDigits(dt.hour)}:${_twoDigits(dt.minute)}';
          } catch (_) {}
        }
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            title: Text(item['title'] ?? ''),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['content'] ?? ''),
                const SizedBox(height: 4),
                Text(
                  'By: ${item['instructor_name'] ?? 'Unknown'} | $dateStr',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');
}
