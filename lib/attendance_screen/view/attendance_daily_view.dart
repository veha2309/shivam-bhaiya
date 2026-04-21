import 'package:flutter/material.dart';
import 'package:school_app/attendance_screen/model/view_attendance.dart';
import 'package:school_app/attendance_screen/view/attendance_daily_class_wise_view.dart';
import 'package:school_app/attendance_screen/view_model/attendance_viewmodel.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/utils.dart';
import 'package:school_app/utils/constants.dart';

class AttendanceDailyView extends StatefulWidget {
  const AttendanceDailyView({super.key});

  @override
  State<AttendanceDailyView> createState() => _AttendanceDailyViewState();
}

class _AttendanceDailyViewState extends State<AttendanceDailyView> {
  Future<ApiResponse<List<TeacherAttendanceStatus>>>?
      getTeacherAttendanceStatus;

  @override
  void initState() {
    super.initState();
    getTeacherAttendanceStatus =
        ViewAttendanceViewModel.instance.getTeacherAttendanceStatus();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: 'View Daily Attendance',
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                AppFutureBuilder<ApiResponse<List<TeacherAttendanceStatus>>>(
                  future: getTeacherAttendanceStatus,
                  builder: (context, snapshot) {
                    List<TeacherAttendanceStatus> teacherStatus =
                        snapshot.data?.data ?? [];

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Text(
                            getDDMMYYYYInNum(DateTime.now()),
                            textScaler: const TextScaler.linear(1.0),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                        ),
                        DataTableWidget(
                          headers: [
                            TableColumnConfiguration(text: "S.No", width: 30),
                            TableColumnConfiguration(text: "Class", width: 120),
                            TableColumnConfiguration(
                                text: "Status", width: 120),
                          ],
                          data: teacherStatus.asMap().entries.map((entry) {
                            int idx = entry.key;
                            TeacherAttendanceStatus status = entry.value;
                            return TableRowConfiguration(
                              rowHeight: 45,
                              cells: [
                                TableCellConfiguration(
                                    text: (idx + 1).toString(), width: 30),
                                TableCellConfiguration(text: status.className),
                                TableCellConfiguration(
                                  width: 120,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        status.attStatus,
                                      ),
                                      const SizedBox(width: 6),
                                      const Icon(
                                        Icons.search,
                                        color: ColorConstant.primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              onTap: (_) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AttendanceDailyClassWiseView(
                                            classStatus: status),
                                  ),
                                );
                              },
                            );
                          }).toList(),
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
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
