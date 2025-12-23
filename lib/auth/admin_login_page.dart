import 'package:flutter/material.dart';
import '../core/api_service.dart';
import '../admin/admin_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginAdmin() async {
    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    final data = await ApiService.loginAdmin(
      emailController.text.trim().toLowerCase(),
      passwordController.text.trim(),
    );

    if (!mounted) return;

    if (data['status'] == 'success' && data['role'] == 'admin') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminPage(adminId: data['id'].toString()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid admin credentials')),
      );
    }

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login'), centerTitle: true),
      body: Center(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Admin Login',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'University Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loginAdmin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Login as Admin'),
                      ),
                    ),
                    
            ],
          ),
        ),
      ),
    );
  }
}
