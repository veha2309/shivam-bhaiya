import 'package:flutter/material.dart';
import '../Model/academic_record_model.dart';
import '../Helper/academic_record_ui_helper.dart';

class AcademicRecordTableWidget extends StatelessWidget {
  final Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
      academicData;
  final String selectedSession;

  const AcademicRecordTableWidget({
    super.key,
    required this.academicData,
    required this.selectedSession,
  });

  @override
  Widget build(BuildContext context) {
    final subjects = AcademicRecordUIHelper.getSubjectsForSession(
        academicData, selectedSession);

    return ListView.builder(
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildSubjectTable(subject),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectTable(String subject) {
    final allExams = AcademicRecordUIHelper.getAllExamsForSubject(
      academicData,
      selectedSession,
      subject,
    );

    if (allExams.isEmpty) {
      return const Text('No data available');
    }

    return Table(
      border: TableBorder.all(color: Colors.grey),
      columnWidths: const {
        0: FlexColumnWidth(2), // Term column
        1: FlexColumnWidth(3), // Exam columns will be flex
      },
      children: [
        // Header row
        TableRow(
          decoration: BoxDecoration(color: Colors.grey[200]),
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Term',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...allExams.map(
              (exam) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  exam,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        // Term 1 row
        _buildTermRow(subject, 'Term-1', allExams),
        // Term 2 row
        _buildTermRow(subject, 'Term-2', allExams),
      ],
    );
  }

  TableRow _buildTermRow(String subject, String term, List<String> exams) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            term,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        ...exams.map(
          (exam) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: _buildMarkCell(subject, term, exam),
          ),
        ),
      ],
    );
  }

  Widget _buildMarkCell(String subject, String term, String exam) {
    final marks = AcademicRecordUIHelper.getMarksForExamAndTerm(
      academicData,
      selectedSession,
      subject,
      term,
      exam,
    );

    final maxMarks = AcademicRecordUIHelper.getMaxMarksForExamAndTerm(
      academicData,
      selectedSession,
      subject,
      term,
      exam,
    );

    final percentage = AcademicRecordUIHelper.getPercentageForExamAndTerm(
      academicData,
      selectedSession,
      subject,
      term,
      exam,
    );

    if (marks == '-') {
      return const Text('-', style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$marks/$maxMarks'),
        if (percentage != '-')
          Text(
            '($percentage%)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }
}

// Example usage widget
class AcademicRecordScreen extends StatefulWidget {
  final List<AcademicRecordDossier> academicRecords;

  const AcademicRecordScreen({
    super.key,
    required this.academicRecords,
  });

  @override
  State<AcademicRecordScreen> createState() => _AcademicRecordScreenState();
}

class _AcademicRecordScreenState extends State<AcademicRecordScreen> {
  late Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
      structuredData;
  String? selectedSession;

  @override
  void initState() {
    super.initState();
    // Convert your existing data to the new structure
    structuredData =
        AcademicRecordDossier.createUIStructuredData(widget.academicRecords);

    // Set default session
    final sessions = AcademicRecordUIHelper.getSessions(structuredData);
    if (sessions.isNotEmpty) {
      selectedSession = sessions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (selectedSession == null) {
      return const Scaffold(
        body: Center(child: Text('No academic records available')),
      );
    }

    final sessions = AcademicRecordUIHelper.getSessions(structuredData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Records'),
      ),
      body: Column(
        children: [
          // Session selector
          if (sessions.length > 1)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: selectedSession,
                isExpanded: true,
                hint: const Text('Select Session'),
                items: sessions.map((session) {
                  return DropdownMenuItem<String>(
                    value: session,
                    child: Text(session),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSession = value;
                  });
                },
              ),
            ),
          // Academic records table
          Expanded(
            child: AcademicRecordTableWidget(
              academicData: structuredData,
              selectedSession: selectedSession!,
            ),
          ),
        ],
      ),
    );
  }
}
