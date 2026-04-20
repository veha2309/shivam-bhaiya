class SaveUpdateStudentDisciplineData {
  String? disciplineCardId;
  String? studentId;
  String? categoryCode;
  String? sessionCode;
  String? classCode;
  String? sectionCode;
  String? disciplineDate;
  String? actionTaken;
  String? suspensionStr;
  String? fromDate;
  String? toDate;
  String? createdBy;
  String? cardNo;

  SaveUpdateStudentDisciplineData(
      {this.disciplineCardId,
      this.studentId,
      this.categoryCode,
      this.sessionCode,
      this.classCode,
      this.sectionCode,
      this.disciplineDate,
      this.actionTaken,
      this.suspensionStr,
      this.fromDate,
      this.toDate,
      this.createdBy,
      this.cardNo});

  factory SaveUpdateStudentDisciplineData.fromJson(Map<String, dynamic> json) {
    return SaveUpdateStudentDisciplineData(
      disciplineCardId: json['disciplineCardId']?.toString(),
      studentId: json['studentId']?.toString(),
      categoryCode: json['categoryCode']?.toString(),
      sessionCode: json['sessionCode']?.toString(),
      classCode: json['classCode']?.toString(),
      sectionCode: json['sectionCode']?.toString(),
      disciplineDate: json['disciplineDate']?.toString(),
      actionTaken: json['actionTaken']?.toString(),
      suspensionStr: json['suspensionStr']?.toString(),
      fromDate: json['fromDate']?.toString(),
      toDate: json['toDate']?.toString(),
      createdBy: json['createdBy']?.toString(),
      cardNo: json['cardNo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'disciplineCardId': disciplineCardId ?? '',
      'studentId': studentId ?? '',
      'categoryCode': categoryCode ?? '',
      'sessionCode': sessionCode ?? '',
      'classCode': classCode ?? '',
      'sectionCode': sectionCode ?? '',
      'disciplineDate': disciplineDate ?? '',
      'actionTaken': actionTaken ?? '',
      'suspensionStr': suspensionStr ?? '',
      'fromDate': fromDate ?? '',
      'toDate': toDate ?? '',
      'createdBy': createdBy ?? '',
      'cardNo': cardNo ?? ''
    };
  }

  static List<SaveUpdateStudentDisciplineData> fromJsonList(
      List<Map<String, dynamic>> jsonList) {
    return jsonList
        .map((json) => SaveUpdateStudentDisciplineData.fromJson(json))
        .toList();
  }

  static List<Map<String, dynamic>> toJsonList(
      List<SaveUpdateStudentDisciplineData> dataList) {
    final List<Map<String, dynamic>> jsonList =
        dataList.map((data) => data.toJson()).toList();
    return jsonList;
  }

  @override
  String toString() {
    return 'SaveUpdateStudentDisciplineData(disciplineCardId: $disciplineCardId, studentId: $studentId, categoryCode: $categoryCode, sessionCode: $sessionCode, classCode: $classCode, sectionCode: $sectionCode, disciplineDate: $disciplineDate, actionTaken: $actionTaken, suspensionStr: $suspensionStr, fromDate: $fromDate, toDate: $toDate, createdBy: $createdBy)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SaveUpdateStudentDisciplineData &&
        other.disciplineCardId == disciplineCardId &&
        other.studentId == studentId &&
        other.categoryCode == categoryCode &&
        other.sessionCode == sessionCode &&
        other.classCode == classCode &&
        other.sectionCode == sectionCode &&
        other.disciplineDate == disciplineDate &&
        other.actionTaken == actionTaken &&
        other.suspensionStr == suspensionStr &&
        other.fromDate == fromDate &&
        other.toDate == toDate &&
        other.createdBy == createdBy &&
        other.cardNo == cardNo;
  }

  @override
  int get hashCode {
    return disciplineCardId.hashCode ^
        studentId.hashCode ^
        categoryCode.hashCode ^
        sessionCode.hashCode ^
        classCode.hashCode ^
        sectionCode.hashCode ^
        disciplineDate.hashCode ^
        actionTaken.hashCode ^
        suspensionStr.hashCode ^
        fromDate.hashCode ^
        toDate.hashCode ^
        createdBy.hashCode ^
        cardNo.hashCode;
  }

  SaveUpdateStudentDisciplineData copyWith({
    String? disciplineCardId,
    String? studentId,
    String? categoryCode,
    String? sessionCode,
    String? classCode,
    String? sectionCode,
    String? disciplineDate,
    String? actionTaken,
    String? suspensionStr,
    String? fromDate,
    String? toDate,
    String? createdBy,
    String? cardNo,
  }) {
    return SaveUpdateStudentDisciplineData(
      disciplineCardId: disciplineCardId ?? this.disciplineCardId,
      studentId: studentId ?? this.studentId,
      categoryCode: categoryCode ?? this.categoryCode,
      sessionCode: sessionCode ?? this.sessionCode,
      classCode: classCode ?? this.classCode,
      sectionCode: sectionCode ?? this.sectionCode,
      disciplineDate: disciplineDate ?? this.disciplineDate,
      actionTaken: actionTaken ?? this.actionTaken,
      suspensionStr: suspensionStr ?? this.suspensionStr,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      createdBy: createdBy ?? this.createdBy,
      cardNo: cardNo ?? this.cardNo,
    );
  }
}
