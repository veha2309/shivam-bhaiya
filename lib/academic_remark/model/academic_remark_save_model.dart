class AcademicRemarkSaveModel {
  final String? studentId;
  final String? categoryCode;
  final String? sessionCode;
  final String? classCode;
  final String? sectionCode;
  final String? disciplineDate;
  final String? subjectCode;

  AcademicRemarkSaveModel({
    this.studentId,
    this.categoryCode,
    this.sessionCode,
    this.classCode,
    this.sectionCode,
    this.disciplineDate,
    this.subjectCode,
  });

  factory AcademicRemarkSaveModel.fromJson(Map<String, dynamic> json) {
    return AcademicRemarkSaveModel(
      studentId: json['studentId'],
      categoryCode: json['categoryCode'],
      sessionCode: json['sessionCode'],
      classCode: json['classCode'],
      sectionCode: json['sectionCode'],
      disciplineDate: json['disciplineDate'],
      subjectCode: json['subjectCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'categoryCode': categoryCode,
      'sessionCode': sessionCode,
      'classCode': classCode,
      'sectionCode': sectionCode,
      'disciplineDate': disciplineDate,
      'subjectCode': subjectCode,
    };
  }

  static List<AcademicRemarkSaveModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => AcademicRemarkSaveModel.fromJson(json))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(
      List<AcademicRemarkSaveModel> concerns) {
    return concerns.map((concern) => concern.toJson()).toList();
  }
}
