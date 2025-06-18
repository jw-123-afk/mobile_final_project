import 'dart:convert';
import 'package:http/http.dart' as http;
import 'worker.dart';
import 'task.dart';
import './submission.dart';

class ApiService {
  static const String baseUrl = 'http://10.144.148.82/workers';

  Future<Map<String, dynamic>> registerWorker({
    required String fullName,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register_worker.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'full_name': fullName,
        'email': email,
        'password': password,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to register worker');
    }
  }

  Future<Worker> loginWorker({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login_worker.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Worker.fromJson(data['worker']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to login');
    }
  }

  Future<List<Task>> getWorkerTasks(int workerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_works.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'worker_id': workerId}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> tasksList = data['tasks'] ?? [];
      return tasksList.map((task) => Task.fromJson(task)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to fetch tasks');
    }
  }

  Future<Map<String, dynamic>> submitWork({
    required int workId,
    required int workerId,
    required String submissionText,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/submit_work.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'work_id': workId,
        'worker_id': workerId,
        'submission_text': submissionText,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit work');
    }
  }

  Future<List<Map<String, dynamic>>> getWorkerSubmissions(int workerId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/get_submissions.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'worker_id': workerId}),
    );

    final data = jsonDecode(response.body);
    print('Server Response: $data'); // Debug log

    if (response.statusCode == 200 && data['success']) {
      final submissions = List<Map<String, dynamic>>.from(data['submissions']);
      print('Submissions data: $submissions'); // Debug log
      return submissions;
    } else {
      final errorMessage =
          data['message'] ??
          data['error_details'] ??
          'Failed to load submissions';
      throw Exception(errorMessage);
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required int workerId,
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_profile.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'worker_id': workerId,
        'fullName': name,
        'email': email,
        'phone': phone,
        'address': address,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update profile');
    }
  }

  Future<Map<String, dynamic>> updateSubmission({
    required int submissionId,
    required String submissionText,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/update_submission.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'submission_id': submissionId,
        'submission_text': submissionText,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update submission');
      }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update submission');
    }
  }
}
