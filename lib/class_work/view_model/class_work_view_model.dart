import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/curriculum_screen/model/curriculam.dart';
import 'package:school_app/network_manager/network_manager.dart';

class ClassWorkItem {
  final String subject;
  final String topic;
  final String teacher;
  final String time;
  final String status; // 'Completed', 'Pending'
  final Color color;
  final IconData icon;

  ClassWorkItem({
    required this.subject,
    required this.topic,
    required this.teacher,
    required this.time,
    required this.status,
    required this.color,
    required this.icon,
  });
}

class PreviousClassWork {
  final String date;
  final String subject;
  final String topic;
  final String status;
  final Color color;

  PreviousClassWork({
    required this.date,
    required this.subject,
    required this.topic,
    required this.status,
    required this.color,
  });
}

class ClassWorkViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _selectedSubject = 'All Subjects';
  String get selectedSubject => _selectedSubject;

  List<ClassWorkItem> _classWork = [];
  List<PreviousClassWork> _previousClassWork = [];

  List<ClassWorkItem> get classWork => _selectedSubject == 'All Subjects' 
      ? _classWork 
      : _classWork.where((item) => item.subject == _selectedSubject).toList();

  List<PreviousClassWork> get previousClassWork => _previousClassWork;

  void setSubject(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
    final response = await NetworkManager.instance.makeRequest(
      Endpoints.getStudentCurriculam(studentId),
      (json) async => Curriculam.fromJsonList(json),
      method: HttpMethod.get,
    );

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      _classWork = response.data!.map((c) {
        return ClassWorkItem(
          subject: c.subjectName ?? "General",
          topic: c.remarks ?? "Lesson Plan",
          teacher: "Teacher",
          time: "09:00 AM",
          status: "Completed",
          color: const Color(0xFF0EA5E9),
          icon: Icons.assignment_rounded,
        );
      }).toList();
      _previousClassWork = _classWork.map((c) => PreviousClassWork(date: "Yesterday", subject: c.subject, topic: c.topic, status: "Completed", color: c.color)).toList();
    } else {
      // Fallback Dummy Data
      _classWork = [
        ClassWorkItem(subject: 'Mathematics', topic: 'Linear Equations in One Variable', teacher: 'Mr. Sharma', time: '08:30 AM', status: 'Completed', color: const Color(0xFF0EA5E9), icon: Icons.calculate_rounded),
        ClassWorkItem(subject: 'Science', topic: 'Acids, Bases and Salts', teacher: 'Ms. Priya', time: '09:30 AM', status: 'Pending', color: const Color(0xFFF59E0B), icon: Icons.science_rounded),
        ClassWorkItem(subject: 'English', topic: 'The Last Leaf – Summary', teacher: 'Mr. David', time: '10:30 AM', status: 'Completed', color: const Color(0xFF10B981), icon: Icons.edit_note_rounded),
        ClassWorkItem(subject: 'Social Studies', topic: 'The Mughal Empire', teacher: 'Mr. Verma', time: '11:30 AM', status: 'Completed', color: const Color(0xFF8B5CF6), icon: Icons.public_rounded),
      ];
      _previousClassWork = [
        PreviousClassWork(date: '16 May 2024', subject: 'Science', topic: 'Force and Laws of Motion', status: 'Completed', color: const Color(0xFFF59E0B)),
        PreviousClassWork(date: '15 May 2024', subject: 'Mathematics', topic: 'Understanding Quadrilaterals', status: 'Completed', color: const Color(0xFF0EA5E9)),
        PreviousClassWork(date: '14 May 2024', subject: 'English', topic: 'Notice Writing Format', status: 'Completed', color: const Color(0xFF10B981)),
        PreviousClassWork(date: '13 May 2024', subject: 'Social Studies', topic: 'Resources and Development', status: 'Completed', color: const Color(0xFF8B5CF6)),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }
}
