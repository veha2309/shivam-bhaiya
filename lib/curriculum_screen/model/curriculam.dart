class Curriculam {
  final String? sectionName;
  final String? uploadDate;
  final String? sessionName;
  final String? examName;
  final String? documentUrl;
  final String? className;
  final String? revisedUploadDate;
  final String? remarks;
  final String? subjectName;

  Curriculam({
    this.sectionName,
    this.uploadDate,
    this.sessionName,
    this.examName,
    this.documentUrl,
    this.className,
    this.revisedUploadDate,
    this.remarks,
    this.subjectName,
  });

  factory Curriculam.fromJson(Map<String, dynamic> json) {
    return Curriculam(
      sectionName: json['sectionName'],
      uploadDate: json['uploadDate'],
      sessionName: json['sessionName'],
      examName: json['examName'],
      documentUrl: json['documentUrl'],
      className: json['className'],
      revisedUploadDate: json['revisedUploadDate'],
      remarks: json['remarks'],
      subjectName: json['subjectName'],
    );
  }

  static List<Curriculam> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Curriculam.fromJson(json)).toList();
  }
}
