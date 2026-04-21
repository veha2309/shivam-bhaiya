import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier_detail/Model/health_record_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class HealthRecordView extends StatefulWidget {
  final String studentId;
  const HealthRecordView({super.key, required this.studentId});

  @override
  State<HealthRecordView> createState() => _HealthRecordViewState();
}

class _HealthRecordViewState extends State<HealthRecordView> {
  Future<List<ApiResponse<List<HealthRecordModel>>>>? getDossierHealthDetails;
  List<List<HealthRecordModel>?> healthRecordModels = [];
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
          callGetDossierHealthDetails(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetDossierHealthDetails(List<Session> sessions) {
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<HealthRecordModel>>>> futures = [];

    for (var session in sessions) {
      futures.add(StudentDossierDetailViewModel.instance.getDossierHealthDetail(
        sessionId: session.sessionCode,
        studentId: widget.studentId,
      ));
    }

    // Wait for all futures to complete
    var future = Future.wait(futures).then((responses) {
      List<List<HealthRecordModel>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var record in data) {
        if (record != null && record.isNotEmpty) {
          healthRecordModels.add(record);
        }
      }

      if (healthRecordModels.isEmpty) {
        loadMore();
      }
      setState(() {});
      return responses;
    });
    getDossierHealthDetails ??= future;
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
    callGetDossierHealthDetails(nextSessions);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: getSessionListFuture,
        builder: (context, snapshot) {
          if (healthRecordModels.isEmpty) {
            return const NoDataWidget();
          }
          return Column(
            spacing: 16,
            children: [
              AppFutureBuilder(
                  future: getDossierHealthDetails,
                  builder: (context, snapshot) {
                    // Check if all sessions have empty data
                    bool allEmpty = healthRecordModels
                        .every((model) => model == null || model.isEmpty);

                    if (allEmpty) {
                      return const NoDataWidget();
                    }

                    return Column(
                      spacing: 24,
                      children: [
                        for (int i = 0; i < selectedSessions.length; i++)
                          if (healthRecordModels.length > i &&
                              healthRecordModels[i] != null &&
                              healthRecordModels[i]!.isNotEmpty)
                            Column(
                              spacing: 16,
                              children: [
                                Text(
                                  healthRecordModels[i]!.first.sessionName ??
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
                                        text: "Diagnosis", width: 70),
                                    TableColumnConfiguration(
                                        text: "Referral", width: 60),
                                    TableColumnConfiguration(
                                        text: "Attended By", width: 100)
                                  ],
                                  data: healthRecordModels[i]
                                          ?.asMap()
                                          .entries
                                          .map((e) {
                                        final health = e.value;
                                        final index = e.key + 1;
                                        return TableRowConfiguration(
                                          cells: [
                                            TableCellConfiguration(
                                                text: "$index", width: 30),
                                            TableCellConfiguration(
                                                text: formatAnyDateToDDMMYY(
                                                    health.visitDate ?? ""),
                                                width: 75),
                                            TableCellConfiguration(
                                                text: health.diagnosis,
                                                width: 70),
                                            TableCellConfiguration(
                                                text: health.referral,
                                                width: 60),
                                            TableCellConfiguration(
                                                text: health.diagnoseBy,
                                                width: 100)
                                          ],
                                        );
                                      }).toList() ??
                                      [],
                                  headingRowHeight: 35,
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
