class Submission {
  final int id;
  final int workId;
  final int workerId;
  final String submissionText;
  final DateTime submissionDate;

  Submission({
    required this.id,
    required this.workId,
    required this.workerId,
    required this.submissionText,
    required this.submissionDate,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: int.parse(json['id'].toString()),
      workId: int.parse(json['work_id'].toString()),
      workerId: int.parse(json['worker_id'].toString()),
      submissionText: json['submission_text'],
      submissionDate: DateTime.parse(json['submission_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'work_id': workId,
      'worker_id': workerId,
      'submission_text': submissionText,
      'submission_date': submissionDate.toIso8601String(),
    };
  }
}