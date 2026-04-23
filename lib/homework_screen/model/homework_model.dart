import 'dart:convert';

class HomeworkModel {
  final String? homeworkDate;
  final List<HomeworkData>? homeworkData;

  HomeworkModel({this.homeworkDate, this.homeworkData});

  factory HomeworkModel.fromJson(Map<String, dynamic> json) {
    return HomeworkModel(
      homeworkDate: json['homeworkDate'] as String?,
      // Fix: Only use jsonDecode if 'homeworkData' is actually a String. 
      // If the API returns a List directly, remove jsonDecode.
      homeworkData: json['homeworkData'] != null
          ? (json['homeworkData'] is String 
              ? jsonDecode(json['homeworkData']) as List 
              : json['homeworkData'] as List)
              .map((data) => HomeworkData.fromJson(data as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'homeworkDate': homeworkDate,
      'homeworkData': homeworkData != null
          ? jsonEncode(homeworkData!.map((e) => e.toJson()).toList())
          : null,
    };
  }

  static List<HomeworkModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => HomeworkModel.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<HomeworkModel> concerns) {
    return concerns.map((concern) => concern.toJson()).toList();
  }
}

// Model for Homework Data
class HomeworkData {
  final String? homework;
  final String? subject;
  final String? dueDate;
  final String? testDate;
  final String? checkStatus;
  final String? checkDate;
  final String? book;
  final String? notebook;
  final String? documentName;
  final String? fileName;
  final bool isDeleted;

  HomeworkData({
    required this.homework,
    required this.subject,
    this.dueDate,
    this.testDate,
    required this.checkStatus,
    this.checkDate,
    required this.book,
    required this.notebook,
    this.documentName,
    this.fileName,
    this.isDeleted = false,
  });

  factory HomeworkData.fromJson(Map<String, dynamic> json) {
    return HomeworkData(
      homework: json['HOMEWORK'],
      subject: json['SUBJECT'],
      dueDate: json['DUEDATE'],
      testDate: json['TESTDATE'],
      checkStatus: json['CHECKSTATUS'],
      checkDate: json['CHECKDATE'],
      book: json['BOOK'],
      notebook: json['NOTEBOOK'],
      documentName: json['DOCUMENTNAME'],
      fileName: json['FILENAME'],
      isDeleted: (json['ISDELETED'] ?? json['isDeleted'] ?? false) == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'HOMEWORK': homework,
      'SUBJECT': subject,
      'DUEDATE': dueDate,
      'TESTDATE': testDate,
      'CHECKSTATUS': checkStatus,
      'CHECKDATE': checkDate,
      'BOOK': book,
      'NOTEBOOK': notebook,
      'DOCUMENTNAME': documentName,
      'FILENAME': fileName,
      'ISDELETED': isDeleted,
    };
  }
}
