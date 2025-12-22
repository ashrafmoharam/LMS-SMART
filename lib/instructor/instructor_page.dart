import 'package:flutter/material.dart';
import 'CoursesPage/courses_page.dart';
import 'add_news_page.dart';
import '../auth/login.dart';
import '../auth/update_password.dart';

class InstructorPage extends StatefulWidget {
  final String instructorId;

  const InstructorPage({super.key, required this.instructorId});

  @override
  State<InstructorPage> createState() => _InstructorPageState();
}

class _InstructorPageState extends State<InstructorPage> {
  int selectedIndex = 0;

  late final List<Widget> pages;
  final List<String> titles = ['Courses', 'Add News'];

  @override
  void initState() {
    super.initState();
    pages = [
      CoursesPage(instructorId: widget.instructorId),
      AddNewsPage(instructorId: widget.instructorId),
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
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'change_password', child: Text('Change Password')),
              const PopupMenuItem(value: 'logout', child: Text('Logout')),
            ],
          ),
        ],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Courses'),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Add News'),
        ],
      ),
    );
  }
}
