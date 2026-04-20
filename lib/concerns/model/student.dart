class Student {
  final String? studentId;
  final String? admissionNo;
  final String? studentName;
  final String? cnt;
  final String? className;

  Student({
    this.studentId,
    this.admissionNo,
    this.studentName,
    this.cnt,
    this.className,
  });

  // Factory constructor to create an instance from JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      admissionNo: json['admissionNo'],
      studentName: json['studentName'],
      cnt: json['cnt'],
      className: json['className'],
    );
  }

  // Convert instance to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'admissionNo': admissionNo,
      'studentName': studentName,
      'cnt': cnt,
      'className': className,
    };
  }
}
