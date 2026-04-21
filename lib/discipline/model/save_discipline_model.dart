import 'dart:convert';

class SaveDisciplineModel {
  String? studentId;
  String? classCode;
  String? sectionCode;
  String? sessionCode;
  String? disciplineCode;
  String? remark;
  String? remedial;
  String? entryDate;
  String? marks;
  String? createdBy;

  SaveDisciplineModel({
    this.studentId,
    this.classCode,
    this.sectionCode,
    this.sessionCode,
    this.disciplineCode,
    this.remark,
    this.remedial,
    this.entryDate,
    this.marks,
    this.createdBy,
  });

  factory SaveDisciplineModel.fromJson(Map<String, dynamic> json) {
    return SaveDisciplineModel(
      studentId: json['studentId'],
      classCode: json['classCode'],
      sectionCode: json['sectionCode'],
      sessionCode: json['sessionCode'],
      disciplineCode: json['disciplineCode'],
      remark: json['remark'],
      remedial: json['remedial'],
      entryDate: json['entryDate'],
      marks: json['marks'],
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'classCode': classCode,
      'sectionCode': sectionCode,
      'sessionCode': sessionCode,
      'disciplineCode': disciplineCode,
      'remark': remark,
      'remedial': remedial,
      'entryDate': entryDate,
      'marks': marks,
      'createdBy': createdBy,
    };
  }

  static List<SaveDisciplineModel>? fromJsonList(String jsonString) {
    final List<dynamic>? jsonList = json.decode(jsonString);
    return jsonList?.map((json) => SaveDisciplineModel.fromJson(json)).toList();
  }

  static String toJsonList(List<SaveDisciplineModel> disciplineList) {
    return json.encode(
        disciplineList.map((discipline) => discipline.toJson()).toList());
  }
}
