class StudentDisciplineCard {
  final String? classCode;
  final String? sessionCode;
  final String? classSection;
  final String? toDate;
  final String? rollNo;
  final String? sectionCode;
  final String? creationDate;
  final String? cardNo;
  final String? studentId;
  final String? fromDate;
  final String? actionTaken;
  final String? createdBy;
  final String? studentName;
  final String? cardId;
  final String? disciplineCode;
  final String? disciplineDate;
  final String? suspension;
  final String? sessionName;
  final String? disciplineName;

  StudentDisciplineCard({
    this.classCode,
    this.sessionCode,
    this.classSection,
    this.toDate,
    this.rollNo,
    this.sectionCode,
    this.creationDate,
    this.cardNo,
    this.studentId,
    this.fromDate,
    this.actionTaken,
    this.createdBy,
    this.studentName,
    this.cardId,
    this.disciplineCode,
    this.disciplineDate,
    this.suspension,
    this.sessionName,
    this.disciplineName,
  });

  factory StudentDisciplineCard.fromJson(Map<String, dynamic> json) {
    return StudentDisciplineCard(
      classCode: json['classCode']?.toString(),
      sessionCode: json['sessionCode']?.toString(),
      classSection: json['classSection']?.toString(),
      toDate: json['toDate']?.toString(),
      rollNo: json['rollNo']?.toString(),
      sectionCode: json['sectionCode']?.toString(),
      creationDate: json['creationDate']?.toString(),
      cardNo: json['cardNo']?.toString(),
      studentId: json['studentId']?.toString(),
      fromDate: json['fromDate']?.toString(),
      actionTaken: json['actionTaken']?.toString(),
      createdBy: json['createdBy']?.toString(),
      studentName: json['studentName']?.toString(),
      cardId: json['cardId']?.toString(),
      disciplineCode: json['disciplineCode']?.toString(),
      disciplineDate: json['disciplineDate']?.toString(),
      suspension: json['suspension']?.toString(),
      sessionName: json['sessionName']?.toString(),
      disciplineName: json['disciplineName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classCode': classCode,
      'sessionCode': sessionCode,
      'classSection': classSection,
      'toDate': toDate,
      'rollNo': rollNo,
      'sectionCode': sectionCode,
      'creationDate': creationDate,
      'cardNo': cardNo,
      'studentId': studentId,
      'fromDate': fromDate,
      'actionTaken': actionTaken,
      'createdBy': createdBy,
      'studentName': studentName,
      'cardId': cardId,
      'disciplineCode': disciplineCode,
      'disciplineDate': disciplineDate,
      'suspension': suspension,
      'sessionName': sessionName,
      'disciplineName': disciplineName,
    };
  }
}
