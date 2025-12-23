// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/api_service.dart';

class UploadAssignmentPage extends StatefulWidget {
  final String courseId;
  final String assignmentId;
  final String studentId;

  const UploadAssignmentPage({
    super.key,
    required this.courseId,
    required this.assignmentId,
    required this.studentId,
  });

  @override
  State<UploadAssignmentPage> createState() => _UploadAssignmentPageState();
}

class _UploadAssignmentPageState extends State<UploadAssignmentPage> {
  FilePickerResult? pickedFile;
  bool isUploading = false;

  void pickFile() async {
    pickedFile = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    setState(() {});
  }

  void uploadFile() async {
    if (pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file first')),
      );
      return;
    }

    setState(() => isUploading = true);

    // إرسال الملف للـ API
    final success = await ApiService.AssignmentSubmissions(
      courseId: widget.courseId,
      assignmentId: widget.assignmentId,
      studentId: widget.studentId,
      file: kIsWeb
          ? pickedFile!.files.first.bytes
          : File(pickedFile!.files.first.path!),
      fileName: pickedFile!.files.first.name,
    );

    setState(() => isUploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'File uploaded successfully' : 'Upload failed'),
      ),
    );

    if (success) {
      Navigator.pop(context); // العودة للقائمة بعد الرفع
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Select PDF File'),
            ),
            const SizedBox(height: 12),
            Text(
              pickedFile != null ? pickedFile!.files.first.name : 'No file selected',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isUploading ? null : uploadFile,
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
