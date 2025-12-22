import 'package:flutter/material.dart';
import 'package:smartlearn_lms/student/CoursesPage/CourseDetailsPage/Course_Details_Page.dart';
import '../../core/api_service.dart';


class CoursesPage extends StatefulWidget {
  final String studentId;

  const CoursesPage({super.key, required this.studentId});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<List<dynamic>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = ApiService.getStudentCourses(widget.studentId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _coursesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No courses found'),
          );
        }

        final courses = snapshot.data!;
        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            final course = courses[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                title: Text(course['title'] ?? 'Untitled'),
                subtitle: Text(course['description'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CourseDetailsPage(
                        courseId: course['id'].toString(),
                        studentId: widget.studentId,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
