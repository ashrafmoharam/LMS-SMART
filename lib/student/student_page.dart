import 'package:flutter/material.dart';
import 'package:smartlearn_lms/student/CoursesPage/courses_page.dart';
import 'package:smartlearn_lms/student/Request_Course_Page.dart';
import 'news_page.dart';
import 'grades_page.dart';
import '../auth/login.dart';
import '../auth/update_password.dart';

class StudentPage extends StatefulWidget {
  final String studentId;

  const StudentPage({super.key, required this.studentId});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  int selectedIndex = 0;

  late final List<Widget> pages;
  final List<String> titles = [
    'Courses',
    'News',
    'Grades',
    'Request Course', // 🆕
  ];

  @override
  void initState() {
    super.initState();
    pages = [
      CoursesPage(studentId: widget.studentId),
      NewsPage(studentId: widget.studentId),
      GradesPage(studentId: widget.studentId),
      const RequestCoursePage(studentId: '',), // 🆕
    ];
  }

  void handleLogout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
    );
  }

  void handleChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const UpdatePasswordPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titles[selectedIndex]),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') handleLogout();
              if (value == 'change_password') handleChangePassword();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: 'change_password',
                  child: Text('Change Password')),
              PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: pages[selectedIndex],
     bottomNavigationBar: BottomNavigationBar(
  currentIndex: selectedIndex,
  onTap: (index) => setState(() => selectedIndex = index),
  selectedItemColor: Colors.black,      // 🖤 اللون عند التحديد
  unselectedItemColor: Colors.black54,  // 🖤 اللون عند عدم التحديد
  items: const [
    BottomNavigationBarItem(
        icon: Icon(Icons.book), label: 'Courses'),
    BottomNavigationBarItem(
        icon: Icon(Icons.newspaper), label: 'News'),
    BottomNavigationBarItem(
        icon: Icon(Icons.grade), label: 'Grades'),
    BottomNavigationBarItem(
        icon: Icon(Icons.request_page), label: 'Request'),
  ],
),

    );
  }
}
