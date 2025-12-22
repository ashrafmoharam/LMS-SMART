import 'package:flutter/material.dart';
import '../core/api_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController personalEmailController = TextEditingController();

  bool isLoading = false;
  String errorMessage = '';

  void handleRegister() async {
    if (nameController.text.isEmpty || personalEmailController.text.isEmpty) {
      setState(() => errorMessage = "Please fill all fields");
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    // تسجيل الطالب فقط
    final result = await ApiService.registerWithEmail(
      nameController.text.trim(),
      personalEmailController.text.trim(),
      'student',
    );

    setState(() => isLoading = false);

    if (result['status'] == 'success') {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Check your email.'),
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } else {
      setState(() {
        errorMessage = result['message'] ?? 'Registration failed';
      });
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    personalEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      appBar: AppBar(
        title: const Text('Register Student'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 12),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Register',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: personalEmailController,
                decoration: const InputDecoration(
                  labelText: 'Personal Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Register', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
