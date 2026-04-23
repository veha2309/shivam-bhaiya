import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/my_discipline_passbook/model/discipline_transaction_model.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/utils/utils.dart';

class DisciplineActivity {
  final String title;
  final String description;
  final String teacher;
  final String time;
  final String date;
  final int points;
  final bool isPositive;

  DisciplineActivity({
    required this.title,
    required this.description,
    required this.teacher,
    required this.time,
    required this.date,
    required this.points,
    required this.isPositive,
  });
}

class NegativeCategory {
  final String label;
  final int count;
  final IconData icon;

  NegativeCategory({required this.label, required this.count, required this.icon});
}

class DisciplineViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int _totalPoints = 0;
  int _positivePoints = 0;
  int _negativePoints = 0;

  int get totalPoints => _totalPoints;
  int get positivePoints => _positivePoints;
  int get negativePoints => _negativePoints;

  String _selectedFilter = 'All Records';
  String get selectedFilter => _selectedFilter;

  List<DisciplineActivity> _activities = [];

  List<NegativeCategory> _negativeCategories = [
    NegativeCategory(label: 'Dress Not Proper', count: 2, icon: Icons.checkroom_rounded),
    NegativeCategory(label: 'Nails Not Clean', count: 1, icon: Icons.pan_tool_alt_rounded),
    NegativeCategory(label: 'Class Bunk', count: 1, icon: Icons.transfer_within_a_station_rounded),
    NegativeCategory(label: 'ID Card Missing', count: 0, icon: Icons.badge_rounded),
  ];

  List<DisciplineActivity> get filteredActivities {
    if (_selectedFilter == 'Positive') {
      return _activities.where((a) => a.isPositive).toList();
    } else if (_selectedFilter == 'Negative') {
      return _activities.where((a) => !a.isPositive).toList();
    }
    return _activities;
  }

  List<NegativeCategory> get negativeCategories => _negativeCategories;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    final user = AuthViewModel.instance.getLoggedInUser();
    final studentId = user?.username ?? "";
    // Using current session year as dummy or from user data if available
    final sessionCode = "2024"; 

    final response = await NetworkManager.instance.makeRequest(
      Endpoints.getStudentDisciplineDetails(sessionCode, studentId),
      (json) async => (json as List).map((i) => DisciplineTransactionModel.fromJson(i)).toList(),
      method: HttpMethod.get,
    );

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      _activities = response.data!.map((t) {
        final debit = int.tryParse(t.debit ?? "0") ?? 0;
        final credit = int.tryParse(t.credit ?? "0") ?? 0;
        return DisciplineActivity(
          title: t.reason ?? "N/A",
          description: t.actionTaken ?? "Discipline Entry",
          teacher: t.name ?? "Teacher",
          time: "N/A",
          date: t.entryDate ?? "N/A",
          points: debit > 0 ? debit : credit,
          isPositive: credit > 0,
        );
      }).toList();

      _positivePoints = _activities.where((a) => a.isPositive).fold(0, (sum, a) => sum + a.points);
      _negativePoints = _activities.where((a) => !a.isPositive).fold(0, (sum, a) => sum + a.points);
      _totalPoints = _positivePoints - _negativePoints;
    } else {
      // Fallback Dummy Data
      _totalPoints = 230;
      _positivePoints = 280;
      _negativePoints = 50;
      _activities = [
        DisciplineActivity(title: 'Helping a classmate', description: 'Good behavior and teamwork', teacher: 'Mr. Sharma', time: '10:30 AM', date: '16 May 2024', points: 10, isPositive: true),
        DisciplineActivity(title: 'Dress Not Proper', description: 'School uniform not as per rules', teacher: 'Ms. Priya', time: '11:15 AM', date: '15 May 2024', points: 10, isPositive: false),
        DisciplineActivity(title: 'Class Bunk', description: 'Absent during class without permission', teacher: 'Mr. Verma', time: '09:40 AM', date: '14 May 2024', points: 20, isPositive: false),
        DisciplineActivity(title: 'Participated in Quiz', description: 'Actively participated in inter-class quiz', teacher: 'Mr. Sharma', time: '02:20 PM', date: '13 May 2024', points: 15, isPositive: true),
        DisciplineActivity(title: 'Nails Not Clean', description: 'Nails not trimmed and clean', teacher: 'Ms. Priya', time: '12:05 PM', date: '12 May 2024', points: 5, isPositive: false),
      ];
    }

    _isLoading = false;
    notifyListeners();
  }
}
