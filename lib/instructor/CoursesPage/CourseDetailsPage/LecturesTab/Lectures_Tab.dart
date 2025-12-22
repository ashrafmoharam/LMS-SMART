// ignore_for_file: file_names
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: deprecated_member_use
import 'dart:html' as html;
import '../../../../core/api_service.dart';
import 'upload_lecture_page.dart';

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
    return Column(
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => UploadLecturePage(courseId: widget.courseId)),
            ).then((_) => fetchLectures());
          },
          child: const Text('Upload Lecture'),
        ),
        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: lectures.length,
                  itemBuilder: (context, index) {
                    final lecture = lectures[index];
                    final fileUrl = lecture['file_url'] ?? '';
                    return ListTile(
                      title: Text(lecture['title']),
                      subtitle: Text(lecture['description'] ?? ''),
                      trailing: IconButton(
                        icon: const Icon(Icons.picture_as_pdf),
                        onPressed: () {
                          if (kIsWeb) {
                            html.window.open(fileUrl, '_blank');
                          }
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
