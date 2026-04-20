class AttandanceRecordModel {
  final String? studentId;
  final String? totalClass;
  final String? leave;
  final String? sessionName;
  final String? studentName;
  final String? absent;
  final String? presentPercentage;
  final String? className;
  final String? classTeacher;
  final String? present;

  AttandanceRecordModel({
    this.studentId,
    this.totalClass,
    this.leave,
    this.sessionName,
    this.studentName,
    this.absent,
    this.presentPercentage,
    this.className,
    this.classTeacher,
    this.present,
  });

  // Factory method to create a StudentAttendance from JSON
  factory AttandanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttandanceRecordModel(
      studentId: json['studentId'],
      totalClass: json['totalClass'],
      leave: json['leave'],
      sessionName: json['sessionName'],
      studentName: json['studentName'],
      absent: json['absent'],
      presentPercentage: json['presentPercentage'],
      className: json['className'],
      classTeacher: json['classTeacher'],
      present: json['present'],
    );
  }

  // Method to convert StudentAttendance to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'totalClass': totalClass,
      'leave': leave,
      'sessionName': sessionName,
      'studentName': studentName,
      'absent': absent,
      'presentPercentage': presentPercentage,
      'className': className,
      'classTeacher': classTeacher,
      'present': present,
    };
  }
}
