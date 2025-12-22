// ignore_for_file: file_names

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/api_service.dart';
import 'dart:io';

class UploadLecturePage extends StatefulWidget {
  final String courseId;
  const UploadLecturePage({super.key, required this.courseId});

  @override
  State<UploadLecturePage> createState() => _UploadLecturePageState();
}

class _UploadLecturePageState extends State<UploadLecturePage> {
  File? selectedFile;          // للموبايل
  Uint8List? selectedFileBytes; // للويب
  String? selectedFileName;     // للويب
  final TextEditingController titleController = TextEditingController();
  bool isLoading = false;

  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb, // مهم للويب للحصول على bytes
    );

    if (result != null) {
      if (kIsWeb) {
        selectedFileBytes = result.files.single.bytes;
        selectedFileName = result.files.single.name;
      } else {
        final path = result.files.single.path;
        if (path != null) selectedFile = File(path);
      }
      setState(() {});
    }
  }

  void uploadLecture() async {
    if (titleController.text.isEmpty || (selectedFile == null && selectedFileBytes == null)) return;

    setState(() => isLoading = true);

    final result = await ApiService.uploadLecture(
  courseId: widget.courseId,
  title: titleController.text,
  fileBytes: selectedFileBytes!,  // ملف مختار
  fileName: selectedFileName!,    // اسم الملف
);


    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Done')),
    );

    if (result['status'] == 'success') Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Lecture')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Lecture Title')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: pickFile, child: const Text('Select PDF')),
            if (kIsWeb && selectedFileName != null) Text('Selected: $selectedFileName'),
            if (!kIsWeb && selectedFile != null) Text('Selected: ${selectedFile!.path.split('/').last}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : uploadLecture,
              child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
