import 'package:flutter/material.dart';
import 'package:school_app/attendance_screen/model/view_attendance.dart';
import 'package:school_app/attendance_screen/view_model/attendance_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class AttendanceDailyClassWiseView extends StatefulWidget {
  final TeacherAttendanceStatus classStatus;

  const AttendanceDailyClassWiseView({
    super.key,
    required this.classStatus,
  });

  @override
  State<AttendanceDailyClassWiseView> createState() =>
      _AttendanceDailyClassWiseViewState();
}

class _AttendanceDailyClassWiseViewState
    extends State<AttendanceDailyClassWiseView> {
  // Ensure TeacherAttendanceStatus has classCode and sectionCode properties
  // or adjust the property names accordingly.
  Future<ApiResponse<List<StudentDailyAttendance>>>? getStudentAttendanceFuture;

  @override
  void initState() {
    super.initState();
    getStudentAttendanceFuture = ViewAttendanceViewModel.instance
        .getSectionWiseAttendance(widget.classStatus.sectionCode);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: 'Attendance Details', // Or a more specific title
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    widget.classStatus.className,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                        color: ColorConstant.primaryColor),
                  ),
                ),
                const SizedBox(height: 12),
                AppFutureBuilder<ApiResponse<List<StudentDailyAttendance>>>(
                  future: getStudentAttendanceFuture,
                  builder: (context, snapshot) {
                    final students = snapshot.data?.data ?? [];
                    if (students.isEmpty) {
                      return const NoDataWidget();
                    }
                    return DataTableWidget(
                      headers: [
                        TableColumnConfiguration(text: "Roll No", width: 80),
                        TableColumnConfiguration(
                            text: "Student Name", width: 180),
                        TableColumnConfiguration(text: "Status", width: 100),
                      ],
                      data: students.map((student) {
                        return TableRowConfiguration(
                          rowHeight: 45,
                          cells: [
                            TableCellConfiguration(text: student.studentId),
                            TableCellConfiguration(
                                text: student.studentName, width: 180),
                            TableCellConfiguration(
                              child: Container(
                                alignment: Alignment.center,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                child: Text(
                                  "${student.attendance} ${student.specialAttendance != '-' ? "(${student.specialAttendance})" : ""}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
