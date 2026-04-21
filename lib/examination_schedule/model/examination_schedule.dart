class ExaminationSchedule {
  final String? sectionName;
  final String? uploadDate;
  final String? sessionName;
  final String? examName;
  final String? documentUrl;
  final String? className;
  final String? revisedUploadDate;
  final String? remarks;

  ExaminationSchedule({
    this.sectionName,
    this.uploadDate,
    this.sessionName,
    this.examName,
    this.documentUrl,
    this.className,
    this.revisedUploadDate,
    this.remarks,
  });

  factory ExaminationSchedule.fromJson(Map<String, dynamic> json) {
    return ExaminationSchedule(
      sectionName: json['sectionName'],
      uploadDate: json['uploadDate'],
      sessionName: json['sessionName'],
      examName: json['examName'],
      documentUrl: json['documentUrl'],
      className: json['className'],
      revisedUploadDate: json['revisedUploadDate'],
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sectionName': sectionName,
      'uploadDate': uploadDate,
      'sessionName': sessionName,
      'examName': examName,
      'documentUrl': documentUrl,
      'className': className,
      'revisedUploadDate': revisedUploadDate,
      'remarks': remarks,
    };
  }

  static List<ExaminationSchedule> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => ExaminationSchedule.fromJson(json)).toList();
  }
}
