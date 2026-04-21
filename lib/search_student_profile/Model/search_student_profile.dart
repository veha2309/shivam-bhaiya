class Student {
  final String? studentId;
  final String? studentName;
  final String? studentClass;

  Student({
    required this.studentId,
    required this.studentName,
    required this.studentClass,
  });

  // Factory method to create a Student object from a JSON map
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['studentId'],
      studentName: json['studentName'],
      studentClass: json['class'],
    );
  }

  // Convert Student object to JSON format
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'class': studentClass,
    };
  }
}
