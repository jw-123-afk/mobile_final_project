class Task {
  final int id;
  final String title;
  final String description;
  final int assignedTo;
  final DateTime dateAssigned;
  final DateTime dueDate;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.dateAssigned,
    required this.dueDate,
    required this.status,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    try {
      return Task(
        id: int.parse(json['id']?.toString() ?? '0'),
        title: json['title'] ?? 'Untitled Task',
        description: json['description'] ?? 'No description provided',
        assignedTo: int.parse(json['assigned_to']?.toString() ?? '0'),
        dateAssigned: _parseDate(json['date_assigned'] ?? ''),
        dueDate: _parseDate(json['due_date'] ?? ''),
        status: json['status'] ?? 'pending',
      );
    } catch (e) {
      print('Error parsing task JSON: $e');
      print('Problematic JSON: $json');
      // Return a default task as fallback
      return Task(
        id: 0,
        title: 'Error: Invalid Task Data',
        description: 'There was an error loading this task. Please refresh or contact support.',
        assignedTo: 0,
        dateAssigned: DateTime.now(),
        dueDate: DateTime.now().add(const Duration(days: 7)),
        status: 'error',
      );
    }
  }
  
  static DateTime _parseDate(String dateStr) {
    if (dateStr == null || dateStr.isEmpty) {
      return DateTime.now();
    }
    
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      // Try different date formats
      try {
        final parts = dateStr.split('-');
        if (parts.length == 3) {
          return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
        }
      } catch (e) {
        print('Failed to parse date: $dateStr');
      }
      
      // If all parsing attempts fail, return current date
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'date_assigned': dateAssigned.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'status': status,
    };
  }
}