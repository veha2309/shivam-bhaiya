class ConcernsDetailModel {
  final String? subject;
  final String? sessionName;
  final String? studentName;
  final String? markedBy;
  final String? inDefaulter;
  final String? defaulterDate;
  final String? remarks;
  final String? disciplineCategory;
  final String? className;
  final String? ticketBy;
  final String? ticketDate;

  ConcernsDetailModel({
    this.subject,
    this.sessionName,
    this.studentName,
    this.markedBy,
    this.inDefaulter,
    this.defaulterDate,
    this.remarks,
    this.disciplineCategory,
    this.className,
    this.ticketBy,
    this.ticketDate,
  });

  factory ConcernsDetailModel.fromJson(Map<String, dynamic> json) {
    return ConcernsDetailModel(
      subject: json['subject'],
      sessionName: json['sessionName'],
      studentName: json['studentName'],
      markedBy: json['markedBy'],
      inDefaulter: json['inDefaulter'],
      defaulterDate: json['defaulterDate'],
      remarks: json['remarks'],
      disciplineCategory: json['disciplineCategory'],
      className: json['className'],
      ticketBy: json['ticketBy'],
      ticketDate: json['ticketDate'],
    );
  }

  static List<ConcernsDetailModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ConcernsDetailModel.fromJson(json)).toList();
  }
}
