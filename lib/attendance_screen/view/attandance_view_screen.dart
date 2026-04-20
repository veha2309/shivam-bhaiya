import 'package:flutter/material.dart';
import 'package:school_app/attendance_screen/model/view_attendance.dart';
import 'package:school_app/attendance_screen/view_model/attendance_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class AttandanceViewScreen extends StatefulWidget {
  static const String routeName = '/attendance-view';
  const AttandanceViewScreen({super.key});

  @override
  State<AttandanceViewScreen> createState() => _AttandanceViewScreenState();
}

class _AttandanceViewScreenState extends State<AttandanceViewScreen> {
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<StudentViewAttendance>>>? getStudentListFuture;

  TextEditingController studentNameController = TextEditingController();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    getClassListFuture = SchoolDetailsViewModel.instance
        .getClassList()
        .then((ApiResponse<List<ClassModel>> response) {
      if (response.success) {
        classes = response.data ?? [];
      }
      return response;
    });
  }

  @override
  void dispose() {
    studentNameController.dispose();
    super.dispose();
  }

  ClassModel? selectedClass;
  Section? selectedSection;
  String? selectedDate;

  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<StudentViewAttendance> students = [];

  String monthHighestAttendance = "";
  String totalHighestAttendance = "";

  List<StudentViewAttendance> processAttendanceData(
      List<StudentViewAttendance> students) {
    Map<String, int> monthTotalDaysFrequency = {};
    for (StudentViewAttendance student in students) {
      List<String> monthAttendanceParts = student.monthAttendance!.split('/');
      if (monthAttendanceParts.length == 2) {
        String presentDays = monthAttendanceParts[0];
        String totalDays = monthAttendanceParts[1];

        // Update frequency
        monthTotalDaysFrequency[totalDays] =
            (monthTotalDaysFrequency[totalDays] ?? 0) + 1;

        student.totalWorkingDaysMonth = totalDays.toString();
        student.presentDaysMonth = presentDays.toString();
      }
    }

    // Sort the map by keys in descending order
    monthTotalDaysFrequency = Map.fromEntries(
        monthTotalDaysFrequency.entries.toList()
          ..sort((e1, e2) => int.parse(e2.key).compareTo(int.parse(e1.key))));

    for (StudentViewAttendance student in students) {
      if (monthTotalDaysFrequency.keys.first == student.totalWorkingDaysMonth) {
        student.showTotalDaysMonth = false;
      } else {
        student.showTotalDaysMonth = true;
      }

      student.monthHighestAttendance = monthTotalDaysFrequency.keys.first;
    }
    monthHighestAttendance = monthTotalDaysFrequency.keys.first;

    Map<String, int> totalDaysFrequency = {};
    for (StudentViewAttendance student in students) {
      List<String> totalAttendancePart = student.totalAttendance!.split('/');
      if (totalAttendancePart.length == 2) {
        String presentDays = totalAttendancePart[0];
        String totalDays = totalAttendancePart[1];

        // Update frequency
        totalDaysFrequency[totalDays] =
            (totalDaysFrequency[totalDays] ?? 0) + 1;

        student.totalWorkingDaysTotal = totalDays.toString();
        student.presentDaysTotal = presentDays.toString();
      }
    }

    // Sort the map by keys in descending order
    totalDaysFrequency = Map.fromEntries(totalDaysFrequency.entries.toList()
      ..sort((e1, e2) => int.parse(e2.key).compareTo(int.parse(e1.key))));

    for (StudentViewAttendance student in students) {
      if (totalDaysFrequency.keys.first == student.totalWorkingDaysTotal) {
        student.showTotalDaysTotal = false;
      } else {
        student.showTotalDaysTotal = true;
      }

      student.totalHighestAttendance = totalDaysFrequency.keys.first;
    }
    totalHighestAttendance = totalDaysFrequency.keys.first;
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "View Cumulative Attendance",
        body: studentProfileSearchScreenBody(context),
      ),
    );
  }

  Widget studentProfileSearchScreenBody(BuildContext context) {
    return AppFutureBuilder(
        future: getClassListFuture,
        builder: (context, snapshot) {
          if (classes.isEmpty) {
            return const NoDataWidget();
          }
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16,
                children: [
                  AppTextfield(
                    onTap: () {
                      openClassBottomSheet(context, classes, (classModel) {
                        setState(() {
                          selectedClass = classModel;
                          selectedSection = null;
                          getSectionListFuture = SchoolDetailsViewModel.instance
                              .getSectionList(classModel.classCode)
                              .then((ApiResponse<List<Section>> response) {
                            if (response.success) {
                              sections = response.data ?? [];
                            }
                            return response;
                          });
                        });
                      });
                    },
                    enabled: false,
                    hintText: selectedClass?.className ?? 'Select Class',
                  ),
                  AppTextfield(
                    onTap: () {
                      openSectionBottomSheet(context, sections, (section) {
                        setState(() {
                          selectedSection = section;
                        });
                      });
                    },
                    enabled: false,
                    hintText: selectedSection?.sectionName ?? 'Select Section',
                  ),
                  AppTextfield(
                    onTap: () {
                      showMonthsBottomSheet(context, (selectedMonth) {
                        setState(() {
                          selectedDate = selectedMonth;
                        });
                      });
                    },
                    enabled: false,
                    hintText: selectedDate ?? 'Select Month',
                  ),
                  AppButton(
                    onPressed: (_) {
                      isLoadingNotifier.value = true;

                      if (selectedClass == null ||
                          selectedSection == null ||
                          selectedDate == null) {
                        isLoadingNotifier.value = false;
                        showSnackBarOnScreen(context,
                            "Please select class, section, and month.");
                        return;
                      }
                      getStudentListFuture = ViewAttendanceViewModel.instance
                          .getViewAttendanceData(
                              selectedClass!.classCode,
                              selectedSection!.sectionCode,
                              monthToInt(selectedDate!))
                          .then((ApiResponse<List<StudentViewAttendance>>
                              response) {
                        isLoadingNotifier.value = false;
                        if (response.success) {
                          setState(() {
                            students =
                                processAttendanceData(response.data ?? []);
                            students = students
                              ..sort((a, b) => int.parse(a.rollNo ?? "0")
                                  .compareTo(int.parse(b.rollNo ?? "0")));
                          });
                        }
                        return response;
                      });
                    },
                    text: "SEARCH",
                  ),
                  if (students.isNotEmpty)
                    SizedBox(
                      child: DataTableWidget(
                        headers: [
                          TableColumnConfiguration(text: "Roll\nNo", width: 40),
                          TableColumnConfiguration(
                              text: "Student\nName", width: 120),
                          TableColumnConfiguration(
                              child: Column(
                                children: [
                                  const SizedBox(height: 2),
                                  const Expanded(
                                    child: Text(
                                      "Monthly\nAttendance",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: fontFamily,
                                        color: ColorConstant.onPrimary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$monthHighestAttendance working ${monthHighestAttendance == "1" ? "day" : "days"}",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: fontFamily,
                                            color: ColorConstant.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              width: 100),
                          TableColumnConfiguration(
                              child: Column(
                                children: [
                                  const SizedBox(height: 2),
                                  const Expanded(
                                    child: Text(
                                      "Cumulative\nAttendance",
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      textScaler: TextScaler.linear(1.0),
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: fontFamily,
                                        color: ColorConstant.onPrimary,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "$totalHighestAttendance working ${totalHighestAttendance == "1" ? "day" : "days"}",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: fontFamily,
                                            color: ColorConstant.onPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              width: 100),
                        ],
                        data: students.asMap().entries.map((entry) {
                          final student = entry.value;
                          return TableRowConfiguration(
                            rowHeight: 55,
                            onTap: (_) {},
                            cells: [
                              TableCellConfiguration(
                                  text: student.rollNo, width: 40),
                              TableCellConfiguration(
                                  text: student.studentName, width: 120),
                              TableCellConfiguration(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${(student.showTotalDaysMonth ?? true) ? student.monthAttendance ?? "-" : student.presentDaysMonth ?? "-"} (${student.monthPercentage}%)",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  text: student.monthAttendance,
                                  width: 100),
                              TableCellConfiguration(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "${(student.showTotalDaysTotal ?? true) ? student.totalAttendance ?? "-" : student.presentDaysTotal ?? "-"} (${student.totalPercentage}%)",
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.center,
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  text: student.monthAttendance,
                                  width: 100),
                            ],
                          );
                        }).toList(),
                        headingRowHeight: 55,
                        headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 12),
                        headingRowColor: ColorConstant.primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          );
        });
  }
}
