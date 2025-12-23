// ignore_for_file: avoid_print, non_constant_identifier_names

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiService {
  // =====================================================
  // Base URL
  // =====================================================
  static String get baseUrl {
    if (kIsWeb) return "http://192.168.1.3/SmartLearn_LMS";
    if (Platform.isAndroid) return "http://10.0.2.2/SmartLearn_LMS";
    if (Platform.isIOS) return "http://localhost/SmartLearn_LMS";
    return "http://localhost/SmartLearn_LMS";
  }

  // =====================================================
  // AUTH
  // =====================================================
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login.php'),
        body: {"email": email, "password": password},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect to server"};
    }
  }
 static Future<Map<String, dynamic>> loginAdmin(
      String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login_admin.php'),
        body: {"email": email, "password": password},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect to server"};
    }
  }
  static Future<Map<String, dynamic>> registerAdmin({
  required String fullName,
  required String personalEmail,
  required String universityEmail,
  required String password,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register_admin.php'),
      body: {
        'full_name': fullName,
        'personal_email': personalEmail,
        'university_email': universityEmail,
        'password': password,
      },
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"status": "error", "message": "Failed to connect to server"};
  }
}

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/forgot_password.php'),
        body: {"email": email},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect to server"};
    }
  }

static Future<Map<String, dynamic>> updatePassword({
  required String email,
  required String oldPassword,
  required String newPassword,
}) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/update_password.php'),
      body: {
        "email": email,
        "old_password": oldPassword,
        "new_password": newPassword,
      },
    );
    return jsonDecode(response.body);
  } catch (e) {
    return {"status": "error", "message": "Server connection failed"};
  }
}




  static Future<Map<String, dynamic>> registerWithEmail(String name, String personalEmail, String role) async {
    try {
      final response = await http.post(
       Uri.parse('$baseUrl/api/auth/register_with_email.php'),
        body: {"name": name, "personal_email": personalEmail, "role": role},
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect to server"};
    }
  }

  // =====================================================
  // INSTRUCTOR REQUEST (UPLOAD CV)
  // =====================================================
  static Future<Map<String, dynamic>> submitInstructorRequest({
    required String fullName,
    required String phone,
    required String personalEmail,
    required String field,
    required File cvFile,
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/instructor/instructor_request.php'));
      request.fields['full_name'] = fullName;
      request.fields['phone'] = phone;
      request.fields['personal_email'] = personalEmail;
      request.fields['field'] = field;
      request.files.add(await http.MultipartFile.fromPath('cv', cvFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // =====================================================
  // STUDENT
  // =====================================================
  static Future<List<dynamic>> getStudentCourses(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/student/student_courses.php?student_id=$studentId'));
      return jsonDecode(response.body)['courses'] ?? [];
    } catch (e) {
      return [];
    }
  }


 static Future<List<dynamic>> getStudentQuizGrades(String studentId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/student/student_grades.php?student_id=$studentId'),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['grades'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getStudentAssignments(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/student/student_assignments.php?student_id=$studentId'));
      return jsonDecode(response.body)['assignments'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getStudentQuizzes(String studentId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/student/student_quizzes.php?student_id=$studentId'));
      return jsonDecode(response.body)['quizzes'] ?? [];
    } catch (e) {
      return [];
    }
  }

static Future<List<dynamic>> getAllNews() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/student/student_news.php'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['news'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // =====================================================
  // INSTRUCTOR
  // =====================================================
static Future<List<dynamic>> getInstructorCourses(String instructorId) async {
  final response = await http.get(
    Uri.parse(
      '$baseUrl/api/instructor/instructor_courses.php?instructor_id=$instructorId',
    ),
  );

  final data = jsonDecode(response.body);
  return data['courses'] ?? [];
}




static Future<List<dynamic>> getInstructorNews(String instructorId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/instructor/instructor_news.php?instructor_id=$instructorId'),
    );

    final data = jsonDecode(response.body);
    return data['news'] ?? [];
  } catch (e) {
    return [];
  }
}

static Future<Map<String, dynamic>> addInstructorNews(
  String title,
  String content,
  String instructorId,
) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/instructor/add_news.php'),
      body: {
        "title": title,
        "content": content,
        "instructor_id": instructorId,
      },
    );

    print(response.body); // 👈 ضروري
    return jsonDecode(response.body);

  } catch (e) {
    print("ERROR: $e");
    return {
      "status": "error",
      "message": "Failed to connect to server"
    };
  }
}

  // =====================================================
  // Course Assignments
  // =====================================================
  
    static Future<List<dynamic>> getCourseAssignments(String courseId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/instructor/course_assignments.php?course_id=$courseId'),
    );
    final data = jsonDecode(response.body);
    return data['assignments'] ?? [];
  } catch (e) {
    return [];
  }
}


