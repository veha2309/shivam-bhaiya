import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/student_dossier_detail/Model/attandance_record_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class AttendanceRecordView extends StatefulWidget {
  final String studentId;

  const AttendanceRecordView({
    super.key,
    required this.studentId,
  });

  @override
  State<AttendanceRecordView> createState() => _AttendanceRecordViewState();
}

class _AttendanceRecordViewState extends State<AttendanceRecordView> {
  Future<ApiResponse<List<AttandanceRecordModel>>>?
      getDossierAttandanceRecordViewAttandanceDetail;
  List<AttandanceRecordModel>? attendanceRecordModel;

  @override
  initState() {
    super.initState();
    callGetDossierAttandanceRecordViewAttandanceDetail();
  }

  @override
  didUpdateWidget(AttendanceRecordView oldWidget) {
    super.didUpdateWidget(oldWidget);
    callGetDossierAttandanceRecordViewAttandanceDetail();
  }

  void callGetDossierAttandanceRecordViewAttandanceDetail() {
    setState(
      () {
        getDossierAttandanceRecordViewAttandanceDetail =
            StudentDossierDetailViewModel.instance
                .getDossierAttandanceRecordViewAttandanceDetail(
                    studentId: widget.studentId)
                .then(
          (response) {
            if (response.success) {
              attendanceRecordModel = response.data;
            }

            return response;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppFutureBuilder(
            future: getDossierAttandanceRecordViewAttandanceDetail,
            builder: (context, snapshot) {
              if (attendanceRecordModel?.isEmpty ?? true) {
                return const NoDataWidget();
              }
              return Column(
                children: [
                  DataTableWidget(
                    headers: [
                      TableColumnConfiguration(text: "Session", width: 55),
                      TableColumnConfiguration(text: "Class", width: 80),
                      TableColumnConfiguration(
                          text: "Class\nTeacher", width: 70),
                      TableColumnConfiguration(
                          text: "Working\nDays", width: 60),
                      TableColumnConfiguration(text: "Present", width: 100),
                      TableColumnConfiguration(text: "Absent", width: 100),
                      TableColumnConfiguration(text: "Leave", width: 100),
                      TableColumnConfiguration(text: "Att. %", width: 100)
                    ],
                    data: attendanceRecordModel?.map((academic) {
                          return TableRowConfiguration(
                            cells: [
                              TableCellConfiguration(
                                  text: academic.sessionName),
                              TableCellConfiguration(
                                  text: academic.className, width: 80),
                              TableCellConfiguration(
                                  text: academic.classTeacher, width: 70),
                              TableCellConfiguration(
                                  text: academic.totalClass, width: 60),
                              TableCellConfiguration(
                                  text: academic.present, width: 60),
                              TableCellConfiguration(
                                  text: academic.absent, width: 60),
                              TableCellConfiguration(
                                  text: academic.leave, width: 60),
                              TableCellConfiguration(
                                  text: academic.presentPercentage, width: 60),
                            ],
                          );
                        }).toList() ??
                        [],
                    headingRowHeight: 35,
                    headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.w300, fontSize: 12),
                    headingRowColor: ColorConstant.primaryColor,
                  ),
                ],
              );
            }),
      ],
    );
  }
}
