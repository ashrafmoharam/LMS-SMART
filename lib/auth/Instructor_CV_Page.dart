// ignore_for_file: file_names, use_build_context_synchronously

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/api_service.dart';
import 'dart:io';

class InstructorCVPage extends StatefulWidget {
  final String instructorId;
  const InstructorCVPage({super.key, required this.instructorId});

  @override
  State<InstructorCVPage> createState() => _InstructorCVPageState();
}

class _InstructorCVPageState extends State<InstructorCVPage> {
  File? selectedFile;           // للموبايل
  Uint8List? selectedFileBytes; // للويب
  String? selectedFileName;     // للويب
  bool isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

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

  void uploadCV() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    if (selectedFile == null && selectedFileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a CV file')),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.uploadInstructorCV(
      instructorId: widget.instructorId,
      fileBytes: selectedFileBytes ?? Uint8List(0), // ملف مختار
      fileName: selectedFileName ?? selectedFile!.path.split('/').last, // اسم الملف
      fullName: nameController.text,
      personalEmail: emailController.text,
      phone: phoneController.text,
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
      appBar: AppBar(title: const Text('Upload Instructor CV')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Personal Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: pickFile, child: const Text('Select PDF CV')),
              const SizedBox(height: 16),
              if (kIsWeb && selectedFileName != null) Text('Selected: $selectedFileName'),
              if (!kIsWeb && selectedFile != null) Text('Selected: ${selectedFile!.path.split('/').last}'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isLoading ? null : uploadCV,
                child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Upload CV'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
