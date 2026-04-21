import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier_detail/Model/academic_discipline_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class AcademicConcernsView extends StatefulWidget {
  final String studentId;
  final bool cardView;

  const AcademicConcernsView(
      {super.key, required this.studentId, this.cardView = true});

  @override
  State<AcademicConcernsView> createState() => _AcademicConcernsViewState();
}

class _AcademicConcernsViewState extends State<AcademicConcernsView> {
  Future<List<ApiResponse<List<AcademicDisciplineModel>>>>?
      getDossierAcademicDetails;
  List<List<AcademicDisciplineModel>?> academicRecordModels = [];
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

          callGetDossierAcademicDetails(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetDossierAcademicDetails(List<Session> sessions) {
    // Create a list of futures for the first three sessions
    List<Future<ApiResponse<List<AcademicDisciplineModel>>>> futures = [];

    for (var session in sessions) {
      futures
          .add(StudentDossierDetailViewModel.instance.getDossierAcademicDetail(
        sessionId: session.sessionCode,
        studentId: widget.studentId,
      ));
    }

    // Wait for all futures to complete
    getDossierAcademicDetails = Future.wait(futures).then((responses) {
      academicRecordModels.addAll(responses
          .map((response) => response.success ? response.data : null)
          .toList());
      setState(() {});
      return responses;
    });
  }

  void loadMore() {
    // Get next three sessions starting from the last fetched index
    sessions.removeRange(0, min(3, sessions.length));

    List<Session> nextSessions = sessions.take(3).toList().cast<Session>();

    // Add the new sessions to the selected sessions list
    selectedSessions.addAll(nextSessions);

    // Call the API for the new sessions
    callGetDossierAcademicDetails(nextSessions);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: getSessionListFuture,
        builder: (context, snapshot) {
          if (sessions.isEmpty) {
            return const NoDataWidget();
          }
          return Column(
            spacing: 16,
            children: [
              AppFutureBuilder(
                  future: getDossierAcademicDetails,
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
                        for (int i = 0; i < selectedSessions.length; i++)
                          if (academicRecordModels.length > i &&
                              academicRecordModels[i] != null &&
                              academicRecordModels[i]!.isNotEmpty)
                            Column(
                              spacing: 8,
                              children: [
                                Text(
                                  academicRecordModels[i]!.first.sessionName ??
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
                                        text: "Subject", width: 80),
                                    TableColumnConfiguration(
                                        text: "Marked By", width: 100),
                                    TableColumnConfiguration(
                                        text: "Area of Concern", width: 130),
                                  ],
                                  data: academicRecordModels[i]
                                          ?.asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key + 1;
                                        AcademicDisciplineModel model =
                                            entry.value;
                                        return TableRowConfiguration(
                                          rowHeight: 65,
                                          cells: [
                                            TableCellConfiguration(
                                                text: "$index", width: 30),
                                            TableCellConfiguration(
                                                text: formatAnyDateToDDMMYY(
                                                    model.defaulterDate ?? ""),
                                                width: 75),
                                            TableCellConfiguration(
                                                text: model.subject ?? "",
                                                width: 80),
                                            TableCellConfiguration(
                                                text: model.markedBy,
                                                width: 100),
                                            TableCellConfiguration(
                                                text: model.inDefaulter,
                                                width: 130),
                                          ],
                                        );
                                      }).toList() ??
                                      [],
                                  headingRowHeight: 45,
                                  headingTextStyle: const TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: 12),
                                  headingRowColor: ColorConstant.primaryColor,
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
