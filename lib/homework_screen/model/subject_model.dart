import 'package:flutter/material.dart';

class SubjectModel {
  final String? subjectCode;
  final String? subjectName;
  DateTime? dueDate;
  TextEditingController? homeworkText;

  SubjectModel({
    this.subjectCode,
    this.subjectName,
    this.dueDate,
    this.homeworkText,
  });

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectCode: json['subjectCode'],
      subjectName: json['subjectName'],
      homeworkText: json['homeworkText'],
    );
  }

  static List<SubjectModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SubjectModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'subjectCode': subjectCode,
      'subjectName': subjectName,
      'homeworkText': homeworkText,
      'dueDate': dueDate?.toIso8601String(),
    };
  }
}
