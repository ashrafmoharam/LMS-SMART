// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import '../../../../core/api_service.dart';
import 'dart:html' as html; // فقط للويب

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
    loadLectures();
  }

  void loadLectures() async {
    setState(() => isLoading = true);
    lectures = await ApiService.getCourseLectures(widget.courseId);
    setState(() => isLoading = false);
  }

  void openPDF(String fileName) {
    final url = 'http://10.0.2.2/SmartLearn_LMS/uploads/lectures/$fileName';
    
    if (kIsWeb) {
      // فتح PDF في نافذة جديدة على Web
      html.window.open(url, '_blank');
    } else {
      // فتح PDF داخل التطبيق على Mobile باستخدام pdfx
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PDFViewerPage(url: url)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (lectures.isEmpty) return const Center(child: Text('No lectures yet.'));

    return ListView.builder(
      itemCount: lectures.length,
      itemBuilder: (context, index) {
        final lecture = lectures[index];
        final pdfFile = lecture['pdf_file'];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(lecture['title'] ?? 'Untitled'),
            trailing: IconButton(
              icon: const Icon(Icons.picture_as_pdf),
              onPressed: () {
                if (pdfFile != null && pdfFile.isNotEmpty) {
                  openPDF(pdfFile);
                } else {
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

// ================= PDF Viewer Page (Mobile فقط) =================
class PDFViewerPage extends StatelessWidget {
  final String url;
  const PDFViewerPage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Viewer')),
      body: PdfView(
        controller: PdfController(
          document: PdfDocument.openAsset(url), // استخدم openAsset بدل openUrl
        ),
      ),
    );
  }
}
