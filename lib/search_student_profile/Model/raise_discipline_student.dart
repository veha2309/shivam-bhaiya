class RaiseDisciplineStudent {
  final String? date;
  final String? dateOfAttendance;
  final String? rollNo;
  final String? studentName;
  final String? admissionNo;
  final String? studentId;
  final String? attendance;
  final String? isUpdate;
  final String? classCode;
  final String? sectionCode;
  final bool? status;

  RaiseDisciplineStudent({
    this.date,
    this.dateOfAttendance,
    this.rollNo,
    this.studentName,
    this.admissionNo,
    this.studentId,
    this.attendance,
    this.isUpdate,
    this.classCode,
    this.sectionCode,
    this.status,
  });

  // Convert JSON to Model
  factory RaiseDisciplineStudent.fromJson(Map<String, dynamic> json) {
    return RaiseDisciplineStudent(
      date: json["DATE"],
      dateOfAttendance: json["dateofattendance"],
      rollNo: json["ROLLNO"],
      studentName: json["STUDENTNAME"],
      admissionNo: json["admissionno"],
      studentId: json["STUDENTID"],
      attendance: json["ATTENDANCE"],
      isUpdate: json["isupdate"],
      classCode: json["CLASSCODE"],
      sectionCode: json["SECTIONCODE"],
      status: json["status"],
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      "DATE": date,
      "dateofattendance": dateOfAttendance,
      "ROLLNO": rollNo,
      "STUDENTNAME": studentName,
      "admissionno": admissionNo,
      "STUDENTID": studentId,
      "ATTENDANCE": attendance,
      "isupdate": isUpdate,
      "CLASSCODE": classCode,
      "SECTIONCODE": sectionCode,
      "status": status,
    };
  }

  // Convert List of JSON to List of Models
  static List<RaiseDisciplineStudent> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => RaiseDisciplineStudent.fromJson(json))
        .toList();
  }

  // Convert List of Models to List of JSON
  static List<Map<String, dynamic>> toJsonList(
      List<RaiseDisciplineStudent> list) {
    return list.map((item) => item.toJson()).toList();
  }
}
