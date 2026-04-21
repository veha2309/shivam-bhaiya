class SuspensionData {
  final String? studentId;
  final String? fromDate;
  final String? classCode;
  final String? sessionCode;
  final String? createdBy;
  final String? studentName;
  final String? toDate;
  final String? rollNo;
  final String? sectionCode;
  final String? description;
  final String? creationDate;
  final String? disciplineCardId;
  final String? cardNo;

  SuspensionData({
    this.studentId,
    this.fromDate,
    this.classCode,
    this.sessionCode,
    this.createdBy,
    this.studentName,
    this.toDate,
    this.rollNo,
    this.sectionCode,
    this.description,
    this.creationDate,
    this.disciplineCardId,
    this.cardNo,
  });

  factory SuspensionData.fromJson(Map<String, dynamic> json) {
    return SuspensionData(
      studentId: json['studentId']?.toString(),
      fromDate: json['fromDate']?.toString(),
      classCode: json['classCode']?.toString(),
      sessionCode: json['sessionCode']?.toString(),
      createdBy: json['createdBy']?.toString(),
      studentName: json['studentName']?.toString(),
      toDate: json['toDate']?.toString(),
      rollNo: json['rollNo']?.toString(),
      sectionCode: json['sectionCode']?.toString(),
      description: json['description']?.toString(),
      creationDate: json['creationDate']?.toString(),
      disciplineCardId: json['disciplineCardId']?.toString(),
      cardNo: json['cardNo']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'fromDate': fromDate,
      'classCode': classCode,
      'sessionCode': sessionCode,
      'createdBy': createdBy,
      'studentName': studentName,
      'toDate': toDate,
      'rollNo': rollNo,
      'sectionCode': sectionCode,
      'description': description,
      'creationDate': creationDate,
      'disciplineCardId': disciplineCardId,
      'cardNo': cardNo,
    };
  }
}
