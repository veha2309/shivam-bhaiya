class AttandanceReconcilliationStudentModel {
  final String? rollNo;
  final String? className;
  final String? sessionCode;
  final String? sectionName;
  final String? month;
  final int? workingDays;
  final int? totalAttendance;
  final String? admissionNo;
  final String? classCode;
  final String? name;
  final String? sectionCode;
  final String? id;
  final int? present;

  AttandanceReconcilliationStudentModel({
    this.rollNo,
    this.className,
    this.sessionCode,
    this.sectionName,
    this.month,
    this.workingDays,
    this.totalAttendance,
    this.admissionNo,
    this.classCode,
    this.name,
    this.sectionCode,
    this.id,
    this.present,
  });

  // Factory method to create an instance from a JSON object
  factory AttandanceReconcilliationStudentModel.fromJson(
      Map<String, dynamic> json) {
    return AttandanceReconcilliationStudentModel(
      rollNo: json['rollno'],
      className: json['className'],
      sessionCode: json['sessioncode'],
      sectionName: json['sectionName'],
      month: json['month'],
      workingDays: json['workingdays'] != null
          ? int.tryParse(json['workingdays'])
          : null,
      totalAttendance: json['totalattendance'] != null
          ? int.tryParse(json['totalattendance'])
          : null,
      admissionNo: json['admissionno'],
      classCode: json['classcode'],
      name: json['name']?.trim(),
      sectionCode: json['sectioncode'],
      id: json['id'],
      present: json['present'] != null ? int.tryParse(json['present']) : null,
    );
  }

  // Convert instance to JSON format
  Map<String, dynamic> toJson() {
    return {
      'rollno': rollNo,
      'className': className,
      'sessioncode': sessionCode,
      'sectionName': sectionName,
      'month': month,
      'workingdays': workingDays?.toString(),
      'totalattendance': totalAttendance?.toString(),
      'admissionno': admissionNo,
      'classcode': classCode,
      'name': name,
      'sectioncode': sectionCode,
      'id': id,
      'present': present?.toString(),
    };
  }

  @override
  String toString() {
    return 'StudentAttendance(rollNo: $rollNo, name: $name, present: $present/$workingDays)';
  }

  static List<Map<String, dynamic>> toJsonList(
      List<AttandanceReconcilliationStudentModel> dataList) {
    final List<Map<String, dynamic>> jsonList =
        dataList.map((data) => data.toJson()).toList();
    return jsonList;
  }
}
