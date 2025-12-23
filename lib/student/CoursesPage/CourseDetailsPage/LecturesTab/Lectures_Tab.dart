// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import '../../../../core/api_service.dart';

class LecturesTab extends StatefulWidget {
  final String courseId;
  const LecturesTab({super.key, required this.courseId});

  @override
  State<LecturesTab> createState() => _LecturesTabState();
}

class _LecturesTabState extends State<LecturesTab> {
  List<dynamic> lectures = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLectures();
  }

  void fetchLectures() async {
    setState(() => isLoading = true);
    lectures = await ApiService.getCourseLectures(widget.courseId);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (lectures.isEmpty) return const Center(child: Text('No lectures yet.'));

    return ListView.builder(
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final lecture = lectures[index];
        final fileUrl = lecture['file_url'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          elevation: 2,
          child: ListTile(
            title: Text(lecture['title'] ?? 'Untitled Lecture'),
            subtitle: Text(lecture['description'] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              tooltip: 'View PDF',
              onPressed: () {
                if (fileUrl.isNotEmpty && kIsWeb) {
                  html.window.open(fileUrl, '_blank');
                } else if (fileUrl.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No PDF available')),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}
