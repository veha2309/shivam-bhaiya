class PendingtestModel {
  final String? homework;
  final String? testStatus;
  final String? homeworkDate;
  final String? subjectCode;
  final String? testDate;
  final String? subjectName;
  final String? className;
  final String? classCode;
  final String? sectionCode;
  final String? checkDate;
  bool isSelected;

  PendingtestModel({
    this.homework,
    this.testStatus,
    this.homeworkDate,
    this.subjectCode,
    this.testDate,
    this.subjectName,
    this.className,
    this.classCode,
    this.sectionCode,
    this.checkDate,
    this.isSelected = false,
  });

  factory PendingtestModel.fromJson(Map<String, dynamic> json) {
    return PendingtestModel(
      homework: json['homework'],
      testStatus: json['testStatus'],
      homeworkDate: json['homeworkDate'],
      subjectCode: json['subjectCode'],
      testDate: json['testDate'],
      subjectName: json['subjectName'],
      className: json['className'],
      classCode: json['classCode'],
      sectionCode: json['sectionCode'],
      checkDate: json['checkDate'],
    );
  }

  static List<PendingtestModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => PendingtestModel.fromJson(json)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'homework': homework,
      'testStatus': testStatus,
      'homeworkDate': homeworkDate,
      'subjectCode': subjectCode,
      'testDate': testDate,
      'subjectName': subjectName,
      'className': className,
      'classCode': classCode,
      'sectionCode': sectionCode,
      'checkDate': checkDate,
    };
  }
}
