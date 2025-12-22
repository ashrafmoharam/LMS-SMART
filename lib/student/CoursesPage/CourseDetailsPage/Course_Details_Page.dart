// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:smartlearn_lms/student/CoursesPage/CourseDetailsPage/AssignmentsTab/Assignments_Tab.dart';
import 'package:smartlearn_lms/student/CoursesPage/CourseDetailsPage/LecturesTab/Lectures_Tab.dart';
import 'package:smartlearn_lms/student/CoursesPage/CourseDetailsPage/QuizzesTab/Quizzes_Tab.dart';


class CourseDetailsPage extends StatefulWidget {
  final String courseId;
  final String studentId;

  const CourseDetailsPage({super.key, required this.courseId, required this.studentId});

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  int selectedTab = 0;
  final tabs = ['Lectures', 'Assignments', 'Quizzes'];

  @override
  Widget build(BuildContext context) {
    final tabPages = [
      LecturesTab(courseId: widget.courseId),
      AssignmentsTab(courseId: widget.courseId, studentId: widget.studentId),
      QuizzesTab(courseId: widget.courseId, studentId: widget.studentId),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('Course Details')),
      body: tabPages[selectedTab],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) => setState(() => selectedTab = index),
        items: tabs
            .map((t) => BottomNavigationBarItem(icon: const Icon(Icons.book), label: t))
            .toList(),
      ),
    );
  }
}
