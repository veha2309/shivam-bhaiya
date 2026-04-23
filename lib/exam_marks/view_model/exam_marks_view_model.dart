import 'package:flutter/material.dart';

class SubjectMark {
  final String subject;
  final int obtained;
  final int total;
  final double percentage;
  final Color color;
  final IconData icon;

  SubjectMark({
    required this.subject,
    required this.obtained,
    required this.total,
    required this.percentage,
    required this.color,
    required this.icon,
  });
}

class ReportCard {
  final String title;
  final String session;
  final int percentage;
  final Color color;

  ReportCard({required this.title, required this.session, required this.percentage, required this.color});
}

class ExamMarksViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int get overallPercentage => 87;
  String get overallGrade => 'A';
  String get lastTermDiff => '+5%';
  
  int get totalMarksObtained => 870;
  int get totalMarksPossible => 1000;
  int get highestMarksPercentage => 95;
  int get classAveragePercentage => 78;

  List<SubjectMark> _subjectMarks = [
    SubjectMark(subject: 'Mathematics', obtained: 95, total: 100, percentage: 95, color: const Color(0xFF0EA5E9), icon: Icons.calculate_rounded),
    SubjectMark(subject: 'Science', obtained: 88, total: 100, percentage: 88, color: const Color(0xFFF59E0B), icon: Icons.science_rounded),
    SubjectMark(subject: 'English', obtained: 82, total: 100, percentage: 82, color: const Color(0xFF10B981), icon: Icons.edit_note_rounded),
    SubjectMark(subject: 'Social Studies', obtained: 80, total: 100, percentage: 80, color: const Color(0xFF8B5CF6), icon: Icons.public_rounded),
    SubjectMark(subject: 'Hindi', obtained: 78, total: 100, percentage: 78, color: const Color(0xFFF43F5E), icon: Icons.translate_rounded),
    SubjectMark(subject: 'Computer', obtained: 92, total: 100, percentage: 92, color: const Color(0xFF06B6D4), icon: Icons.laptop_chromebook_rounded),
  ];

  List<ReportCard> _previousReportCards = [
    ReportCard(title: 'Annual Exam', session: '2022-23', percentage: 85, color: const Color(0xFF10B981)),
    ReportCard(title: 'Term 2 Exam', session: '2022-23', percentage: 83, color: const Color(0xFFF59E0B)),
    ReportCard(title: 'Term 1 Exam', session: '2022-23', percentage: 81, color: const Color(0xFF8B5CF6)),
  ];

  List<SubjectMark> get subjectMarks => _subjectMarks;
  List<ReportCard> get previousReportCards => _previousReportCards;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    _isLoading = false;
    notifyListeners();
  }
}
