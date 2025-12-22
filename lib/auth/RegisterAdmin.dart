import 'package:flutter/material.dart';
import '../core/api_service.dart';

class RegisterAdminPage extends StatefulWidget {
  const RegisterAdminPage({super.key});

  @override
  State<RegisterAdminPage> createState() => _RegisterAdminPageState();
}

class _RegisterAdminPageState extends State<RegisterAdminPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();
  final TextEditingController universityEmailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> registerAdmin() async {
    final fullName = fullNameController.text.trim();
    final personalEmail = personalEmailController.text.trim();
    final universityEmail = universityEmailController.text.trim();
    final password = passwordController.text.trim();

    if (fullName.isEmpty || personalEmail.isEmpty || universityEmail.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.registerAdmin(
      fullName: fullName,
      personalEmail: personalEmail,
      universityEmail: universityEmail,
      password: password,
    );

    setState(() => isLoading = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin registered successfully')),
      );
      fullNameController.clear();
      personalEmailController.clear();
      universityEmailController.clear();
      passwordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Failed to register admin')),
      );
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    personalEmailController.dispose();
    universityEmailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Admin')),
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
              const Text('Register Admin', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),

              TextField(
                controller: fullNameController,
                decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: personalEmailController,
                decoration: const InputDecoration(labelText: 'Personal Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: universityEmailController,
                decoration: const InputDecoration(labelText: 'University Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : registerAdmin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
