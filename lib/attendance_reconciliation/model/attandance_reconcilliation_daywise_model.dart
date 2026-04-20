class AttandanceReconcilliationDaywiseModel {
  final String? date;
  final String? studentId;
  final String? day;
  final String? holiday;
  final String? status;
  final String? attendanceValue;
  final String? attendance;

  AttandanceReconcilliationDaywiseModel({
    this.date,
    this.studentId,
    this.day,
    this.holiday,
    this.status,
    this.attendance,
    this.attendanceValue,
  });

  // Factory method to create an instance from a JSON object
  factory AttandanceReconcilliationDaywiseModel.fromJson(
      Map<String, dynamic> json) {
    return AttandanceReconcilliationDaywiseModel(
      date: json['date'],
      studentId: json['studentId'],
      day: json['day'],
      holiday: json['holiday'] ?? "",
      status: json['status'],
      attendanceValue: json['attendanceValue'],
      attendance: json['attendance'],
    );
  }

  // Convert instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'studentId': studentId,
      'day': day,
      'holiday': holiday,
      'status': status,
      'attendanceValue': attendanceValue,
      'attendance': attendance,
    };
  }

  @override
  String toString() {
    return 'Attendance(date: $date, studentId: $studentId, day: $day, holiday: $holiday, status: $status)';
  }
}
