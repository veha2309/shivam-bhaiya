import 'package:flutter/material.dart';

enum AttendanceDayType { present, absent, leave, holiday, notApplicable }

class RecentAbsenceItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final Color accent;

  const RecentAbsenceItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

class AttendanceMonthData {
  final List<AttendanceDayType> dayTypes;
  final int totalWorkingDays;
  final int presentDays;
  final int absentDays;
  final int leaveDays;
  final List<RecentAbsenceItem> recentAbsences;

  const AttendanceMonthData({
    required this.dayTypes,
    required this.totalWorkingDays,
    required this.presentDays,
    required this.absentDays,
    required this.leaveDays,
    required this.recentAbsences,
  });

  int get totalMarkedDays => presentDays + absentDays + leaveDays;

  int get attendancePercentage => totalMarkedDays == 0
      ? 0
      : ((presentDays / totalMarkedDays) * 100).round();
}
