import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:school_app/academic_concerns/model/academic_concern_category_model.dart';

class SearchStudentModel {
  String? studentId;
  String studentName;
  String? sectionCode;
  String? className;
  String? classCode;
  String? fatherName;
  String? gender;
  String? admissionNo;
  String? motherName;
  int? sNo;
  List<AcademicConcernCategoryModel>? categories;
  Set<String>? cardCategoryCode;
  TextEditingController? cardNoController;
  TextEditingController? remarkController;
  bool suspension;
  TextEditingController? fromDate;
  TextEditingController? toDate;

  SearchStudentModel({
    this.studentId,
    required this.studentName,
    this.sectionCode,
    this.className,
    this.classCode,
    this.fatherName,
    this.gender,
    this.admissionNo,
    this.motherName,
    this.sNo,
    this.categories,
    this.cardNoController,
    this.remarkController,
    this.fromDate,
    this.toDate,
    this.suspension = false,
    this.cardCategoryCode,
  });

  factory SearchStudentModel.fromJson(Map<String, dynamic> json) {
    return SearchStudentModel(
      studentId: json['studentId'],
      studentName: json['studentName'],
      className: json['className'],
      classCode: json['classCode'],
      fatherName: json['fatherName'],
      gender: json['gender'],
      admissionNo: json['admissionNo'],
      motherName: json['motherName'],
      sectionCode: json['sectionCode'],
      sNo: json['sNo'],
      categories: json['categories'] != null
          ? List<AcademicConcernCategoryModel>.from(json['categories']
              .map((x) => AcademicConcernCategoryModel.fromJson(x)))
          : null,
      remarkController: json['remarkController'] != null
          ? TextEditingController(text: json['remarkController'])
          : null,
      cardNoController: TextEditingController(),
      toDate: TextEditingController(),
      fromDate: TextEditingController(),
      suspension: false,
      cardCategoryCode: <String>{},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'className': className,
      'classCode': classCode,
      'fatherName': fatherName,
      'gender': gender,
      'admissionNo': admissionNo,
      'motherName': motherName,
      'sectionCode': sectionCode,
      'sNo': sNo,
      'categories': categories?.map((x) => x.toJson()).toList(),
      'remarkController': remarkController?.text,
    };
  }

  static List<SearchStudentModel> fromJsonList(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => SearchStudentModel.fromJson(json)).toList();
  }

  static String toJsonList(List<SearchStudentModel> students) {
    final List<Map<String, dynamic>> jsonList =
        students.map((s) => s.toJson()).toList();
    return json.encode(jsonList);
  }
}
