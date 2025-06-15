import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'api_service.dart';
import 'task.dart';
import 'worker_provider.dart';
import 'work_submission_screen.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final ApiService _apiService = ApiService();
  List<Task> _tasks = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    print('TaskListScreen initState called at ${DateTime.now()}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final workerProvider = Provider.of<WorkerProvider>(
        context,
        listen: false,
      );
      final worker = workerProvider.worker;
      print('Worker from WorkerProvider: ${worker?.id}');
      if (worker == null) {
        print('No worker found, redirecting to login');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please log in to view tasks.';
        });
        Future.delayed(Duration.zero, () {
          Navigator.pushReplacementNamed(context, '/login');
        });
        return;
      }

      print('Loading tasks for worker ID: ${worker.id}');
      final tasks = await _apiService
          .getWorkerTasks(worker.id)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your connection.',
              );
            },
          );
      print('Tasks loaded: ${tasks.length}');

      for (var task in tasks) {
        print('Task ID: ${task.id}, Title: ${task.title}');
        print('  Description: ${task.description}');
        print('  Assigned To: ${task.assignedTo}');
        print('  Date Assigned: ${task.dateAssigned}');
        print('  Due Date: ${task.dueDate}');
        print('  Status: ${task.status}');
      }

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoading = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('Error in _loadTasks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              e.toString().contains('ProviderNotFoundError')
                  ? 'Please log in to view tasks.'
                  : 'Failed to load tasks: ${e.toString().substring(0, min(50, e.toString().length))}... Please try again.';
        });
        if (e.toString().contains('ProviderNotFoundError')) {
          Future.delayed(Duration.zero, () {
            Navigator.pushReplacementNamed(context, '/login');
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkerProvider>(
      builder: (context, workerProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Tasks'),
            backgroundColor: Colors.transparent, // transparent background
          ),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            onPressed:
                _isLoading
                    ? null
                    : () {
                      print('Manually refreshing tasks at ${DateTime.now()}');
                      _loadTasks();
                    },
            child:
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.refresh),
            tooltip: 'Refresh Tasks',
            backgroundColor: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _loadTasks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 14.0),
                  ),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_tasks.isEmpty) {
      return const Center(child: Text('No tasks assigned'));
    }

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(_tasks[index]);
        },
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    try {
      final Color cardColor =
          task.status == 'completed'
              ? Colors.green.withOpacity(0.1)
              : task.status == 'in_progress'
              ? Colors.blue.withOpacity(0.1)
              : Colors.grey.withOpacity(0.1);

      final DateTime now = DateTime.now();
      final bool isOverdue =
          task.dueDate.isBefore(now) && task.status != 'completed';

      final DateFormat formatter = DateFormat('MMM dd, yyyy');
      final String formattedDueDate = formatter.format(task.dueDate);
      final String formattedAssignedDate = formatter.format(task.dateAssigned);

      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        color: cardColor,
        child: InkWell(
          onTap: () async {
            if (task.status != 'completed') {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkSubmissionScreen(task: task),
                ),
              );

              if (result == true) {
                _loadTasks();
              }
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        task.title,
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 3.0,
                      ),
                      decoration: BoxDecoration(
                        color:
                            task.status == 'completed'
                                ? Colors.green
                                : task.status == 'in_progress'
                                ? Colors.blue
                                : isOverdue
                                ? Colors.red
                                : Colors.orange,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        task.status == 'completed'
                            ? 'Completed'
                            : task.status == 'in_progress'
                            ? 'In Progress'
                            : isOverdue
                            ? 'Overdue'
                            : 'Pending',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 14.0),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: [
                    _buildInfoChip(
                      Icons.calendar_today,
                      'Assigned: $formattedAssignedDate',
                      Colors.blue,
                    ),
                    _buildInfoChip(
                      Icons.event,
                      'Due: $formattedDueDate',
                      isOverdue ? Colors.red : Colors.orange,
                    ),
                  ],
                ),
                if (task.status != 'completed')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => WorkSubmissionScreen(task: task),
                            ),
                          );

                          if (result == true) {
                            _loadTasks();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).primaryColor, // Purple
                          foregroundColor: Colors.white, // Ensure white text
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 10.0,
                          ),
                          minimumSize: const Size(120, 40), // Larger size
                          textStyle: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Submit Work'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error building task card: $e');
      return Card(
        margin: const EdgeInsets.only(bottom: 16.0),
        color: Colors.red.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Error Displaying Task',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8.0),
              Text('Task ID: ${task.id}'),
              const SizedBox(height: 8.0),
              Text(
                'Error: ${e.toString().substring(0, min(100, e.toString().length))}...',
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _loadTasks,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 14.0),
                ),
                child: const Text('Refresh Tasks'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.0, color: color),
          const SizedBox(width: 4.0),
          Text(label, style: TextStyle(fontSize: 10.0, color: color)),
        ],
      ),
    );
  }
}
