class DisciplineStudentModel {
  final String? studentId;
  final String? classCode;
  final String? fatherName;
  final String? zone;
  final String? admissionNo;
  final String? studentName;
  final String? motherName;
  final String? rollNo;
  final String? sectionCode;
  final String? className;
  final String? bal;

  DisciplineStudentModel({
    this.studentId,
    this.classCode,
    this.fatherName,
    this.zone,
    this.admissionNo,
    this.studentName,
    this.motherName,
    this.rollNo,
    this.sectionCode,
    this.className,
    this.bal,
  });

  // Factory method to create a Student from JSON
  factory DisciplineStudentModel.fromJson(Map<String, dynamic> json) {
    return DisciplineStudentModel(
      studentId: json['studentId'] as String?,
      classCode: json['classCode'] as String?,
      fatherName: json['fatherName'] as String?,
      zone: json['zone'] as String?,
      admissionNo: json['admissionNo'] as String?,
      studentName: json['studentName'] as String?,
      motherName: json['motherName'] as String?,
      rollNo: json['rollNo'] as String?,
      sectionCode: json['sectionCode'] as String?,
      className: json['className'] as String?,
      bal: json['bal'] as String?,
    );
  }

  // Method to convert a Student to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'classCode': classCode,
      'fatherName': fatherName,
      'zone': zone,
      'admissionNo': admissionNo,
      'studentName': studentName,
      'motherName': motherName,
      'rollNo': rollNo,
      'sectionCode': sectionCode,
      'className': className,
      'bal': bal,
    };
  }

  // Factory method to create a list of students from JSON
  static List<DisciplineStudentModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => DisciplineStudentModel.fromJson(json))
        .toList();
  }
}
