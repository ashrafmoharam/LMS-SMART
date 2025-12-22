import 'package:flutter/material.dart';
import '../../../../core/api_service.dart';


class CreateQuizPage extends StatefulWidget {
  final String courseId;

  const CreateQuizPage({super.key, required this.courseId});

  @override
  State<CreateQuizPage> createState() => _CreateQuizPageState();
}

class _CreateQuizPageState extends State<CreateQuizPage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController questionsCountController = TextEditingController();
  int totalMarks = 0;
  List<Map<String, dynamic>> questions = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Quiz")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quiz Title
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Quiz Title"),
            ),
            const SizedBox(height: 16),

            // Total Marks
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Marks"),
              onChanged: (val) {
                setState(() {
                  totalMarks = int.tryParse(val) ?? 0;
                });
              },
            ),
            const SizedBox(height: 16),

            // Number of Questions
            TextField(
              controller: questionsCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Number of Questions"),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () {
                final count = int.tryParse(questionsCountController.text) ?? 0;
                if (count <= 0) return;

                setState(() {
                  questions = List.generate(count, (index) => {
                        "question": "",
                        "options": ["", "", "", ""],
                        "answer": ""
                      });
                });
              },
              child: const Text("Create Questions Fields"),
            ),
            const SizedBox(height: 16),

            // Questions Fields
            ...questions.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: "Question ${index + 1}"),
                        onChanged: (val) => q["question"] = val,
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(4, (i) {
                        return TextField(
                          decoration: InputDecoration(labelText: "Option ${i + 1}"),
                          onChanged: (val) => q["options"][i] = val,
                        );
                      }),
                      const SizedBox(height: 8),
                      TextField(
                        decoration: const InputDecoration(labelText: "Correct Answer (Option text)"),
                        onChanged: (val) => q["answer"] = val,
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || totalMarks <= 0 || questions.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please fill all fields")),
                  );
                  return;
                }

                final result = await ApiService.createQuiz(
                  courseId: widget.courseId,
                  title: titleController.text,
                  totalMarks: totalMarks,
                  questions: questions,
                );

                if (result['status'] == 'success') {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Quiz created successfully")),
                  );
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result['message'] ?? "Failed to create quiz")),
                  );
                }
              },
              child: const Text("Submit Quiz"),
            ),
          ],
        ),
      ),
    );
  }
}
