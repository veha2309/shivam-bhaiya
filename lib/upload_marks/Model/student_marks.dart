import 'package:flutter/material.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';

class StudentMarks {
  final String? studentId;
  String? testMarks;
  final String? admissionNo;
  final String? studentName;
  final String? rollNo;
  final String? groupName;
  final String? attendance;
  final String? ml;
  AttendanceParam? attendanceParam;
  TextEditingController? controller;

  // Constructor
  StudentMarks({
    this.studentId,
    this.testMarks,
    this.admissionNo,
    this.studentName,
    this.rollNo,
    this.groupName,
    this.attendance,
    this.ml,
    this.attendanceParam,
    this.controller,
  });

  // Method to convert JSON to Student object
  factory StudentMarks.fromJson(Map<String, dynamic> json) {
    return StudentMarks(
      studentId: json['studentid'],
      testMarks: json['testmarks'],
      admissionNo: json['admissionno'],
      studentName: json['studentname'],
      rollNo: json['rollno'],
      groupName: json['groupname'],
      attendance: json['attendance'],
      ml: json['ml'],
    );
  }

  // Method to convert Student object to JSON
  Map<String, dynamic>? toJson() {
    return {
      'studentid': studentId,
      'testmarks': testMarks,
      'admissionno': admissionNo,
      'studentname': studentName,
      'rollno': rollNo,
      'groupname': groupName,
      'attendance': attendance,
      'ml': ml,
    };
  }
}
