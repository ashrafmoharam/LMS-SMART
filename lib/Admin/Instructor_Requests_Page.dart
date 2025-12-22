// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/api_service.dart';

class InstructorRequestsPage extends StatefulWidget {
  const InstructorRequestsPage({super.key});

  @override
  State<InstructorRequestsPage> createState() => _InstructorRequestsPageState();
}

class _InstructorRequestsPageState extends State<InstructorRequestsPage> {
  List requests = [];
  bool loading = true;
  bool submitting = false;

  @override
  void initState() {
    super.initState();
    loadRequests();
  }

  Future<void> loadRequests() async {
    setState(() => loading = true);
    requests = await ApiService.getInstructorRequests();
    setState(() => loading = false);
  }

  // فتح ملف PDF باستخدام الرابط
  Future<void> viewCV(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open CV')),
      );
    }
  }

  Future<void> handleRequest(String id, bool approve) async {
    if (submitting) return;
    setState(() => submitting = true);

    final result = approve
        ? await ApiService.approveInstructor(id)
        : await ApiService.rejectInstructor(id);

    setState(() => submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message'] ?? (approve ? 'Approved' : 'Rejected')),
        backgroundColor:
            result['status'] == 'success' ? Colors.green : Colors.red,
      ),
    );

    // إعادة تحميل الطلبات بعد الإجراء
    await loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instructor Requests')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : requests.isEmpty
              ? const Center(child: Text('No pending requests'))
              : ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final r = requests[index];
                    final cvFile = r['cv_file'] ?? '';
                    final cvUrl =
                        'http://10.0.2.2/SmartLearn_LMS/uploads/cvs/$cvFile';

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(r['full_name'] ?? 'Unknown'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r['personal_email'] ?? ''),
                            const SizedBox(height: 4),
                            cvFile.isNotEmpty
                                ? GestureDetector(
                                    onTap: () => viewCV(cvUrl),
                                    child: const Text(
                                      'View CV',
                                      style: TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  )
                                : const Text('No CV uploaded'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => handleRequest(r['id'], true),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => handleRequest(r['id'], false),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
