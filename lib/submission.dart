class Submission {
  final int id;
  final int workId;
  final int workerId;
  final String submissionText;
  final DateTime submissionDate;
  final String taskName;
  final String status;

  Submission({
    required this.id,
    required this.workId,
    required this.workerId,
    required this.submissionText,
    required this.submissionDate,
    required this.taskName,
    required this.status,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    print('Parsing submission JSON: $json'); // Debug log

    DateTime parseDate(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) {
        return DateTime.now();
      }
      try {
        return DateTime.parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr, error: $e');
        return DateTime.now();
      }
    }

    return Submission(
      id: int.parse(json['id'].toString()),
      workId: int.parse(json['work_id'].toString()),
      workerId: int.parse(json['worker_id'].toString()),
      submissionText: json['submission_text'],
      submissionDate: parseDate(json['submitted_at']),
      taskName: json['task_name'] ?? 'Unknown Task',
      status: json['status'] ?? 'Pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_id': workId,
      'worker_id': workerId,
      'submission_text': submissionText,
      'submitted_at': submissionDate.toIso8601String(),
      'task_name': taskName,
      'status': status,
    };
  }
}
