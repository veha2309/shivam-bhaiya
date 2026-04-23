import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/homework_screen/model/homework_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/utils/utils.dart';

enum HomeworkFilter { all, pending, submitted, overdue }

class HomeworkViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  HomeworkFilter _currentFilter = HomeworkFilter.all;
  HomeworkFilter get currentFilter => _currentFilter;

  List<HomeworkModel> _allMonthsHomework = [];
  List<HomeworkData> _filteredHomework = [];
  List<HomeworkData> get filteredHomework => _filteredHomework;

  // Stats
  int _totalCount = 0;
  int _submittedCount = 0;
  int _pendingCount = 0;
  int _overdueCount = 0;

  int get totalCount => _totalCount;
  int get submittedCount => _submittedCount;
  int get pendingCount => _pendingCount;
  int get overdueCount => _overdueCount;

  HomeworkViewModel() {
    fetchHomework(DateTime.now());
  }

  void setFilter(HomeworkFilter filter) {
    _currentFilter = filter;
    _applyFilterAndStats();
    notifyListeners();
  }

  void onDateSelected(DateTime date) {
    _selectedDate = date;
    _applyFilterAndStats();
    notifyListeners();
  }

  Future<void> fetchHomework(DateTime month) async {
    _isLoading = true;
    notifyListeners();

    final studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
    final monthYearString = "${month.month.toString().padLeft(2, '0')}-${month.year}";

    final response = await NetworkManager.instance.makeRequest(
      Endpoints.getStudentHomeWorkForMonth(studentId, monthYearString),
      (json) async => HomeworkModel.fromJsonList(json),
      method: HttpMethod.get,
    );

    if (response.success && response.data != null && response.data!.isNotEmpty) {
      _allMonthsHomework = response.data!;
      _applyFilterAndStats();
    } else {
      // Fallback Dummy Data
      _allMonthsHomework = [
        HomeworkModel(
          homeworkDate: "16-05-2024",
          homeworkData: [
            HomeworkData(subject: "Maths", homework: "Algebra & Equations", dueDate: "16 May 2024", checkStatus: "y", book: "NCERT", notebook: "Classwork"),
            HomeworkData(subject: "Science", homework: "Human Body System", dueDate: "18 May 2024", checkStatus: "n", book: "Science Plus", notebook: "Lab Manual"),
            HomeworkData(subject: "English", homework: "My Favourite Book", dueDate: "20 May 2024", checkStatus: "n", book: "Honeycomb", notebook: "Creative Writing"),
            HomeworkData(subject: "Social Studies", homework: "Indian Freedom Struggle", dueDate: "15 May 2024", checkStatus: "n", book: "Our Pasts III", notebook: "History"),
            HomeworkData(subject: "Science", homework: "Chemical Reactions", dueDate: "14 May 2024", checkStatus: "n", book: "Science Plus", notebook: "Lab Record"),
          ],
        ),
      ];
      _applyFilterAndStats();
    }

    _isLoading = false;
    notifyListeners();
  }

  void _applyFilterAndStats() {
    final List<HomeworkData> allData = _allMonthsHomework.expand((m) => m.homeworkData ?? <HomeworkData>[]).toList();
    
    // Calculate Stats for the current month/view
    _totalCount = allData.length;
    _submittedCount = allData.where((d) => d.checkStatus?.toLowerCase() == 'y').length;
    _overdueCount = allData.where((d) {
      if (d.checkStatus?.toLowerCase() == 'y') return false;
      if (d.dueDate == null) return false;
      try {
        final dueDate = formatAnyDateIntoDateTime(d.dueDate!);
        return dueDate.isBefore(DateTime.now());
      } catch (_) {
        return false;
      }
    }).length;
    _pendingCount = _totalCount - _submittedCount - _overdueCount;

    // Apply Filter
    switch (_currentFilter) {
      case HomeworkFilter.all:
        _filteredHomework = allData;
        break;
      case HomeworkFilter.pending:
        _filteredHomework = allData.where((d) {
          if (d.checkStatus?.toLowerCase() == 'y') return false;
          final dueDateStr = d.dueDate;
          if (dueDateStr == null) return true;
          try {
            final dueDate = formatAnyDateIntoDateTime(dueDateStr);
            return !dueDate.isBefore(DateTime.now());
          } catch (_) {
            return true;
          }
        }).toList();
        break;
      case HomeworkFilter.submitted:
        _filteredHomework = allData.where((d) => d.checkStatus?.toLowerCase() == 'y').toList();
        break;
      case HomeworkFilter.overdue:
        _filteredHomework = allData.where((d) {
          if (d.checkStatus?.toLowerCase() == 'y') return false;
          final dueDateStr = d.dueDate;
          if (dueDateStr == null) return false;
          try {
            final dueDate = formatAnyDateIntoDateTime(dueDateStr);
            return dueDate.isBefore(DateTime.now());
          } catch (_) {
            return false;
          }
        }).toList();
        break;
    }
  }
}