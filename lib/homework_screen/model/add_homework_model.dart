class AddHomeworkModel {
  final String? classcode;
  final String? sectioncode;
  final String? subjectcode;
  final String? sessioncode;
  final String? homework;
  final String? homeworkdate;
  final String? duedate;
  final String? status;
  final String? testdate;
  final String? book;
  final String? noteBook;
  String? subjectName;
  String? fileName;
  String? documentName;

  AddHomeworkModel({
    this.classcode,
    this.sectioncode,
    this.subjectcode,
    this.sessioncode,
    this.homework,
    this.homeworkdate,
    this.duedate,
    this.status,
    this.testdate,
    this.book,
    this.noteBook,
    this.fileName,
    this.documentName,
    required this.subjectName,
  });

  factory AddHomeworkModel.fromJson(Map<String, dynamic> json) {
    return AddHomeworkModel(
      classcode: json['classcode'] as String?,
      sectioncode: json['sectioncode'] as String?,
      sessioncode: json['sessioncode'] as String?,
      subjectcode: json['subjectcode'] as String?,
      homework: json['homework'] as String?,
      homeworkdate: json['homeworkdate'] as String?,
      duedate: json['duedate'] as String?,
      status: json['status'] as String?,
      testdate: json['testDate'] as String?,
      book: json['book'] as String?,
      noteBook: json['noteBook'] as String?,
      subjectName: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classcode': classcode,
      'sectioncode': sectioncode,
      'sessioncode': sessioncode,
      'subjectcode': subjectcode,
      'homework': homework,
      'homeworkdate': homeworkdate,
      'duedate': duedate,
      'status': status,
      'testDate': testdate,
      'book': book,
      'noteBook': noteBook,
      'fileName': fileName,
      'documentName': documentName,
    };
  }

  static List<AddHomeworkModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => AddHomeworkModel.fromJson(json)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(
      List<AddHomeworkModel> concerns) {
    return concerns.map((concern) => concern.toJson()).toList();
  }
}
