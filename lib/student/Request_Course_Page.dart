// ignore_for_file: file_names, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../core/api_service.dart';

class RequestCoursePage extends StatefulWidget {
  final String studentId; // ID الطالب
  const RequestCoursePage({super.key, required this.studentId});

  @override
  State<RequestCoursePage> createState() => _RequestCoursePageState();
}

class _RequestCoursePageState extends State<RequestCoursePage> {
  String? selectedCourseId; // تخزن ID المادة
  bool loading = false;
  bool loadingCourses = true;

  List<Map<String, String>> coursesList = []; // كل مادة: {id, title}
  List<String> sentCourses = []; // تخزين ID المواد المرسلة مسبقاً

  @override
  void initState() {
    super.initState();
    fetchCourses();
  }

  // جلب المواد من السيرفر
  Future<void> fetchCourses() async {
    try {
      final res = await ApiService.getAllCourses(); // List<dynamic>
      setState(() {
        coursesList = res
            .map((e) => {"id": e['id'].toString(), "title": e['title'].toString()})
            .toList();
        loadingCourses = false;
      });
      print("Courses fetched: $coursesList"); // Debug
    } catch (e) {
      setState(() => loadingCourses = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching courses: $e")),
      );
    }
  }

  Future<void> submit() async {
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

    setState(() => loading = true);

    print("Sending studentId=${widget.studentId}, courseId=$selectedCourseId");

    final res = await ApiService.requestCourse(
      studentId: widget.studentId,
      courseId: selectedCourseId!,
    );

    print("Response from server: $res"); // Debug

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
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
    );
  }
}
