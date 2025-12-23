// ignore_for_file: file_names, use_build_context_synchronously

import 'package:flutter/material.dart';
import '../core/api_service.dart';

class AddNewsPage extends StatefulWidget {
  final String instructorId;
  const AddNewsPage({super.key, required this.instructorId});

  @override
  State<AddNewsPage> createState() => _AddNewsPageState();
}

class _AddNewsPageState extends State<AddNewsPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  bool submitting = false;
  bool loadingNews = true;
  List<dynamic> newsList = [];

  @override
  void initState() {
    super.initState();
    loadNews();
  }

  /// تحميل الأخبار
  Future<void> loadNews() async {
    setState(() => loadingNews = true);
    newsList = await ApiService.getInstructorNews(widget.instructorId);
    setState(() => loadingNews = false);
  }

  /// إضافة خبر
  Future<void> addNews() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and content are required')),
      );
      return;
    }

    setState(() => submitting = true);

    final result = await ApiService.addInstructorNews(
      title,
      content,
      widget.instructorId,
    );

    setState(() => submitting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Done')),
    );

    // ✅ تحديث تلقائي
    titleController.clear();
    contentController.clear();
    await loadNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin News'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// ===== Add News =====
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: contentController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Content',
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitting ? null : addNews,
                        child: submitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Publish'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// ===== News List =====
            const Text(
              'Your News',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            loadingNews
                ? const Center(child: CircularProgressIndicator())
                : newsList.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No news yet'),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: newsList.length,
                        itemBuilder: (context, index) {
                          final news = newsList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(
                                news['title'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    news['content'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    news['created_at'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
