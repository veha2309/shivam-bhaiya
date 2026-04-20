import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier_detail/Model/academic_record_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class AcademicRecordView extends StatefulWidget {
  final String studentId;

  const AcademicRecordView({
    super.key,
    required this.studentId,
  });

  @override
  State<AcademicRecordView> createState() => _AcademicRecordViewState();
}

class _AcademicRecordViewState extends State<AcademicRecordView> {
  Future<List<ApiResponse<List<AcademicRecordDossier>>>>?
      getDossierAcademicRecordDetail;
  List<List<AcademicRecordDossier>?> academicRecordModels = [];
  List<Session> selectedSessions = [];

  Future<ApiResponse<List<Session>>>? getSessionListFuture;
  List<Session> sessions = [];

  // Updated structure: Session -> Subject -> Term -> List<AcademicRecordDossier>
  Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
      academicRecordMap = {};
  Set<String> subjectCodes = {};
  Set<String> examCodes = {};

  @override
  void initState() {
    super.initState();
    getSessionListFuture = SchoolDetailsViewModel.instance
        .getSessionList()
        .then((ApiResponse<List<Session>> response) {
      if (response.success) {
        sessions = response.data ?? [];
        if (sessions.isNotEmpty) {
          // Get first three sessions or fewer if less than three are available
          selectedSessions = sessions.take(3).toList().cast<Session>();
          callGetDossierAcademicRecordDetail(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetDossierAcademicRecordDetail(List<Session> sessions,
      [ValueNotifier<bool>? isLoadingMore]) {
    isLoadingMore?.value = true;
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<AcademicRecordDossier>>>> futures = [];

    for (var session in sessions) {
      futures.add(
          StudentDossierDetailViewModel.instance.getDossierAcademicRecordDetail(
        sessionId: session.sessionCode,
        studentId: widget.studentId,
      ));
    }

    // Wait for all futures to complete
    var future = Future.wait(futures).then((responses) {
      List<List<AcademicRecordDossier>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var record in data) {
        if (record != null && record.isNotEmpty) {
          academicRecordModels.add(record);
          // Process the records using the new UI structure
          Map<String, Map<String, Map<String, List<AcademicRecordDossier>>>>
              newData = AcademicRecordDossier.createUIStructuredData(record);

          // Merge the new data with existing academicRecordMap
          for (var sessionEntry in newData.entries) {
            String sessionName = sessionEntry.key;

            // Initialize session map if not exists
            academicRecordMap[sessionName] ??= {};

            for (var subjectEntry in sessionEntry.value.entries) {
              String subjectName = subjectEntry.key;
              subjectCodes.add(subjectName);

              // Initialize subject map if not exists
              academicRecordMap[sessionName]![subjectName] ??= {
                'Term-1': <AcademicRecordDossier>[],
                'Term-2': <AcademicRecordDossier>[],
              };

              // Merge term data
              for (var termEntry in subjectEntry.value.entries) {
                String termName = termEntry.key;
                academicRecordMap[sessionName]![subjectName]![termName]!
                    .addAll(termEntry.value);

                // Collect exam codes for reference
                for (var examRecord in termEntry.value) {
                  if (examRecord.exam != null) {
                    examCodes.add(examRecord.exam!);
                  }
                }
              }
            }
          }
        }
      }

      if (academicRecordModels.isEmpty) {
        loadMore(isLoadingMore);
      }
      setState(() {});
      isLoadingMore?.value = false;
      return responses;
    });
    getDossierAcademicRecordDetail ??= future;
  }

  void loadMore([ValueNotifier<bool>? isLoadingMore]) {
    if (sessions.isEmpty) {
      return;
    }
    // Get next three sessions starting from the last fetched index
    sessions.removeRange(0, min(3, sessions.length));
    List<Session> nextSessions = sessions.take(3).toList().cast<Session>();

    // Add the new sessions to the selected sessions list
    selectedSessions.addAll(nextSessions);

    // Call the API for the new sessions
    callGetDossierAcademicRecordDetail(nextSessions, isLoadingMore);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: getSessionListFuture,
        builder: (context, snapshot) {
          return Column(
            spacing: 16,
            children: [
              AppFutureBuilder(
                  future: getDossierAcademicRecordDetail,
                  builder: (context, snapshot) {
                    // Check if all sessions have empty data
                    bool allEmpty = academicRecordModels
                        .every((model) => model == null || model.isEmpty);

                    if (allEmpty) {
                      return const NoDataWidget();
                    }

                    return Column(
                      spacing: 24,
                      children: [
                        getAcademicRecordView(),
                        if (sessions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: AppButton(
                              onPressed: (isLoadingMore) =>
                                  loadMore(isLoadingMore),
                              text: 'Load More',
                            ),
                          ),
                      ],
                    );
                  }),
            ],
          );
        });
  }

  Widget getAcademicRecordView() {
    if (academicRecordMap.isEmpty) {
      return const NoDataWidget();
    }

    return Column(
      spacing: 24,
      children: [
        // Create a separate table for each session
        ...academicRecordMap.entries.map((sessionEntry) {
          String sessionName = sessionEntry.key;
          Map<String, Map<String, List<AcademicRecordDossier>>> sessionData =
              sessionEntry.value;

          return Column(
            spacing: 16,
            children: [
              // Session header
              Text(
                sessionName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.primaryColor,
                ),
              ),
              // Session table
              _buildSessionTable(sessionData),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildSessionTable(
      Map<String, Map<String, List<AcademicRecordDossier>>> sessionData) {
    int index = 1;

    // Get all unique exams across all subjects in this session
    Set<String> sessionExams = {};
    for (var subjectData in sessionData.values) {
      for (var termData in subjectData.values) {
        for (var record in termData) {
          if (record.exam != null) {
            sessionExams.add(record.exam!);
          }
        }
      }
    }

    // Convert to sorted list for consistent ordering
    List<String> sortedExams = sessionExams.toList()..sort();

    // Separate "Overall" subject from others and sort the rest
    List<MapEntry<String, Map<String, List<AcademicRecordDossier>>>>
        sortedSubjects = [];
    MapEntry<String, Map<String, List<AcademicRecordDossier>>>? overallEntry;

    for (var entry in sessionData.entries) {
      if (entry.key.toLowerCase().contains("overall")) {
        overallEntry = entry;
      } else {
        sortedSubjects.add(entry);
      }
    }

    // Sort non-overall subjects alphabetically
    sortedSubjects.sort((a, b) => a.key.compareTo(b.key));

    // Add overall at the end if it exists
    if (overallEntry != null && sortedSubjects.isNotEmpty) {
      sortedSubjects.insert(0, overallEntry);
    }

    return _buildFrozenTable(sortedSubjects, sortedExams, index);
  }

  Widget _buildFrozenTable(
    List<MapEntry<String, Map<String, List<AcademicRecordDossier>>>>
        sortedSubjects,
    List<String> sortedExams,
    int startIndex,
  ) {
    // Create tables for each subject with Term-1 and Term-2 rows
    return Column(
      spacing: 16,
      children: sortedSubjects.map((subjectEntry) {
        String subjectName = subjectEntry.key;
        Map<String, List<AcademicRecordDossier>> subjectTermData =
            subjectEntry.value;

        return _buildSubjectTable(subjectName, subjectTermData, sortedExams);
      }).toList(),
    );
  }

  Widget _buildSubjectTable(String subjectName,
      Map<String, List<AcademicRecordDossier>> termData, List<String> exams) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          width: double.infinity,
          color: ColorConstant.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "$subjectName ${termData['Term-1']?.first.overallPercentage != null ? "% : ${termData['Term-1']?.first.overallPercentage}" : ""}",
                textAlign: TextAlign.center,
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.onPrimary,
                ),
              ),
            ],
          ),
        ),

        // Subject table with terms as rows and exams as columns
        _buildTermBasedTable(
          termData,
          exams,
        ),
      ],
    );
  }

  Widget _buildTermBasedTable(
      Map<String, List<AcademicRecordDossier>> termData, List<String> exams) {
    if (exams.isEmpty) {
      return const Text('No exam data available');
    }

    // Create table headers
    List<TableColumnConfiguration> headers = [
      TableColumnConfiguration(text: "Term", width: 80),
    ];

    int noOfCol = max(
        (termData['Term-1'] ?? []).length, (termData['Term-2'] ?? []).length);

    headers.addAll(List.generate(
      noOfCol,
      (_) => TableColumnConfiguration(text: "Term", width: 50),
    ));

    // Create table rows for Term-1 and Term-2
    List<TableRowConfiguration> rows = [
      _buildTermRow(
        'Term-1',
        termData['Term-1'] ?? [],
        exams,
        minCol: noOfCol + 1,
      ),
      _buildTermRow(
        'Term-2',
        termData['Term-2'] ?? [],
        exams,
        minCol: noOfCol + 1,
      ),
    ];

    return DataTableWidget(
      headers: headers,
      minColumnWidth: 90,
      headingRowHeight: 0,
      data: rows,
      enableHorizontalScroll: true,
      headingRowColor: ColorConstant.primaryColor,
      headingTextStyle: const TextStyle(
        fontWeight: FontWeight.w300,
        fontSize: 12,
        color: ColorConstant.onPrimary,
      ),
    );
  }

  TableRowConfiguration _buildTermRow(String termName,
      List<AcademicRecordDossier> termRecords, List<String> exams,
      {required int minCol}) {
    List<TableCellConfiguration> cells = [
      TableCellConfiguration(
        text: termName,
        width: 50,
        height: 60,
      ),
    ];

    // Add cells for each exam
    for (AcademicRecordDossier termRecord in termRecords) {
      // AcademicRecordDossier? record = _getRecordForExam(termRecords, exam);
      String displayText = "-";
      String exam = termRecord.activityName ?? "-";
      String marks = termRecord.testMarks ?? "-";
      String maxMarks = termRecord.maxMarks ?? "-";
      String percentage = termRecord.percentage ?? "-";
      displayText = "$exam\n$marks/$maxMarks\n($percentage%)";

      cells.add(TableCellConfiguration(
        text: displayText,
        width: 80,
        height: 60,
      ));
    }

    while (cells.length < minCol) {
      cells.add(TableCellConfiguration(
        text: "--",
        width: 80,
        height: 60,
      ));
    }

    return TableRowConfiguration(
      rowHeight: 60,
      cells: cells,
    );
  }

  AcademicRecordDossier? _getRecordForExam(
      List<AcademicRecordDossier> records, String examName) {
    try {
      return records.firstWhere((record) => record.exam == examName);
    } catch (e) {
      return null;
    }
  }
}