// رفع الاسيمنت على Web فقط
static Future<Map<String, dynamic>> uploadAssignment({
  required String courseId,
  required String title,
  required Uint8List fileBytes,
  required String fileName,
  required String dueDate, File? file, // ✅ due_date
}) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/instructor/upload_assignment.php'),
    );

    // =========================
    // البيانات النصية
    // =========================
    request.fields['course_id'] = courseId;
    request.fields['title'] = title;
    request.fields['due_date'] = dueDate; // ✅ إرسال due_date

    // =========================
    // الملف (Web)
    // =========================
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      ),
    );

    var response = await request.send();
    var respStr = await response.stream.bytesToString();

    return jsonDecode(respStr);
  } catch (e) {
    return {
      "status": "error",
      "message": e.toString(),
    };
  }
}

  static Future<bool> AssignmentSubmissions({
    required String courseId,
    required String assignmentId,
    required String studentId,
    required dynamic file,
    required String fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/student/assignment_submissions.php'),
      );
      request.fields['course_id'] = courseId;
      request.fields['assignment_id'] = assignmentId;
      request.fields['student_id'] = studentId;

      if (kIsWeb) {
        request.files.add(http.MultipartFile.fromBytes('file', file, filename: fileName));
      } else {
        request.files.add(await http.MultipartFile.fromPath('file', file.path));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        var resStr = await response.stream.bytesToString();
        return resStr.contains('"status":"success"');
      } else {
        return false;
      }
    } catch (e) {
      print(e);
      return false;
    }
  }

 static Future<List<dynamic>> getAssignmentSubmissions(String assignmentId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/instructor/assignment_submissions.php?assignment_id=$assignmentId'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // تحقق من أن status success والمفتاح submissions موجود
      if (data['status'] == 'success' && data['submissions'] != null) {
        return List<dynamic>.from(data['submissions']);
      } else {
        return [];
      }
    } else {
      return [];
    }
  } catch (e) {
    return [];
  }
}


  // =====================================================
  // Course Lectures
  // =====================================================
  static Future<List<dynamic>> getCourseLectures(String courseId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/instructor/course_lectures.php?course_id=$courseId'),
      );
      final data = jsonDecode(response.body);
      return data['lectures'] ?? [];
    } catch (e) {
      return [];
    }
  }

 // ==========================================
  // رفع محاضرة موحدة للموبايل والويب
  // ==========================================
 // رفع المحاضرة على Web فقط
   static Future<Map<String, dynamic>> uploadLecture({
    required String courseId,
    required String title,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/instructor/upload_lecture.php'),
      );

      request.fields['course_id'] = courseId;
      request.fields['title'] = title;

      // إضافة الملف للويب
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );

      var response = await request.send();
      var respStr = await response.stream.bytesToString();

      return jsonDecode(respStr);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
  // =====================================================
  // Quizzes
  // =====================================================
  static Future<Map<String, dynamic>> createQuiz({
    required String courseId,
    required String title,
    required int totalMarks,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/instructor/create_quiz.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "course_id": courseId,
          "title": title,
          "total_marks": totalMarks,
          "questions": questions,
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect to server"};
    }
  }

  static Future<List<dynamic>> getCourseQuizzes(String courseId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/instructor/course_quizzes.php?course_id=$courseId'));
      return jsonDecode(response.body)['quizzes'] ?? [];
    } catch (e) {
      return [];
    }
  }

 /// جلب نتائج جميع الطلاب لكويز معين
  static Future<List<dynamic>> getQuizResults(String quizId) async {
    try {
      final url = Uri.parse('$baseUrl/api/instructor/quiz_results.php?quiz_id=$quizId');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['results'] ?? [];
        } else {
          return [];
        }
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching quiz results: $e');
      return [];
    }
  }

  // =========================================
  // جلب أسئلة الكويز
  // =========================================
  static Future<List<dynamic>> getQuizQuestions(String quizId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/student/quiz_questions.php?quiz_id=$quizId'));
      final data = jsonDecode(response.body);
      return data['questions'] ?? [];
    } catch (e) {
      return [];
    }
  }

  // =========================================
  // إرسال إجابات الكويز
  // =========================================
  static Future<bool> submitQuiz({
    required String quizId,
    required String studentId,
    required Map<int, String> answers, // quiz_question_id -> selected_option
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/student/submit_quiz.php'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "quiz_id": quizId,
          "student_id": studentId,
          "answers": answers,
        }),
      );

      final data = jsonDecode(response.body);
      return data['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
  // =====================================================
  // Course Students
  // =====================================================
 static Future<List<dynamic>> getCourseStudents(String courseId) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/instructor/course_students.php?course_id=$courseId')
    );
    final data = jsonDecode(response.body);
    if (data['status'] == 'success') {
      return data['students'] ?? [];
    }
    return [];
  } catch (e) {
    return [];
  }
}


  // =====================================================
  // ADMIN FUNCTIONS
  // =====================================================
  static Future<List<dynamic>> getInstructorRequests() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/instructor_requests.php'));
      return jsonDecode(response.body)['requests'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> approveInstructor(String requestId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/admin/approve_instructor.php'), body: {"request_id": requestId});
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error"};
    }
  }

  static Future<Map<String, dynamic>> rejectInstructor(String requestId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/admin/reject_instructor.php'), body: {"request_id": requestId});
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error"};
    }
  }

  static Future<Map<String, dynamic>> addCourse(String title, String description) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/admin/add_course.php'), body: {"title": title, "description": description});
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error"};
    }
  }

  static Future<Map<String, dynamic>> assignInstructorToCourse(String instructorId, String courseId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/admin/assign_instructor.php'), body: {"instructor_id": instructorId, "course_id": courseId});
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": "Failed to connect to server"};
    }
  }

  static Future<Map<String, dynamic>> addStudentToCourse(String studentId, String courseId) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/admin/add_student_to_course.php'), body: {"student_id": studentId, "course_id": courseId});
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error"};
    }
  }

  static Future<List<dynamic>> getAllStudents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all_students.php'));
      return jsonDecode(response.body)['students'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAllInstructors() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all_instructors.php'));
      return jsonDecode(response.body)['instructors'] ?? [];
    } catch (e) {
      return [];
    }
  }

  static Future<List<dynamic>> getAllCourses() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/admin/all_courses.php'));
      return jsonDecode(response.body)['courses'] ?? [];
    } catch (e) {
      return [];
    }
  }
}
