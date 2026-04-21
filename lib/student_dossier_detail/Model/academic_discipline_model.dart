class AcademicDisciplineModel {
  final String? sessionName;
  final String? studentName;
  final String? inDefaulter;
  final String? markedBy;
  final String? defaulterDate;
  final String? remarks;
  final String? type;
  final String? subject;

  AcademicDisciplineModel({
    this.sessionName,
    this.studentName,
    this.inDefaulter,
    this.markedBy,
    this.defaulterDate,
    this.remarks,
    this.type,
    this.subject,
  });

  // Factory method to create a DefaulterRecord from JSON
  factory AcademicDisciplineModel.fromJson(Map<String, dynamic> json) {
    return AcademicDisciplineModel(
      sessionName: json['sessionName'],
      studentName: json['studentName'],
      inDefaulter: json['inDefaulter'],
      markedBy: json['markedBy'],
      defaulterDate: json['defaulterDate'],
      remarks: json['remarks'],
      type: json['type'],
      subject: json['subject'],
    );
  }

  // Method to convert DefaulterRecord to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessionname': sessionName,
      'studentname': studentName,
      'indefaulter': inDefaulter,
      'markedby': markedBy,
      'defaulterdate': defaulterDate,
      'remarks': remarks,
      'type': type,
      'subject': subject,
    };
  }
}
