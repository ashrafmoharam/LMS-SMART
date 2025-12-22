// ignore_for_file: file_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../core/api_service.dart'; // عدل المسار حسب مكان ملف ApiService.dart

class InstructorCVPage extends StatefulWidget {
  const InstructorCVPage({super.key});

  @override
  State<InstructorCVPage> createState() => _InstructorCVPageState();
}

class _InstructorCVPageState extends State<InstructorCVPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fieldController = TextEditingController();

  File? _cvFile;
  bool isLoading = false;

  // اختيار الملف
  Future<void> pickCV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() {
        _cvFile = File(result.files.single.path!);
      });
    }
  }

  // ارسال الطلب باستخدام ApiService
  Future<void> submitRequest() async {
    if (!_formKey.currentState!.validate()) return;
    if (_cvFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your CV')),
      );
      return;
    }

    setState(() => isLoading = true);

    var result = await ApiService.submitInstructorRequest(
      fullName: _nameController.text,
      phone: _phoneController.text,
      personalEmail: _emailController.text,
      field: _fieldController.text,
      cvFile: _cvFile!,
    );

    setState(() => isLoading = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request submitted successfully!')),
      );
      _formKey.currentState!.reset();
      setState(() {
        _cvFile = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Submission failed')),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _fieldController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor CV Submission'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF2F4F7),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              shrinkWrap: true,
              children: [
                const Text(
                  'Submit Your CV',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your full name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your phone number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Personal Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fieldController,
                  decoration: const InputDecoration(
                    labelText: 'Field',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? 'Please enter your field' : null,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: pickCV,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_cvFile == null ? 'Upload CV' : 'Change CV'),
                ),
                if (_cvFile != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child:
                        Text('Selected file: ${_cvFile!.path.split('/').last}'),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : submitRequest,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit Request', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
