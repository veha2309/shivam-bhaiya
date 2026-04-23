import 'package:flutter/material.dart';
import 'package:school_app/attendance_screen/model/attendance_model.dart';

class AttendanceViewModel extends ChangeNotifier {
  late DateTime _monthCursor;
  AttendanceMonthData? _data;
  DateTime? _selectedDate;

  AttendanceViewModel() {
    final now = DateTime.now();
    _monthCursor = DateTime(now.year, now.month, 1);
    _selectedDate = now;
    _loadData();
  }

  DateTime get monthCursor => _monthCursor;
  AttendanceMonthData? get data => _data;
  DateTime? get selectedDate => _selectedDate;

  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void nextMonth() {
    _monthCursor = DateTime(_monthCursor.year, _monthCursor.month + 1, 1);
    _loadData();
  }

  void prevMonth() {
    _monthCursor = DateTime(_monthCursor.year, _monthCursor.month - 1, 1);
    _loadData();
  }

  void setMonth(DateTime date) {
    _monthCursor = DateTime(date.year, date.month, 1);
    _loadData();
  }

  void _loadData() {
    // In a real app, this would call an API. For now, we mock it.
    _data = _mockMonth(_monthCursor);
    
    final daysInMonth = DateTime(_monthCursor.year, _monthCursor.month + 1, 0).day;
    if (_selectedDate == null ||
        _selectedDate!.year != _monthCursor.year ||
        _selectedDate!.month != _monthCursor.month ||
        _selectedDate!.day > daysInMonth) {
      _selectedDate = DateTime(_monthCursor.year, _monthCursor.month, 1);
    }
    notifyListeners();
  }

  AttendanceMonthData _mockMonth(DateTime monthCursor) {
    final daysInMonth = DateTime(monthCursor.year, monthCursor.month + 1, 0).day;
    final seed = (monthCursor.year * 100) + monthCursor.month;
    int nextRand(int mod) => ((seed * 1103515245 + 12345) ~/ 65536) % mod;

    final dayTypes = <AttendanceDayType>[];
    int present = 0;
    int absent = 0;
    int leave = 0;
    int working = 0;

    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(monthCursor.year, monthCursor.month, d);
      final isWeekend = date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
      if (isWeekend) {
        dayTypes.add(AttendanceDayType.holiday);
        continue;
      }

      working++;
      final roll = (d * 7 + nextRand(97)) % 100;
      if (roll < 82) {
        dayTypes.add(AttendanceDayType.present);
        present++;
      } else if (roll < 92) {
        dayTypes.add(AttendanceDayType.absent);
        absent++;
      } else {
        dayTypes.add(AttendanceDayType.leave);
        leave++;
      }
    }

    final recentAbsences = <RecentAbsenceItem>[];
    for (int i = daysInMonth; i >= 1 && recentAbsences.length < 2; i--) {
      final date = DateTime(monthCursor.year, monthCursor.month, i);
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) continue;
      final t = dayTypes[i - 1];
      if (t == AttendanceDayType.absent || t == AttendanceDayType.leave) {
        recentAbsences.add(
          RecentAbsenceItem(
            date: date,
            title: t == AttendanceDayType.leave ? 'Sick Leave' : 'Personal Work',
            subtitle: t == AttendanceDayType.leave ? 'Medical reason' : 'Family function',
            accent: t == AttendanceDayType.leave ? const Color(0xFF6366F1) : const Color(0xFFEF4444),
          ),
        );
      }
    }

    if (recentAbsences.isEmpty) {
      recentAbsences.addAll([
        RecentAbsenceItem(
          date: DateTime(monthCursor.year, monthCursor.month, (daysInMonth / 2).floor().clamp(1, daysInMonth)),
          title: 'Sick Leave',
          subtitle: 'Medical reason',
          accent: const Color(0xFF6366F1),
        ),
        RecentAbsenceItem(
          date: DateTime(monthCursor.year, monthCursor.month, (daysInMonth / 3).floor().clamp(1, daysInMonth)),
          title: 'Personal Work',
          subtitle: 'Family function',
          accent: const Color(0xFFEF4444),
        ),
      ]);
    }

    return AttendanceMonthData(
      dayTypes: dayTypes,
      totalWorkingDays: working,
      presentDays: present,
      absentDays: absent,
      leaveDays: leave,
      recentAbsences: recentAbsences,
    );
  }
}
