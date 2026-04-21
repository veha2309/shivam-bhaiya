import '../Model/academic_record_model.dart';

class AcademicRecordUIHelper {
  // Convert your existing academicRecordMap to the new UI structure
  static Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
      convertToUIStructure(
          Map<String, Map<String, List<AcademicRecordDossier>>> oldStructure) {
    List<AcademicRecordDossier> allRecords = [];

    // Flatten the old structure to get all records
    for (var sessionEntry in oldStructure.entries) {
      for (var subjectEntry in sessionEntry.value.entries) {
        allRecords.addAll(subjectEntry.value);
      }
    }

    // Use the helper method to create the new structure
    return AcademicRecordDossier.createUIStructuredData(allRecords);
  }

  // Get all sessions
  static List<String> getSessions(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data) {
    return data.keys.toList();
  }

  // Get all subjects for a session
  static List<String> getSubjectsForSession(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session) {
    return data[session]?.keys.toList() ?? [];
  }

  // Get term data for a specific session and subject
  static Map<String, List<AcademicRecordDossier>>? getTermDataForSubject(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject) {
    return data[session]?[subject];
  }

  // Check if a subject has data for both terms
  static bool hasDataForBothTerms(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject) {
    final termData = getTermDataForSubject(data, session, subject);
    if (termData == null) return false;

    return (termData['Term-1']?.isNotEmpty ?? false) &&
        (termData['Term-2']?.isNotEmpty ?? false);
  }

  // Get all unique exams across both terms for a subject
  static List<String> getAllExamsForSubject(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject) {
    final termData = getTermDataForSubject(data, session, subject);
    if (termData == null) return [];

    Set<String> allExams = {};

    for (var termRecords in termData.values) {
      for (var record in termRecords) {
        if (record.exam != null) {
          allExams.add(record.exam!);
        }
      }
    }

    return allExams.toList();
  }

  // Get marks for a specific exam and term
  static String getMarksForExamAndTerm(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject,
      String term,
      String examName) {
    final termData = getTermDataForSubject(data, session, subject);
    if (termData == null) return '-';

    final termRecords = termData[term] ?? [];
    final record =
        AcademicRecordDossier.getRecordForExam(termRecords, examName);

    return record?.testMarks ?? '-';
  }

  // Get percentage for a specific exam and term
  static String getPercentageForExamAndTerm(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject,
      String term,
      String examName) {
    final termData = getTermDataForSubject(data, session, subject);
    if (termData == null) return '-';

    final termRecords = termData[term] ?? [];
    final record =
        AcademicRecordDossier.getRecordForExam(termRecords, examName);

    return record?.percentage ?? '-';
  }

  // Get max marks for a specific exam and term
  static String getMaxMarksForExamAndTerm(
      Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>> data,
      String session,
      String subject,
      String term,
      String examName) {
    final termData = getTermDataForSubject(data, session, subject);
    if (termData == null) return '-';

    final termRecords = termData[term] ?? [];
    final record =
        AcademicRecordDossier.getRecordForExam(termRecords, examName);

    return record?.maxMarks ?? '-';
  }
}
