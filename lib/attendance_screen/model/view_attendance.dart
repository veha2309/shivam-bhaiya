class StudentViewAttendance {
  final String? studentId;
  final String? admissionNo;
  final String? studentName;
  final String? rollNo;
  final String? className;
  final String? currentDate;
  final String? currentDay;
  String? monthAttendance;
  String? totalAttendance;
  final String? monthPercentage;
  final String? totalPercentage;
  String? presentDaysMonth;
  String? totalWorkingDaysMonth;
  bool? showTotalDaysMonth;

  String? monthHighestAttendance;
  String? totalHighestAttendance;

  String? presentDaysTotal;
  String? totalWorkingDaysTotal;
  bool? showTotalDaysTotal;

  StudentViewAttendance({
    this.studentId,
    this.admissionNo,
    this.studentName,
    this.rollNo,
    this.className,
    this.currentDate,
    this.currentDay,
    this.monthAttendance,
    this.totalAttendance,
    this.monthPercentage,
    this.totalPercentage,
    this.presentDaysMonth,
    this.totalWorkingDaysMonth,
    this.showTotalDaysMonth,
    this.presentDaysTotal,
    this.totalWorkingDaysTotal,
    this.showTotalDaysTotal,
    this.monthHighestAttendance,
    this.totalHighestAttendance,
  });

  // Factory constructor to create a StudentViewAttendance object from a JSON map
  factory StudentViewAttendance.fromJson(Map<String, dynamic> json) {
    return StudentViewAttendance(
      studentId: json['studentId'],
      admissionNo: json['admissionNo'],
      studentName: json['studentName'],
      rollNo: json['rollNo'],
      className: json['className'],
      currentDate: json['currentDate'],
      currentDay: json['currentDay'],
      monthAttendance: json['monthAttendance'],
      totalAttendance: json['totalAttendance'],
      monthPercentage: json['monthPercentage'].toString(),
      totalPercentage: json['totalPercentage'].toString(),
    );
  }

  // Convert StudentAttendance object to JSON map
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'admissionNo': admissionNo,
      'studentName': studentName,
      'rollNo': rollNo,
      'className': className,
      'currentDate': currentDate,
      'currentDay': currentDay,
      'monthAttendance': monthAttendance,
      'totalAttendance': totalAttendance,
      'monthPercentage': monthPercentage,
      'totalPercentage': totalPercentage,
    };
  }

  // Factory method to parse a list of students from JSON
  static List<StudentViewAttendance> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => StudentViewAttendance.fromJson(json))
        .toList();
  }
}

class TeacherAttendanceStatus {
  final String classCode;
  final String attStatus;
  final String sectionCode;
  final String className;

  TeacherAttendanceStatus({
    required this.classCode,
    required this.attStatus,
    required this.sectionCode,
    required this.className,
  });

  factory TeacherAttendanceStatus.fromJson(Map<String, dynamic> json) {
    return TeacherAttendanceStatus(
      classCode: json['classCode'] ?? '',
      attStatus: json['attStatus'] ?? '',
      sectionCode: json['sectionCode'] ?? '',
      className: json['className'] ?? '',
    );
  }
}

class StudentDailyAttendance {
  final String studentId;
  final String studentName;
  final String className;
  final String specialAttendance;
  final String attendanceDate;
  final String attendance;

  StudentDailyAttendance({
    required this.studentId,
    required this.studentName,
    required this.className,
    required this.specialAttendance,
    required this.attendanceDate,
    required this.attendance,
  });

  factory StudentDailyAttendance.fromJson(Map<String, dynamic> json) {
    return StudentDailyAttendance(
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      className: json['className'] ?? '',
      specialAttendance: json['specialAttendance'] ?? '',
      attendanceDate: json['attendanceDate'] ?? '',
      attendance: json['attendance'] ?? '',
    );
  }
}
