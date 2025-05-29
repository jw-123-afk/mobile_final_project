import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'api_service.dart';
import 'task.dart';
import 'worker_provider.dart';

class WorkSubmissionScreen extends StatefulWidget {
  final Task task;

  const WorkSubmissionScreen({Key? key, required this.task}) : super(key: key);

  @override
  _WorkSubmissionScreenState createState() => _WorkSubmissionScreenState();
}

class _WorkSubmissionScreenState extends State<WorkSubmissionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _submissionController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _submissionController.dispose();
    super.dispose();
  }

  Future<void> _submitWork() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final worker = context.read<WorkerProvider>().worker;
    if (worker == null) {
      setState(() {
        _isSubmitting = false;
        _errorMessage = 'Worker information not found';
      });
      return;
    }

    try {
      await _apiService.submitWork(
        workId: widget.task.id,
        workerId: worker.id,
        submissionText: _submissionController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work submitted successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('MMM dd, yyyy');
    final String formattedDueDate = formatter.format(widget.task.dueDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Work'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.task.title,
                        style: const TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(widget.task.description),
                      const SizedBox(height: 16.0),
                      Row(
                        children: [
                          const Icon(
                            Icons.event,
                            size: 16.0,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 4.0),
                          Text(
                            'Due: $formattedDueDate',
                            style: const TextStyle(color: Colors.orange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                'Submission Details',
                style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8.0),
              TextFormField(
                controller: _submissionController,
                decoration: const InputDecoration(
                  hintText: 'Describe the work you have completed...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter submission details';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitWork,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor, // Purple
                    foregroundColor: Colors.white, // White text
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    minimumSize: const Size(
                      double.infinity,
                      48.0,
                    ), // Taller button
                    textStyle: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Submit Work'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
