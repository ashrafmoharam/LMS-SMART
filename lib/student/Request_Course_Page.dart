// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class RequestCoursePage extends StatefulWidget {
  const RequestCoursePage({super.key});

  @override
  State<RequestCoursePage> createState() => _RequestCoursePageState();
}

class _RequestCoursePageState extends State<RequestCoursePage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController(); // البريد الجامعي

  String? selectedCourseId;
  bool loading = false;
  bool loadingCourses = true;

  String? studentId; // ID الطالب من SharedPreferences
  List<Map<String, String>> coursesList = [];
  List<String> sentCourses = [];

  @override
  void initState() {
    super.initState();
    loadStudentData();
    fetchCourses();
  }

  Future<void> loadStudentData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      studentId = prefs.getString('student_id'); // لازم يكون مخزن عند تسجيل الدخول
      nameController.text = prefs.getString('student_name') ?? '';
      emailController.text = prefs.getString('student_email') ?? '';
    });
  }

  Future<void> fetchCourses() async {
    try {
      final res = await ApiService.getAllCourses();
      setState(() {
        coursesList = res
            .map((e) => {"id": e['id'].toString(), "title": e['title'].toString()})
            .toList();
        loadingCourses = false;
      });
      print("Courses fetched: $coursesList");
    } catch (e) {
      setState(() => loadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $e")),
      );
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a course")),
      );
      return;
    }

    if (sentCourses.contains(selectedCourseId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You have already requested this course"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Student ID not found")),
      );
      return;
    }

    setState(() => loading = true);

    final res = await ApiService.requestCourse(
      studentId: studentId!,
      courseId: selectedCourseId!,
      studentEmail: emailController.text,
    );

    setState(() => loading = false);

    if (res['status'] == 'success') {
      sentCourses.add(selectedCourseId!);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Request Sent ✅"),
          content: Text(
              "Your request for '${coursesList.firstWhere((c) => c['id'] == selectedCourseId)['title']}' has been sent successfully."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      setState(() {
        selectedCourseId = null;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['message'] ?? "Error")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const Scaffold(
        body: Center(child: Text("Web only")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Request Course")),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "Student Name"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: "University Email"),
                  validator: (v) => v!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 10),
                loadingCourses
                    ? const CircularProgressIndicator()
                    : DropdownButtonFormField<String>(
                        value: selectedCourseId,
                        decoration: const InputDecoration(
                          labelText: "Select Course",
                          border: OutlineInputBorder(),
                        ),
                        items: coursesList
                            .map((course) => DropdownMenuItem(
                                  value: course["id"],
                                  child: Text(course["title"]!),
                                  enabled: !sentCourses.contains(course["id"]),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedCourseId = value;
                          });
                        },
                        validator: (v) =>
                            v == null ? "Please select a course" : null,
                      ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: loading ? null : submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Request"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
