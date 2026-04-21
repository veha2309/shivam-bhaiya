import 'dart:convert';

class AcademicRecordDossier {
  final String? studentId;
  final String? exam;
  final String? subjectName;
  final String? testMarks;
  final String? className;
  final String? sessionName;
  final String? studentName;
  final String? classCode;
  final String? percentage;
  final String? sectionCode;
  final String? activityName;
  final String? maxMarks;
  final String? overallPercentage;

  AcademicRecordDossier({
    this.studentId,
    this.exam,
    this.subjectName,
    this.testMarks,
    this.className,
    this.sessionName,
    this.studentName,
    this.classCode,
    this.percentage,
    this.sectionCode,
    this.activityName,
    this.maxMarks,
    this.overallPercentage,
  });

  // Convert JSON to Model
  factory AcademicRecordDossier.fromJson(Map<String, dynamic> json) {
    return AcademicRecordDossier(
      studentId: json['studentid'],
      exam: json['exam'],
      subjectName: json['subjectname'],
      testMarks: json['testmarks'],
      className: json['classname'],
      sessionName: json['sessionname'],
      studentName: json['studentname'],
      classCode: json['classcode'],
      percentage: json['percentage'],
      sectionCode: json['sectioncode'],
      activityName: json['activityname'],
      maxMarks: json['maxmarks'],
      overallPercentage: json['overallPercentage'],
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      'studentid': studentId,
      'exam': exam,
      'subjectname': subjectName,
      'testmarks': testMarks,
      'classname': className,
      'sessionname': sessionName,
      'studentname': studentName,
      'classcode': classCode,
      'percentage': percentage,
      'sectioncode': sectionCode,
      'activityname': activityName,
      'maxmarks': maxMarks,
      'overallPercentage': overallPercentage,
    };
  }

  // Convert JSON List to Model List
  static List<AcademicRecordDossier>? fromJsonList(String jsonData) {
    final List<dynamic>? decodedData = json.decode(jsonData);
    return decodedData
        ?.map((json) => AcademicRecordDossier.fromJson(json))
        .toList();
  }

  // Helper method to determine term based on exam name
  String get termType {
    if (exam == null) return 'Term-1';

    final examLower = exam!.toLowerCase();
    if (examLower.contains('term 2') ||
        examLower.contains('term-2') ||
        examLower.contains('term2') ||
        examLower.contains('second term') ||
        examLower.contains('final') ||
        examLower.contains('annual') ||
        examLower.contains('half yearly') ||
        examLower.contains('yearly')) {
      return 'Term-2';
    }
    return 'Term-1';
  }

  // Helper method to create structured data for UI
  static Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
      createUIStructuredData(List<AcademicRecordDossier> records) {
    Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
        structuredData = {};

    for (var record in records) {
      final session = record.sessionName ?? 'Unknown Session';
      final subject = record.subjectName ?? 'Unknown Subject';
      final term = record.termType;

      // Initialize nested maps if they don't exist
      structuredData[session] ??= {};
      structuredData[session]![subject] ??= {
        'Term-1': <AcademicRecordDossier>[],
        'Term-2': <AcademicRecordDossier>[],
      };

      // Add the record to the appropriate term
      structuredData[session]![subject]![term]!.add(record);
    }

    return structuredData;
  }

  // Helper method to get all exams for a specific session, subject, and term
  static List<String> getExamsForTerm(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject,
      String term) {
    final records = data[session]?[subject]?[term] ?? [];
    return records.map((record) => record.exam ?? '').toSet().toList();
  }

  // Helper method to get marks for a specific exam in a term
  static AcademicRecordDossier? getRecordForExam(
      List<AcademicRecordDossier> termRecords, String examName) {
    try {
      return termRecords.firstWhere((record) => record.exam == examName);
    } catch (e) {
      return null;
    }
  }
}
