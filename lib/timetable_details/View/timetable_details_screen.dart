import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/teacher_time_table/View/teacher_time_table_screen.dart';
import 'package:school_app/timetable_details/Model/timetable_details.dart';
import 'package:school_app/timetable_details/ViewModel/timetable_details_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class TimetableDetailsScreen extends StatefulWidget {
  static const String routeName = '/timetable-details';
  final String? title;
  const TimetableDetailsScreen({super.key, this.title});

  @override
  State<TimetableDetailsScreen> createState() => _TimetableDetailsScreenState();
}

class _TimetableDetailsScreenState extends State<TimetableDetailsScreen> {
  int day = 1;
  Future<ApiResponse<CompleteTeacherTimetable>>? getAllTeacherTimeTableFuture;
  CompleteTeacherTimetable? completeTeacherTimetable;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    callGetAllTeacherTimeTable();
  }

  void callGetAllTeacherTimeTable() {
    getAllTeacherTimeTableFuture = TimetableDetailsViewModel.instance
        .getAllTeacherTimeTable()
        .then((response) {
      if (response.success) {
        completeTeacherTimetable = response.data!;
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Timetable Details",
        body: timeTableDetailsBody(context),
      ),
    );
  }

  Widget timeTableDetailsBody(BuildContext context) {
    return AppFutureBuilder(
      future: getAllTeacherTimeTableFuture,
      builder: (context, snapshot) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16.0,
              children: [
                if (completeTeacherTimetable != null &&
                    completeTeacherTimetable?.timeTable != null &&
                    (completeTeacherTimetable!.timeTable?.isNotEmpty ?? false))
                  DataTableWidget(
                    headingRowHeight: 45,
                    headingTextStyle: const TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w300,
                      fontSize: 12,
                    ),
                    headingRowColor: ColorConstant.primaryColor,
                    dataTextStyle: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 12,
                    ),
                    headers: [
                      TableColumnConfiguration(text: "S.No", width: 30),
                      TableColumnConfiguration(
                          text: "Teacher's Name", width: 100),
                      TableColumnConfiguration(
                          text: "Teacher's\nCode", width: 80),
                      TableColumnConfiguration(text: "M", width: 30),
                      TableColumnConfiguration(text: "T", width: 30),
                      TableColumnConfiguration(text: "W", width: 30),
                      TableColumnConfiguration(text: "T", width: 30),
                      TableColumnConfiguration(text: "F", width: 30),
                      TableColumnConfiguration(text: "S", width: 30),
                      TableColumnConfiguration(text: "Total", width: 40),
                    ],
                    data: completeTeacherTimetable?.timeTable
                            ?.asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final teacherTimeTable = entry.value;
                          return TableRowConfiguration(
                            rowHeight: 45,
                            onTap: (index) {
                              String? teacherCode = completeTeacherTimetable
                                  ?.timeTable?[index].teacherCode;
                              if (teacherCode != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TeacherTimeTableScreen(
                                      teacherId: completeTeacherTimetable!
                                              .timeTable?[index].teacherCode ??
                                          "",
                                    ),
                                  ),
                                );
                              }
                            },
                            cells: [
                              TableCellConfiguration(
                                text: (index + 1).toString(),
                                width: 30,
                              ),
                              TableCellConfiguration(
                                text: teacherTimeTable.teacherName,
                                width: 100,
                              ),
                              TableCellConfiguration(
                                text: teacherTimeTable.teacherCode ?? "",
                                width: 80,
                              ),
                              TableCellConfiguration(
                                  text: teacherTimeTable.monday.toString(),
                                  width: 30),
                              TableCellConfiguration(
                                  text: teacherTimeTable.tuesday.toString(),
                                  width: 30),
                              TableCellConfiguration(
                                  text: teacherTimeTable.wednesday.toString(),
                                  width: 30),
                              TableCellConfiguration(
                                  text: teacherTimeTable.thursday.toString(),
                                  width: 30),
                              TableCellConfiguration(
                                  text: teacherTimeTable.friday.toString(),
                                  width: 30),
                              TableCellConfiguration(
                                  text: "${teacherTimeTable.saturday ?? 0}",
                                  width: 30),
                              TableCellConfiguration(
                                  text: teacherTimeTable.total.toString(),
                                  width: 35),
                            ],
                          );
                        }).toList() ??
                        [],
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
