import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/report_card/Model/report_card_model.dart';
import 'package:school_app/report_card/ViewModel/report_card_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class ReportCardScreen extends StatefulWidget {
  static const String routeName = '/report-card';
  final String? title;
  const ReportCardScreen({super.key, this.title});

  @override
  State<ReportCardScreen> createState() => _ReportCardScreenState();
}

class _ReportCardScreenState extends State<ReportCardScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<ReportCardModel>>>? getReportCardForStudentFuture;
  List<ReportCardModel> reportCardList = [];

  @override
  void initState() {
    super.initState();
    getReportCardForStudentFuture =
        ReportCardViewModel.instance.getReportCardForStudent().then((response) {
      if (response.success) {
        reportCardList = response.data ?? [];
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Report Card",
        body: SingleChildScrollView(
          child: studentProfileBody(context),
        ),
      ),
    );
  }

  Widget studentProfileBody(BuildContext context) {
    return AppFutureBuilder(
      future: getReportCardForStudentFuture,
      builder: (context, snapshot) {
        if (reportCardList.isEmpty) {
          return const NoDataWidget();
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 16.0,
            children: [
              ...reportCardList.map(
                (reportCard) => Column(
                  children: [
                    TableWidget(
                      rows: [
                        TableRowConfiguration(
                          rowHeight: 35,
                          cells: [
                            TableCellConfiguration(
                              text: "Session",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                            TableCellConfiguration(
                              text: reportCard.sessionName ?? "",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 35,
                          cells: [
                            TableCellConfiguration(
                              text: "Class/Section",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                            TableCellConfiguration(
                              text: reportCard.className ?? "",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 35,
                          cells: [
                            TableCellConfiguration(
                              text: "Teacher Name",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                            TableCellConfiguration(
                              text: reportCard.classTeacher ?? "",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                          ],
                        ),
                        TableRowConfiguration(
                          rowHeight: 35,
                          cells: [
                            TableCellConfiguration(
                              text: "Exam",
                              padding: const EdgeInsets.only(left: 10),
                            ),
                            TableCellConfiguration(
                              onTap: (_) {
                                if (reportCard.url != null) {
                                  launchURLString(reportCard.url!);
                                }
                              },
                              child: Row(
                                spacing: 8,
                                children: [
                                  Text(
                                    reportCard.term ?? "",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: const TextStyle(
                                      color: ColorConstant.inactiveColor,
                                      fontSize: 12,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (reportCard.url != null) {
                                        launchURLString(reportCard.url!);
                                      }
                                    },
                                    child: const Icon(
                                      Icons.download,
                                      size: 14,
                                      color: ColorConstant.inactiveColor,
                                    ),
                                  )
                                ],
                              ),
                              padding: const EdgeInsets.only(left: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
