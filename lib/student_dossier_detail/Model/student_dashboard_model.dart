import 'dart:convert';

class StudentDashboardModel {
  final String? studentId;
  final String? studentName;
  final String? admissionNo;
  final String? dob;
  final String? doa;
  final String? className;
  final String? fatherName;
  final String? motherName;
  final String? fContactNo;
  final String? mContactNo;
  final String? fMobileNo;
  final String? mMobileNo;
  final String? fEmail;
  final String? mEmailId;
  final String? fReligion;
  final String? mReligion;
  final String? fCaste;
  final String? mCaste;
  final String? routeName;
  final String? studentImage;
  final String? fatherImage;
  final String? motherImage;

  StudentDashboardModel({
    this.studentId,
    this.studentName,
    this.admissionNo,
    this.dob,
    this.doa,
    this.className,
    this.fatherName,
    this.motherName,
    this.fContactNo,
    this.mContactNo,
    this.fMobileNo,
    this.mMobileNo,
    this.fEmail,
    this.mEmailId,
    this.fReligion,
    this.mReligion,
    this.fCaste,
    this.mCaste,
    this.routeName,
    this.studentImage,
    this.fatherImage,
    this.motherImage,
  });

  // Factory method to create an instance from JSON
  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      studentId: json['studentId'],
      studentName: json['studentName']?.trim(),
      admissionNo: json['admissionNo'],
      dob: json['dob'],
      doa: json['doa'],
      className: json['className'],
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      fContactNo: json['fContactNo'],
      mContactNo: json['mContactNo'],
      fMobileNo: json['fMobileNo'],
      mMobileNo: json['mMobileNo'],
      fEmail: json['fEmail'],
      mEmailId: json['mEmailId'],
      fReligion: json['fReligion'],
      mReligion: json['mReligion'],
      fCaste: json['fCaste'],
      mCaste: json['mCaste'],
      routeName: json['routeName'],
      studentImage: json['studentImage'],
      fatherImage: json['fatherImage'],
      motherImage: json['motherImage'],
    );
  }

  // Convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'admissionNo': admissionNo,
      'dob': dob,
      'doa': doa,
      'className': className,
      'fatherName': fatherName,
      'motherName': motherName,
      'fContactNo': fContactNo,
      'mContactNo': mContactNo,
      'fMobileNo': fMobileNo,
      'mMobileNo': mMobileNo,
      'fEmail': fEmail,
      'mEmailId': mEmailId,
      'fReligion': fReligion,
      'mReligion': mReligion,
      'fCaste': fCaste,
      'mCaste': mCaste,
      'routeName': routeName,
      'studentImage': studentImage,
      'fatherImage': fatherImage,
      'motherImage': motherImage,
    };
  }

  // Create a list of students from JSON array
  static List<StudentDashboardModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList
        .map((json) => StudentDashboardModel.fromJson(json))
        .toList();
  }
}
