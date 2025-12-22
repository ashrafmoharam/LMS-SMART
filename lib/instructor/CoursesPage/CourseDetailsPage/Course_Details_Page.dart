// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'AssignmentsTab/Assignments_Tab.dart';
import 'LecturesTab/Lectures_Tab.dart';
import 'QuizzesTab/Quizzes_Tab.dart';
import 'StudentsTab/Course_Students_Page.dart';

class CourseDetailsPage extends StatefulWidget {
  final String courseId;
  final String courseTitle;

  const CourseDetailsPage({
    super.key,
    required this.courseId,
    required this.courseTitle,
  });

  @override
  State<CourseDetailsPage> createState() => _CourseDetailsPageState();
}

class _CourseDetailsPageState extends State<CourseDetailsPage> {
  int selectedIndex = 0;

  late final List<Widget> pages;

  final List<String> titles = const [
    'Lectures',
    'Assignments',
    'Quizzes',
    'Students',
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      LecturesTab(courseId: widget.courseId),
      AssignmentsTab(courseId: widget.courseId),
      QuizzesTab(courseId: widget.courseId),
      CourseStudentsPage(
        courseId: widget.courseId,
        courseTitle: widget.courseTitle,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.courseTitle} • ${titles[selectedIndex]}'),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Lectures',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Assignments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.quiz_outlined),
            label: 'Quizzes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_outlined),
            label: 'Students',
          ),
        ],
      ),
    );
  }
}
