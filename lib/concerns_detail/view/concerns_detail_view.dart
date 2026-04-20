import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/concerns/view/concerns_view.dart';
import 'package:school_app/concerns_detail/model/concerns_detail_model.dart';
import 'package:school_app/concerns_detail/view_model/concerns_detail_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class ConcernsDetailView extends StatefulWidget {
  static const String routeName = '/concerns-detail';
  final String? title;
  final String studentId;
  final String? studentName;
  final ConcernsViewScreenType screenType;
  final bool cardView;
  final bool shouldShowScaffold;

  const ConcernsDetailView({
    super.key,
    required this.studentId,
    required this.screenType,
    this.cardView = true,
    this.studentName,
    this.title,
    this.shouldShowScaffold = true,
  });

  @override
  State<ConcernsDetailView> createState() => _ConcernsDetailViewState();
}

class _ConcernsDetailViewState extends State<ConcernsDetailView> {
  Future<List<ApiResponse<List<ConcernsDetailModel>>>>? getConcernsDetails;
  List<List<ConcernsDetailModel>?> concernsModels = [];
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
          callGetConcernsDetails(selectedSessions);
        }
      }
      return response;
    });
  }

  Future<void> callGetConcernsDetails(List<Session> sessions) async {
    // Create a list of futures for the sessions
    List<Future<ApiResponse<List<ConcernsDetailModel>>>> futures = [];

    for (var session in sessions) {
      switch (widget.screenType) {
        case ConcernsViewScreenType.disciplineCard:
          futures.add(ConcernsDetailViewModel.instance
              .getStudentDisciplineCardArray(
                  widget.studentId, session.sessionCode));
          break;
        case ConcernsViewScreenType.discipline:
          futures.add(ConcernsDetailViewModel.instance
              .getStudentDisciplineDefaulterData(
                  widget.studentId, session.sessionCode));
          break;
        case ConcernsViewScreenType.academicDiscipline:
          futures.add(ConcernsDetailViewModel.instance
              .getStudentDisciplineAcademicArray(
                  widget.studentId, session.sessionCode));
          break;
      }
    }

    var future = Future.wait(futures).then((responses) {
      List<List<ConcernsDetailModel>?> data = responses
          .map((response) => response.success ? response.data : null)
          .toList();
      for (var concern in data) {
        if (concern != null && concern.isNotEmpty) {
          concernsModels.add(concern);
        }
      }

      if (concernsModels.isEmpty) {
        loadMore();
      }
      setState(() {});
      return responses;
    });
    getConcernsDetails ??= future;
    await future;
  }

  Future<void> loadMore() async {
    if (sessions.isEmpty) {
      return;
    }
    // Get next three sessions starting from the last fetched index
    sessions.removeRange(0, min(3, sessions.length));
    List<Session> nextSessions = sessions.take(3).toList().cast<Session>();

    // Add the new sessions to the selected sessions list
    selectedSessions.addAll(nextSessions);

    // Call the API for the new sessions
    await callGetConcernsDetails(nextSessions);
  }

  Widget body(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppFutureBuilder(
          future: getSessionListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return SingleChildScrollView(
              child: Column(
                spacing: 16,
                children: [
                  AppFutureBuilder(
                      future: getConcernsDetails,
                      builder: (context, snapshot) {
                        // Check if all sessions have empty data
                        bool allEmpty = concernsModels
                            .every((model) => model == null || model.isEmpty);

                        if (allEmpty) {
                          return const NoDataWidget();
                        }

                        return Column(
                          spacing: 24,
                          children: [
                            for (int i = 0; i < selectedSessions.length; i++)
                              if (concernsModels.length > i &&
                                  concernsModels[i] != null &&
                                  concernsModels[i]!.isNotEmpty)
                                Column(
                                  spacing: 16,
                                  children: [
                                    Text(
                                      concernsModels[i]!.first.sessionName ??
                                          "--",
                                      textScaler: const TextScaler.linear(1.0),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.bold,
                                        color: ColorConstant.primaryColor,
                                      ),
                                    ),
                                    _buildSessionConcernsView(
                                        concernsModels[i]!),
                                  ],
                                ),
                            if (sessions.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: AppButton(
                                  onPressed: (isLoading) async {
                                    isLoading.value = true;
                                    await loadMore();
                                    isLoading.value = false;
                                  },
                                  text: 'Load More',
                                ),
                              ),
                          ],
                        );
                      })
                ],
              ),
            );
          }),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shouldShowScaffold) {
      return AppScaffold(
        studentName: widget.studentName,
        body: AppBody(
            title: widget.title ?? widget.screenType.getScreenTitle(),
            body: body(context)),
      );
    } else {
      return body(context);
    }
  }

  Widget _buildSessionConcernsView(List<ConcernsDetailModel> concerns) {
    return DataTableWidget(
      headers: _getHeadersForScreenType(),
      data: concerns.asMap().entries.map((valueEntry) {
        final concern = valueEntry.value;
        final index = valueEntry.key + 1;
        return TableRowConfiguration(
          rowHeight: 70,
          cells: _getCellsForScreenType(concern, index),
        );
      }).toList(),
      headingRowHeight: 50,
      headingTextStyle:
          const TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
      headingRowColor: ColorConstant.primaryColor,
    );
  }

  List<TableColumnConfiguration> _getHeadersForScreenType() {
    switch (widget.screenType) {
      case ConcernsViewScreenType.discipline:
        return [
          TableColumnConfiguration(text: "S.No", width: 30),
          TableColumnConfiguration(text: "Date", width: 75),
          TableColumnConfiguration(text: "Category", width: 150),
          TableColumnConfiguration(text: "Marked By", width: 120),
        ];
      case ConcernsViewScreenType.academicDiscipline:
        return [
          TableColumnConfiguration(text: "S.No", width: 30),
          TableColumnConfiguration(text: "Date", width: 75),
          TableColumnConfiguration(text: "Subject", width: 100),
          TableColumnConfiguration(text: "Marked By", width: 120),
          TableColumnConfiguration(text: "Defaulter", width: 150),
        ];
      case ConcernsViewScreenType.disciplineCard:
        return [
          TableColumnConfiguration(text: "S.No", width: 30),
          TableColumnConfiguration(text: "Date", width: 75),
          TableColumnConfiguration(text: "Marked By", width: 120),
          TableColumnConfiguration(text: "Defaulter", width: 150),
          TableColumnConfiguration(text: "Remark", width: 120),
        ];
    }
  }

  List<TableCellConfiguration> _getCellsForScreenType(
      ConcernsDetailModel concern, int index) {
    switch (widget.screenType) {
      case ConcernsViewScreenType.discipline:
        return [
          TableCellConfiguration(text: "$index", width: 30),
          TableCellConfiguration(
              text: formatAnyDateToDDMMYY(concern.ticketDate ?? ""), width: 75),
          TableCellConfiguration(
              text: concern.disciplineCategory ?? "", width: 150),
          TableCellConfiguration(text: concern.ticketBy ?? "", width: 120),
        ];
      case ConcernsViewScreenType.academicDiscipline:
        return [
          TableCellConfiguration(text: "$index", width: 30),
          TableCellConfiguration(
              text: formatAnyDateToDDMMYY(concern.defaulterDate ?? ""),
              width: 75),
          TableCellConfiguration(text: concern.subject ?? "", width: 100),
          TableCellConfiguration(text: concern.markedBy ?? "", width: 120),
          TableCellConfiguration(text: concern.inDefaulter ?? "", width: 150),
        ];
      case ConcernsViewScreenType.disciplineCard:
        return [
          TableCellConfiguration(text: "$index", width: 30),
          TableCellConfiguration(
              text: formatAnyDateToDDMMYY(concern.defaulterDate ?? ""),
              width: 75),
          TableCellConfiguration(text: concern.markedBy ?? "", width: 120),
          TableCellConfiguration(text: concern.inDefaulter ?? "", width: 150),
          TableCellConfiguration(text: concern.remarks ?? "", width: 120),
        ];
    }
  }
}
