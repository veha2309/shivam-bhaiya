import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier_detail/Model/reward_recognition_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class AwardRecognitionView extends StatefulWidget {
  final String studentId;
  final bool cardView;

  const AwardRecognitionView(
      {super.key, required this.studentId, this.cardView = true});

  @override
  State<AwardRecognitionView> createState() => _AwardRecognitionViewState();
}

class _AwardRecognitionViewState extends State<AwardRecognitionView> {
  Future<List<ApiResponse<List<RewardRecognitionModel>>>>?
      getDossierRewardDetails;
  List<List<RewardRecognitionModel>?> rewardRecognitionModels = [];
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
          callGetDossierRewardDetails(selectedSessions);
        }
      }
      return response;
    });
  }

  void callGetDossierRewardDetails(List<Session> sessions) {
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<RewardRecognitionModel>>>> futures = [];

    for (var session in sessions) {
      futures.add(StudentDossierDetailViewModel.instance.getDossierRewardDetail(
        sessionId: session.sessionCode,
        studentId: widget.studentId,
      ));
    }

    // Wait for all futures to complete

    var future = Future.wait(futures).then((responses) {
      List<List<RewardRecognitionModel>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var reward in data) {
        if (reward != null && reward.isNotEmpty) {
          rewardRecognitionModels.add(reward);
        }
      }

      if (rewardRecognitionModels.isEmpty) {
        loadMore();
      }
      setState(() {});
      return responses;
    });
    getDossierRewardDetails ??= future;
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
    callGetDossierRewardDetails(nextSessions);
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
        future: getSessionListFuture,
        builder: (context, snapshot) {
          if (rewardRecognitionModels.isEmpty) {
            return const NoDataWidget();
          }
          return SingleChildScrollView(
            child: Column(
              spacing: 16,
              children: [
                AppFutureBuilder(
                    future: getDossierRewardDetails,
                    builder: (context, snapshot) {
                      // Check if all sessions have empty data
                      bool allEmpty = rewardRecognitionModels
                          .every((model) => model == null || model.isEmpty);

                      if (allEmpty) {
                        return const NoDataWidget();
                      }

                      return Column(
                        spacing: 24,
                        children: [
                          for (int i = 0; i < selectedSessions.length; i++)
                            if (rewardRecognitionModels.length > i &&
                                rewardRecognitionModels[i] != null &&
                                rewardRecognitionModels[i]!.isNotEmpty)
                              Column(
                                spacing: 16,
                                children: [
                                  Text(
                                    rewardRecognitionModels[i]!
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
                                  _buildSessionRewardsView(
                                      rewardRecognitionModels[i]!),
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
                    })
              ],
            ),
          );
        });
  }

  Widget _buildSessionRewardsView(List<RewardRecognitionModel> rewards) {
    // Create a map of event types to rewards for this session
    Map<String, List<RewardRecognitionModel>> sessionRewardMap = {};

    for (var reward in rewards) {
      if (sessionRewardMap.containsKey(reward.eventType)) {
        sessionRewardMap[reward.eventType]!.add(reward);
      } else {
        sessionRewardMap[reward.eventType ?? ""] = [reward];
      }
    }

    // Define the desired order of award types
    List<String> orderedKeys = [
      "achievementaward",
      "ratnaaward",
      "interschool",
      "intraschool"
    ];

    return Column(
      children: [
        ...orderedKeys.map((orderedKey) {
          // Find matching entry in sessionRewardMap (case-insensitive)
          MapEntry<String, List<RewardRecognitionModel>>? matchingEntry;
          for (var entry in sessionRewardMap.entries) {
            if (entry.key.toLowerCase() == orderedKey.toLowerCase()) {
              matchingEntry = entry;
              break;
            }
          }

          // If no matching entry found, return empty container
          if (matchingEntry == null) {
            return const SizedBox.shrink();
          }

          String key = matchingEntry.key;
          List<RewardRecognitionModel> value = matchingEntry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(
                    color: ColorConstant.primaryColor,
                  ),
                  alignment: Alignment.topLeft,
                  child: Text(
                    key.toLowerCase() == "interschool"
                        ? "Inter-School Award(s)"
                        : key.toLowerCase() == "intraschool"
                            ? "Intra-School Award(s)"
                            : key.toLowerCase() == "achievementaward"
                                ? "High Honour Award(s)"
                                : "Vivekanand Ratna Award",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.onPrimary,
                    ),
                  ),
                ),
                DataTableWidget(
                  headers: [
                    TableColumnConfiguration(text: "Date", width: 75),
                    TableColumnConfiguration(text: "Event", width: 150),
                    TableColumnConfiguration(text: "Competition", width: 130),
                    TableColumnConfiguration(text: "Result", width: 100)
                  ],
                  data: value.asMap().entries.map((valueEntry) {
                    final reward = valueEntry.value;
                    return TableRowConfiguration(
                      rowHeight: 70,
                      cells: [
                        TableCellConfiguration(
                            text: formatAnyDateToDDMMYY(reward.eventDate ?? ""),
                            width: 80),
                        TableCellConfiguration(
                            text: reward.eventName, width: 75),
                        TableCellConfiguration(
                            text: reward.competitionName, width: 130),
                        TableCellConfiguration(text: reward.prize, width: 100)
                      ],
                    );
                  }).toList(),
                  headingRowHeight: 50,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 12),
                  headingRowColor: ColorConstant.primaryColor,
                ),
              ],
            ),
          );
        }).where((widget) => widget is! SizedBox),
      ],
    );
  }
}
