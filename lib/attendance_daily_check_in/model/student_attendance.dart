import 'package:school_app/attendance_daily_check_in/model/attendance_save_response_model.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';

class StudentAttendance {
  final String? date;
  final String? attendanceValue;
  final String? classCode;
  final String? dateOfAttendance;
  final String? rollNo;
  final String? sectionCode;
  final int? slno;
  final String? studentId;
  final String? attendencestatus;
  final String? admissionNo;
  final String? studentName;
  String? attendance;
  final String? isUpdate;
  List<AttendanceParam>? attendanceStatusList;
  String? attendanceStatus;

  StudentAttendance({
    this.date,
    this.attendanceValue,
    this.classCode,
    this.dateOfAttendance,
    this.rollNo,
    this.sectionCode,
    this.slno,
    this.studentId,
    this.attendencestatus,
    this.attendanceStatus,
    this.admissionNo,
    this.studentName,
    this.attendance,
    this.isUpdate,
    this.attendanceStatusList,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      date: json['date'] ?? '',
      attendanceValue: json['attendanceValue'] ?? '',
      classCode: json['classCode'] ?? '',
      dateOfAttendance: json['dateOfAttendance'] ?? '',
      rollNo: json['rollNo']?.toString() ?? '',
      sectionCode: json['sectionCode'] ?? '',
      slno: json['slno'] ?? 0,
      studentId: json['studentId'] ?? '',
      attendencestatus: json['attendencestatus'] ?? '',
      admissionNo: json['admissionNo'] ?? '',
      studentName: json['studentName'] ?? '',
      attendance: json['attendance'] ?? '',
      isUpdate: json['isUpdate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date ?? '',
      'attendanceValue': attendanceValue ?? '',
      'classCode': classCode ?? '',
      'dateOfAttendance': dateOfAttendance ?? '',
      'rollNo': rollNo ?? '',
      'sectionCode': sectionCode ?? '',
      'slno': slno ?? 0,
      'studentId': studentId ?? '',
      'attendencestatus': attendencestatus ?? '',
      'admissionNo': admissionNo ?? '',
      'studentName': studentName ?? '',
      'attendance': attendance ?? '',
      'isUpdate': isUpdate ?? '',
    };
  }

  static List<StudentAttendance> fromJsonList(List<Map<String, dynamic>> json) {
    return json.map((json) => StudentAttendance.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(
      List<StudentAttendance> attendanceList) {
    return attendanceList.map((attendance) => attendance.toJson()).toList();
  }
}

List<AttendanceSaveResponseModel> convertToAttendanceSaveResponseModel(
    List<StudentAttendance> studentAttendances, String attendanceTakenBy) {
  return studentAttendances.map((student) {
    return AttendanceSaveResponseModel(
      studentId: student.studentId,
      sectionCode: student.sectionCode,
      attendance: student.attendance, // Passed as a parameter
      dateOfAttendance: student.dateOfAttendance,
      isUpdate: student.isUpdate,
    );
  }).toList();
}
