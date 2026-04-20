import 'dart:convert';

class UploadSubjectMarks {
  final String? showExpired;
  final String? activityCode;
  final String? activity;
  final String? subActivity;
  final String? subject;
  final String? subjectCode;
  final String? sessionCode;
  final String? startDate;
  final String? groupName;
  final String? maxMarks;
  final String? subActivityCode;
  final String? isGradeEnabled;
  final String? entryType;
  final String? exam;
  final String? freezeDate;
  final String? className;
  final String? marksStatus;
  final String? sessionName;
  final String? classCode;
  final String? sectionCode;
  final String? examDate;
  final String? examCode;
  final String? status;

  UploadSubjectMarks({
    this.showExpired,
    this.activityCode,
    this.activity,
    this.subActivity,
    this.subject,
    this.subjectCode,
    this.sessionCode,
    this.startDate,
    this.groupName,
    this.maxMarks,
    this.subActivityCode,
    this.isGradeEnabled,
    this.entryType,
    this.exam,
    this.freezeDate,
    this.className,
    this.marksStatus,
    this.sessionName,
    this.classCode,
    this.sectionCode,
    this.examDate,
    this.examCode,
    this.status,
  });

  factory UploadSubjectMarks.fromJson(Map<String, dynamic> json) {
    return UploadSubjectMarks(
      showExpired: json['show_expired'],
      activityCode: json['activitycode'],
      activity: json['activity'],
      subActivity: json['subactivity'],
      subject: json['subject'],
      subjectCode: json['subjectcode'],
      sessionCode: json['sessioncode'],
      startDate: json['startdate'],
      groupName: json['groupname'],
      maxMarks: json['maxmarks'],
      subActivityCode: json['subactivitycode'],
      isGradeEnabled: json['isgradeenabled'],
      entryType: json['entrytype'],
      exam: json['exam'],
      freezeDate: json['freezedate'],
      className: json['classname'],
      marksStatus: json['marks_status'],
      sessionName: json['sessionname'],
      classCode: json['classcode'],
      sectionCode: json['sectioncode'],
      examDate: json['examdate'],
      examCode: json['examcode'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'show_expired': showExpired,
      'activitycode': activityCode,
      'activity': activity,
      'subactivity': subActivity,
      'subject': subject,
      'subjectcode': subjectCode,
      'sessioncode': sessionCode,
      'startdate': startDate,
      'groupname': groupName,
      'maxmarks': maxMarks.toString(),
      'subactivitycode': subActivityCode,
      'isgradeenabled': isGradeEnabled.toString(),
      'entrytype': entryType,
      'exam': exam,
      'freezedate': freezeDate,
      'classname': className,
      'marks_status': marksStatus,
      'sessionname': sessionName,
      'classcode': classCode,
      'sectioncode': sectionCode,
      'examdate': examDate,
      'examcode': examCode,
      'status': status,
    };
  }

  static List<UploadSubjectMarks> fromJsonList(String jsonString) {
    final List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.map((item) => UploadSubjectMarks.fromJson(item)).toList();
  }

  static String toJsonList(List<UploadSubjectMarks> exams) {
    return jsonEncode(exams.map((exam) => exam.toJson()).toList());
  }
}
