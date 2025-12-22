import 'package:flutter/material.dart';
import '../core/api_service.dart';

class UpdatePasswordPage extends StatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  State<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends State<UpdatePasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool isLoading = false;

  void updatePassword() async {
    final email = emailController.text.trim();
    final oldPass = oldPasswordController.text.trim();
    final newPass = newPasswordController.text.trim();

    if (email.isEmpty || oldPass.isEmpty || newPass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All fields are required")),
      );
      return;
    }

    setState(() => isLoading = true);

    final result = await ApiService.updatePassword(
      email: email,
      oldPassword: oldPass,
      newPassword: newPass,
    );

    setState(() => isLoading = false);

    if (result['status'] == 'success') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully")),
      );
      emailController.clear();
      oldPasswordController.clear();
      newPasswordController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? "Failed")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Update Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Email
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'University Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),

            /// Old Password
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(
                labelText: 'Old Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 16),

            /// New Password
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updatePassword,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Update Password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
