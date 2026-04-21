import 'dart:convert';

class StudentDossier {
  final String? studentId;
  final String? studentName;
  final String? fatherName;
  final String? motherName;
  final String? classCode;
  final String? sectionCode;
  final String? emailId;
  final String? mobileNo;
  final String? transport;
  final String? feeConcession;
  final String? feeStatus;
  final String? status;
  final String? imageName;
  final String? className;
  final String? sectionName;

  StudentDossier({
    this.studentId,
    this.studentName,
    this.fatherName,
    this.motherName,
    this.classCode,
    this.sectionCode,
    this.emailId,
    this.mobileNo,
    this.transport,
    this.feeConcession,
    this.feeStatus,
    this.status,
    this.imageName,
    this.className,
    this.sectionName,
  });

  // Factory method to create an instance from JSON
  factory StudentDossier.fromJson(Map<String, dynamic> json) {
    return StudentDossier(
      studentId: json['studentId'],
      studentName: json['studentName']?.trim(),
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      classCode: json['classCode'],
      sectionCode: json['sectionCode'],
      emailId: json['emailId'],
      mobileNo: json['mobileNo'],
      transport: json['transport'],
      feeConcession: json['feeConcession'],
      feeStatus: json['feeStatus'],
      status: json['status'],
      imageName: json['imageName'],
      className: json['className'],
      sectionName: json['sectionName'],
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'fatherName': fatherName,
      'motherName': motherName,
      'classCode': classCode,
      'sectionCode': sectionCode,
      'emailId': emailId,
      'mobileNo': mobileNo,
      'transport': transport,
      'feeConcession': feeConcession,
      'feeStatus': feeStatus,
      'status': status,
      'imageName': imageName,
      'className': className,
      'sectionName': sectionName,
    };
  }

  // Create a list of students from JSON array
  static List<StudentDossier> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => StudentDossier.fromJson(json)).toList();
  }
}
