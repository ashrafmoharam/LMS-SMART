// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/api_service.dart';

class UploadAssignmentPage extends StatefulWidget {
  final String courseId;
  const UploadAssignmentPage({super.key, required this.courseId});

  @override
  State<UploadAssignmentPage> createState() => _UploadAssignmentPageState();
}

class _UploadAssignmentPageState extends State<UploadAssignmentPage> {
  File? selectedFile;               // 📱 موبايل
  Uint8List? selectedFileBytes;     // 🌐 ويب
  String? selectedFileName;         // 🌐 ويب

  final TextEditingController titleController = TextEditingController();
  DateTime? dueDate;                // 📅 due date + time
  bool isLoading = false;

  // ===============================
  // اختيار ملف PDF
  // ===============================
  void pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: kIsWeb,
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

  // ===============================
  // اختيار Due Date + Time
  // ===============================
  void pickDueDateTime() async {
    // اختيار التاريخ
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate == null) return;

    // اختيار الساعة
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime == null) return;

    // دمج التاريخ + الساعة
    setState(() {
      dueDate = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  // ===============================
  // رفع الاسايمنت
  // ===============================
  void uploadAssignment() async {
    if (titleController.text.isEmpty ||
        dueDate == null ||
        (selectedFile == null && selectedFileBytes == null)) {
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.uploadAssignment(
      courseId: widget.courseId,
      title: titleController.text,
      dueDate: dueDate!.toString().substring(0, 19), // YYYY-MM-DD HH:MM:SS
      fileBytes:  selectedFileBytes! ,
      fileName:   selectedFileName! ,
      file:  selectedFile ,
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
      appBar: AppBar(title: const Text('Upload Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Assignment Title'),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: pickFile,
              child: const Text('Select PDF'),
            ),

            if (kIsWeb && selectedFileName != null)
              Text('Selected: $selectedFileName'),

            if (!kIsWeb && selectedFile != null)
              Text('Selected: ${selectedFile!.path.split('/').last}'),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: pickDueDateTime,
              child: const Text('Select Due Date & Time'),
            ),

            if (dueDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Due Date: ${dueDate!.toString().substring(0, 16)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: isLoading ? null : uploadAssignment,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }
}
