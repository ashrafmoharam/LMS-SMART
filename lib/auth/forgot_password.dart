import 'package:flutter/material.dart';
import '../core/api_service.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String message = '';

  void handleForgotPassword() async {
    if (emailController.text.isEmpty) {
      setState(() => message = "Please enter your email");
      return;
    }

    setState(() {
      isLoading = true;
      message = '';
    });

    final result = await ApiService.forgotPassword(emailController.text.trim());

    setState(() {
      isLoading = false;
      message = result['status'] == 'success'
          ? "A password reset link has been sent to your email"
          : result['message'] ?? "Failed to send reset link";
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forgot Password'),
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
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Forgot Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              if (message.isNotEmpty)
                Text(
                  message,
                  style: TextStyle(
                    color: message.contains("sent") ? Colors.green : Colors.red,
                  ),
                ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isLoading ? null : handleForgotPassword,
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Send Reset Link', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
