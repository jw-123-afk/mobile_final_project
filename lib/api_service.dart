import 'dart:convert';
import 'package:http/http.dart' as http;
import 'worker.dart';
import 'task.dart';
import './submission.dart';

class ApiService {
  static const String baseUrl = 'http://10.144.162.180/workers';

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
}
