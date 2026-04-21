import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_app/attendance_daily_check_in/model/attendance_save_response_model.dart';
import 'package:school_app/attendance_daily_check_in/model/student_attendance.dart';
import 'package:school_app/attendance_daily_check_in/view_model/attendance_check_in_viewmodel.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class AttendanceDailyCheckInScreen extends StatefulWidget {
  static const String routeName = '/attendance-daily-check-in';
  final String? title;
  final ClassModel classModel;
  final Section section;
  final DateTime date;

  const AttendanceDailyCheckInScreen({
    super.key,
    this.title,
    required this.classModel,
    required this.section,
    required this.date,
  });

  @override
  State<AttendanceDailyCheckInScreen> createState() =>
      _AttendanceDailyCheckInScreenState();
}

class _AttendanceDailyCheckInScreenState
    extends State<AttendanceDailyCheckInScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<StudentAttendance>>>? getStudentAttendanceList;
  Future<ApiResponse<List<AttendanceParam>>>? getAttendanceStatusList;
  List<StudentAttendance> studentAttendanceList = [];
  List<AttendanceParam> attendanceStatusList = [];
  bool isSaveAndSubmit = false;
  bool isToday = false;
  String? day;
  String? date;
  String? classSection;

  bool isTodayDate(DateTime date) {
    DateTime now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  void initState() {
    super.initState();

    String teacherSectionCode =
        AuthViewModel.instance.getLoggedInUser()?.sectionCode ?? "";
    if (teacherSectionCode == widget.section.sectionCode) {
      isSaveAndSubmit = true;
    }

    isToday = isTodayDate(widget.date);

    day = intToDayFull(widget.date.weekday);
    date = DateFormat('dd-MM-yyyy').format(widget.date);
    classSection =
        "${widget.classModel.className}/${widget.section.sectionName}";

    callGetAttendanceStatus();
  }

  void callGetAttendanceStatus() {
    attendanceCounts = {};
    getAttendanceStatusList = AttendanceCheckInViewModel.instance
        .getAttendanceStatus()
        .then((response) {
      if (response.success) {
        callGetStudentAttendanceList();
        attendanceStatusList = response.data ?? [];
      }
      return response;
    });
  }

  void callGetStudentAttendanceList() {
    getStudentAttendanceList = AttendanceCheckInViewModel.instance
        .getStudentAttendanceList(widget.classModel.classCode,
            widget.section.sectionCode, widget.date)
        .then((response) {
      if (response.success) {
        studentAttendanceList = response.data ?? [];

        getAttendanceCounts();
        studentAttendanceList = studentAttendanceList.map((student) {
          try {
            var matchingStatus = attendanceStatusList.firstWhere(
              (element) => element.paramValue == student.attendance,
            );
            student.attendanceStatus = matchingStatus.paramValue;
            return student;
          } catch (_) {}
          return student;
        }).toList();
      }
      return response;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Daily Check In",
        body: SizedBox(
          child: SingleChildScrollView(
            child: getAttendanceDailyCheckInBody(),
          ),
        ),
      ),
    );
  }

  Widget getAttendanceDailyCheckInBody() {
    return AppFutureBuilder(
      future: getStudentAttendanceList,
      builder: (context, snapshot) {
        if (studentAttendanceList.isEmpty) {
          return const NoDataWidget();
        }
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getClassDetails(),
              const SizedBox(height: 16),
              getSetAsDefault(),
              const SizedBox(height: 16),
              getTableWithActions(),
              const SizedBox(height: 16),
              getStatusScore(),
            ],
          ),
        );
      },
    );
  }

  Widget getSetAsDefault() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Set All As: ",
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
            const SizedBox(width: 8),
            ...attendanceStatusList.map((status) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      changeAllStudentsAttendance(status.paramName ?? "");
                    });
                  },
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: ColorConstant.primaryColor,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        status.paramName ?? "",
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: fontFamily,
                          color: ColorConstant.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget getTableWithActions() {
    return Column(
      children: [
        DataTableWidget(
          headers: [
            TableColumnConfiguration(text: "Roll\nNo", width: 30),
            TableColumnConfiguration(text: "Student\nName", width: 100),
            TableColumnConfiguration(text: "Attendance", width: 200),
          ],
          data: studentAttendanceList.map(
            (studentAttendance) {
              return TableRowConfiguration(
                backgroundColor:
                    studentAttendance.attendance?.toUpperCase() == "S"
                        ? Colors.black12
                        : null,
                rowHeight: 60,
                cells: [
                  TableCellConfiguration(
                      text: studentAttendance.rollNo, width: 30),
                  TableCellConfiguration(
                      text: studentAttendance.studentName, width: 100),
                  TableCellConfiguration(
                      padding: const EdgeInsets.all(4.0),
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children:
                                attendanceStatusList.map((attendanceStatus) {
                              bool isSelected = attendanceStatus.paramValue
                                      ?.compareTo(
                                          studentAttendance.attendanceStatus ??
                                              "") ==
                                  0;

                              return InkWell(
                                onTap: () {
                                  if (studentAttendance.attendance
                                          ?.toUpperCase() ==
                                      "S") {
                                    showSnackBarOnScreen(context,
                                        "Cannot mark attendance for suspended students");
                                    return;
                                  }

                                  setState(() {
                                    studentAttendance.attendanceStatus =
                                        attendanceStatus.paramValue;
                                    studentAttendance.attendance =
                                        attendanceStatus.paramValue;

                                    int index = studentAttendanceList
                                        .indexOf(studentAttendance);

                                    if (index != -1) {
                                      studentAttendanceList[index] =
                                          studentAttendance;
                                    }
                                    getAttendanceCounts();
                                  });
                                },
                                child: Container(
                                  height: 30,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(right: 5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: ColorConstant.primaryColor,
                                        width: 1.5),
                                    color: isSelected
                                        ? ColorConstant.primaryColor
                                        : Colors.transparent,
                                  ),
                                  child: Text(
                                    attendanceStatus.paramName ?? "",
                                    textAlign: TextAlign.center,
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontFamily: fontFamily,
                                      color: isSelected
                                          ? ColorConstant.onPrimary
                                          : ColorConstant.primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      width: 200),
                ],
              );
            },
          ).toList(),
        ),
        const SizedBox(
          height: 16,
        ),
        AppButton(
          text: isSaveAndSubmit ? "Save & Submit" : "Save",
          onPressed: (isLoading) async {
            bool validation = true;

            for (var student in studentAttendanceList) {
              if (student.attendance == null || student.attendance!.isEmpty) {
                validation = false;
                break;
              }
            }

            if (!validation) {
              showSnackBarOnScreen(
                  context, "Please mark attendance for all students");
              return;
            }
            bool doesHaveAbsentMarked = false;
            List<StudentAttendance> absentStudent = [];
            for (StudentAttendance student in studentAttendanceList) {
              if (student.attendanceStatus == "A") {
                doesHaveAbsentMarked = true;
                absentStudent.add(student);
              }
            }
            if (doesHaveAbsentMarked) {
              showDialog(
                context: context,
                useRootNavigator: true,
                useSafeArea: true,
                builder: (context) => AlertDialog(
                  title: const Text(
                    "Absent student list",
                    textAlign: TextAlign.left,
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                      color: ColorConstant.primaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  titlePadding:
                      const EdgeInsets.only(left: 16, right: 16, top: 16.0),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Row(
                        children: [
                          SizedBox(
                            width: 50,
                            child: Text(
                              "R.No",
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryTextColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            flex: 4,
                            child: Text(
                              "Name",
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryTextColor,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              "Adm.No",
                              textAlign: TextAlign.left,
                              overflow: TextOverflow.ellipsis,
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ColorConstant.primaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      ...absentStudent.map((student) {
                        return Row(
                          children: [
                            SizedBox(
                              width: 50,
                              child: Text(
                                "${student.rollNo}",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  color: ColorConstant.primaryTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                "${student.studentName}",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  color: ColorConstant.primaryTextColor,
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                "${student.admissionNo}",
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  color: ColorConstant.primaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                  contentPadding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16.0,
                    bottom: 16.0,
                  ),
                  actionsAlignment: MainAxisAlignment.end,
                  actionsPadding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 16.0,
                  ),
                  actions: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: AppButton(
                            text: "Cancel",
                            onPressed: (p0) {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: AppButton(
                            text: "Continue",
                            onPressed: (p0) {
                              Navigator.of(context).pop();
                              onSaveAndSubmit(isLoading);
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            } else {
              onSaveAndSubmit(isLoading);
            }
          },
        ),
      ],
    );
  }

  Widget getClassDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Date: $date",
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          "Day: $day",
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          "Class/Section: $classSection",
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget getStatusScore() {
    List<Widget> widgets = [];
    if (attendanceCounts.isNotEmpty) {
      for (var entry in attendanceCounts.entries) {
        widgets.add(Text(
          "${entry.key} ${entry.value}",
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            fontSize: 16,
            fontFamily: fontFamily,
          ),
        ));
      }
    }
    return attendanceCounts.isEmpty
        ? const SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...widgets,
              Text(
                "Total = ${studentAttendanceList.length}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          );
  }

  Map<String, int> attendanceCounts = {};

  Map<String, int> getAttendanceCounts() {
    attendanceCounts = {};
    for (var student in studentAttendanceList) {
      if (student.attendanceStatus != null &&
          student.attendanceStatus!.isNotEmpty) {
        attendanceCounts[student.attendanceStatus!] =
            (attendanceCounts[student.attendanceStatus] ?? 0) + 1;
      }
    }

    return attendanceCounts;
  }

  void changeAllStudentsAttendance(String status) {
    for (int i = 0; i < studentAttendanceList.length; i++) {
      if (studentAttendanceList[i].attendance?.toUpperCase() == "S") {
        continue;
      }
      studentAttendanceList[i].attendanceStatus = status;
      // Find the corresponding attendance value from attendanceStatusList
      var matchingStatus = attendanceStatusList.firstWhere(
        (element) => element.attendanceValue == status,
        orElse: () => attendanceStatusList.first,
      );
      studentAttendanceList[i].attendance = matchingStatus.paramValue;
    }
    getAttendanceCounts();
  }

  void onSaveAndSubmit(ValueNotifier<bool> isLoading) async {
    User? user = AuthViewModel.instance.getLoggedInUser();

    bool validation = true;

    for (var student in studentAttendanceList) {
      if (student.attendance == null || student.attendance!.isEmpty) {
        validation = false;
        break;
      }
    }

    if (!validation) {
      showSnackBarOnScreen(context, "Please mark attendance for all students");
      return;
    }

    List<AttendanceSaveResponseModel> saveAttendanceList =
        convertToAttendanceSaveResponseModel(
            studentAttendanceList, user?.username ?? "");
    isLoading.value = true;
    ApiResponse response = await AttendanceCheckInViewModel.instance
        .saveAttendance(saveAttendanceList);
    isLoading.value = false;
    if (!mounted) return;

    if (!response.success) {
      showSnackBarOnScreen(context, "Something went wrong");
    } else {
      popScreen(context);
      showSnackBarOnScreen(context, "Record Saved");
    }
  }
}
