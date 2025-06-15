import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import '/login_screen.dart';
import '/register_screen.dart';
import '/profile_screen.dart';
import '/worker.dart';
import '/worker_provider.dart';
import '/task_list_screen.dart';
import '/work_submission_screen.dart';
import '/submission_history_screen.dart';
import '/edit_profile_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WorkerProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worker Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      home: const AuthenticationWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/tasks': (context) => const TaskListScreen(),
        '/submissions': (context) => const SubmissionHistoryScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
      },
    );
  }
}

class AuthenticationWrapper extends StatefulWidget {
  const AuthenticationWrapper({super.key});

  @override
  State<AuthenticationWrapper> createState() => _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends State<AuthenticationWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final workerData = prefs.getString('worker_data');

      if (workerData != null) {
        final worker = Worker.fromJson(jsonDecode(workerData));
        if (!mounted) return;
        context.read<WorkerProvider>().setWorker(worker);
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : const SizedBox(),
    );
  }
}
