import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier_detail/Model/discipline_record_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class DisciplineRecordView extends StatefulWidget {
  final String studentId;

  const DisciplineRecordView({super.key, required this.studentId});

  @override
  State<DisciplineRecordView> createState() => _DisciplineRecordViewState();
}

class _DisciplineRecordViewState extends State<DisciplineRecordView> {
  Future<List<ApiResponse<List<DisciplineRecordModel>>>>?
      getDossierDisciplineRecordDetails;
  List<List<DisciplineRecordModel>?> disciplineRecordModels = [];
  List<Session> selectedSessions = [];

  Future<ApiResponse<List<Session>>>? getSessionListFuture;
  List<Session> sessions = [];

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
          callGetDossierDisciplineRecordDetails(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetDossierDisciplineRecordDetails(List<Session> sessions) {
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<DisciplineRecordModel>>>> futures = [];

    for (var session in sessions) {
      futures.add(StudentDossierDetailViewModel.instance
          .getDossierDisciplineRecordDetail(
        sessionId: session.sessionCode,
        studentId: widget.studentId,
      ));
    }

    // Wait for all futures to complete
    var future = Future.wait(futures).then((responses) {
      List<List<DisciplineRecordModel>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var record in data) {
        if (record != null && record.isNotEmpty) {
          disciplineRecordModels.add(record);
        }
      }

      if (disciplineRecordModels.isEmpty) {
        loadMore();
      }
      setState(() {});
      return responses;
    });
    getDossierDisciplineRecordDetails ??= future;
  }

  void loadMore() {
    if (sessions.isEmpty) {
      return;
    }
    // Get next three sessions starting from the last fetched index
    sessions.removeRange(0, min(3, sessions.length));
    List<Session> nextSessions = sessions.take(3).toList().cast<Session>();

    // Add the new sessions to the selected sessions list
    selectedSessions.addAll(nextSessions);

    // Call the API for the new sessions
    callGetDossierDisciplineRecordDetails(nextSessions);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: getSessionListFuture,
        builder: (context, snapshot) {
          if (disciplineRecordModels.isEmpty) {
            return const NoDataWidget();
          }
          return Column(
            spacing: 16,
            children: [
              const Text(
                "Discipline Record",
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: fontFamily,
                  color: ColorConstant.primaryColor,
                ),
              ),
              AppFutureBuilder(
                  future: getDossierDisciplineRecordDetails,
                  builder: (context, snapshot) {
                    // Check if all sessions have empty data
                    bool allEmpty = disciplineRecordModels
                        .every((model) => model == null || model.isEmpty);

                    if (allEmpty) {
                      return const NoDataWidget();
                    }

                    return Column(
                      spacing: 24,
                      children: [
                        for (int i = 0; i < selectedSessions.length; i++)
                          if (disciplineRecordModels.length > i &&
                              disciplineRecordModels[i] != null &&
                              disciplineRecordModels[i]!.isNotEmpty)
                            Column(
                              spacing: 16,
                              children: [
                                Text(
                                  disciplineRecordModels[i]!
                                          .first
                                          .sessionName ??
                                      "--",
                                  textScaler: const TextScaler.linear(1.0),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold,
                                    color: ColorConstant.primaryColor,
                                  ),
                                ),
                                DataTableWidget(
                                  headers: [
                                    TableColumnConfiguration(
                                        text: "S.No", width: 30),
                                    TableColumnConfiguration(
                                        text: "Date", width: 75),
                                    TableColumnConfiguration(
                                        text: "Area of Concern", width: 70),
                                    TableColumnConfiguration(
                                        text: "Remarks", width: 60),
                                    TableColumnConfiguration(
                                        text: "Marked By", width: 100)
                                  ],
                                  data: disciplineRecordModels[i]
                                          ?.asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key + 1;
                                        DisciplineRecordModel model =
                                            entry.value;
                                        return TableRowConfiguration(
                                          rowHeight: 45,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "$index", width: 30),
                                            TableCellConfiguration(
                                                text: formatAnyDateToDDMMYY(
                                                    model.defaulterDate ?? ""),
                                                width: 75),
                                            TableCellConfiguration(
                                                text: model.inDefaulter,
                                                width: 70),
                                            TableCellConfiguration(
                                                text: model.remarks ?? "",
                                                width: 60),
                                            TableCellConfiguration(
                                                text: model.markedBy,
                                                width: 100)
                                          ],
                                        );
                                      }).toList() ??
                                      [],
                                  headingRowHeight: 45,
                                  headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12),
                                  headingRowColor:
                                      ColorConstant.primaryColor.withAlpha(127),
                                ),
                              ],
                            ),
                        if (sessions.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: AppButton(
                              onPressed: (_) => loadMore(),
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
}
