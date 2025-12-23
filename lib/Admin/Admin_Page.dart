// ignore_for_file: file_names
import 'package:flutter/material.dart';
import '../auth/update_password.dart';
import '../instructor/add_news_page.dart';
import 'Instructor_Requests_Page.dart';
import 'courses_management_page.dart';
import 'assign_instructor_page.dart';
import '../auth/login.dart';
// فقط استدعاء الملف

class AdminPage extends StatefulWidget {
  final String adminId; // معرف الأدمن

  const AdminPage({super.key, required this.adminId});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  final List<String> _titles = const [
    'Instructor Requests',
    'Manage Courses',
    'Assign Instructor',
    'Add Student',
  ];

  @override
  void initState() {
    super.initState();
    _pages = [
      const InstructorRequestsPage(),
      const CoursesManagementPage(),
      const AssignInstructorPage(),
      const AddNewsPage(instructorId: '',),
    ];
  }

  void logout() {
    // مسح بيانات الجلسة إذا موجودة
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Login()),
      (route) => false,
    );
  }

  void changePassword() {
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
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.settings),
            onSelected: (value) {
              if (value == 'change_password') {
                changePassword();
              } else if (value == 'logout') {
                logout();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'change_password',
                child: Text('Change Password'),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Courses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Assign',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: 'Add News'),
        ],
      ),
    );
  }
}
