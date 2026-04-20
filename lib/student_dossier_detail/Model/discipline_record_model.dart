class DisciplineRecordModel {
  final String? sessionCode;
  final String? sessionName;
  final String? studentName;
  final String? markedBy;
  final String? inDefaulter;
  final String? defaulterDate;
  final String? remarks;
  final String? type;
  final String? date;

  DisciplineRecordModel({
    this.sessionCode,
    this.sessionName,
    this.studentName,
    this.markedBy,
    this.inDefaulter,
    this.defaulterDate,
    this.remarks,
    this.type,
    this.date,
  });

  // Factory method to create a DefaulterRecord from JSON
  factory DisciplineRecordModel.fromJson(Map<String, dynamic> json) {
    return DisciplineRecordModel(
      sessionCode: json['sessioncode'],
      sessionName: json['sessionname'],
      studentName: json['studentname'],
      markedBy: json['markedby'],
      inDefaulter: json['indefaulter'],
      defaulterDate: json['defaulterdate'],
      remarks: json['remarks'],
      type: json['type'],
      date: json['date'],
    );
  }

  // Method to convert DefaulterRecord to JSON
  Map<String, dynamic> toJson() {
    return {
      'sessioncode': sessionCode,
      'sessionName': sessionName,
      'studentName': studentName,
      'markedBy': markedBy,
      'inDefaulter': inDefaulter,
      'defaulterDate': defaulterDate,
      'remarks': remarks,
      'type': type,
      'date': date,
    };
  }
}
