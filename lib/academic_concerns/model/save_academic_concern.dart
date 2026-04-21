class SaveAcademicConcern {
  final String? studentId;
  final String? disciplineCode;
  final String? remark;
  final String? createdBy;
  final String? subjectCode;

  SaveAcademicConcern({
    required this.studentId,
    required this.disciplineCode,
    required this.remark,
    required this.createdBy,
    required this.subjectCode,
  });

  factory SaveAcademicConcern.fromJson(Map<String, dynamic> json) {
    return SaveAcademicConcern(
      studentId: json['studentId'] as String,
      disciplineCode: json['disciplineCode'] as String,
      remark: json['remark'] as String,
      createdBy: json['createdBy'] as String,
      subjectCode: json['subjectCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'disciplineCode': disciplineCode,
      'remark': remark,
      'createdBy': createdBy,
      'subjectCode': subjectCode,
    };
  }

  static List<SaveAcademicConcern> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => SaveAcademicConcern.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(
      List<SaveAcademicConcern> concerns) {
    return concerns.map((concern) => concern.toJson()).toList();
  }
}
