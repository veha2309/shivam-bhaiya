import 'dart:convert';

import 'package:school_app/discipline/model/discipline_data.dart';

class StudentDisciplineModel {
  int? sNo;
  final String? studentId;
  final String? studentName;
  DisciplineData? disciplineData;

  StudentDisciplineModel(
      {this.sNo = 0, this.studentId, this.studentName, this.disciplineData});

  factory StudentDisciplineModel.fromJson(Map<String, dynamic> json) {
    return StudentDisciplineModel(
      studentId: json['STUDENTID'],
      studentName: json['STUDENTNAME'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'STUDENTID': studentId,
      'STUDENTNAME': studentName,
    };
  }
}

class DisciplineModel {
  final List<StudentDisciplineModel>? studentData;
  final String? markedStatus;

  DisciplineModel({this.studentData, this.markedStatus});

  factory DisciplineModel.fromJson(Map<String, dynamic> json) {
    var list = jsonDecode(json['studentData']) as List;
    List<StudentDisciplineModel> students =
        list.map((i) => StudentDisciplineModel.fromJson(i)).toList();

    return DisciplineModel(
      studentData: students,
      markedStatus: json['markedStatus'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentData': jsonEncode(studentData?.map((s) => s.toJson()).toList()),
      'markedStatus': markedStatus,
    };
  }
}
