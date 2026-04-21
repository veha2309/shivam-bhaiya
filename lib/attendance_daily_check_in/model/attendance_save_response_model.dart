class AttendanceSaveResponseModel {
  final String? studentId;
  final String? sectionCode;
  final String? attendance;
  final String? attendanceTakenBy;
  final String? dateOfAttendance;
  final String? attendanceValue;
  final String? isUpdate;

  // Constructor
  AttendanceSaveResponseModel({
    this.studentId,
    this.sectionCode,
    this.attendance,
    this.attendanceTakenBy,
    this.dateOfAttendance,
    this.attendanceValue,
    this.isUpdate,
  });

  // Factory method to create an instance from JSON
  factory AttendanceSaveResponseModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSaveResponseModel(
      studentId: json['studentId'] as String?,
      sectionCode: json['sectionCode'] as String?,
      attendance: json['attendance'] as String?,
      attendanceTakenBy: json['attendance_taken_by'] as String?,
      dateOfAttendance: json['dateofattendance'] as String?,
      attendanceValue: json['attendancevalue'] as String?,
      isUpdate: json['isupdate'] as String?,
    );
  }

  // Method to convert the model back into JSON
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'sectionCode': sectionCode,
      'attendance': attendance,
      'attendance_taken_by': attendanceTakenBy,
      'dateofattendance': dateOfAttendance,
      'attendancevalue': attendanceValue,
      'isupdate': isUpdate,
    };
  }
}
