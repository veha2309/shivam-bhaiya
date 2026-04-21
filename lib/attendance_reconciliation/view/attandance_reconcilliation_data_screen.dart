import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_daywise_model.dart';
import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_student_model.dart';
import 'package:school_app/attendance_reconciliation/view/attendance_reconciliation_screen.dart';
import 'package:school_app/attendance_reconciliation/view_model/attendance_recon_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class AttandanceReconcilliationDataScreen extends StatefulWidget {
  static const String routeName = '/attendance-reconciliation-data';
  final AttandanceReconcilliationStudentModel student;
  final String month;

  const AttandanceReconcilliationDataScreen({
    super.key,
    required this.student,
    required this.month,
  });

  @override
  State<AttandanceReconcilliationDataScreen> createState() =>
      _AttandanceReconcilliationDataScreenState();
}

class _AttandanceReconcilliationDataScreenState
    extends State<AttandanceReconcilliationDataScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  Future<ApiResponse<List<AttandanceReconcilliationDaywiseModel>>>?
      getAttendanceReconDataFuture;
  List<AttandanceReconcilliationDaywiseModel> attendanceReconData = [];
  EventController eventController = EventController();

  int _getMonthNumberFromMMM(String month) {
    final months = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MAY': 5,
      'JUN': 6,
      'JUL': 7,
      'AUG': 8,
      'SEP': 9,
      'OCT': 10,
      'NOV': 11,
      'DEC': 12
    };
    return months[month] ?? DateTime.now().month;
  }

  @override
  void initState() {
    super.initState();
    // Set initial selected date based on the provided month
    final currentYear = DateTime.now().year;
    final monthNumber = _getMonthNumberFromMMM(widget.month);
    selectedDate.value = DateTime(currentYear, monthNumber, 1);

    callGetAttendanceReconDataFuture();
  }

  void callGetAttendanceReconDataFuture() {
    getAttendanceReconDataFuture = AttendanceReconViewmodel.instance
        .fetchAttendanceDataByStudentId(widget.student.sessionCode ?? "",
            widget.month, widget.student.id ?? "")
        .then((response) {
      if (response.success) {
        attendanceReconData = response.data ?? [];
        if (attendanceReconData.isNotEmpty &&
            attendanceReconData.first.date != null) {
          // Parse the date string and update selectedDate
          List<String> dateParts = attendanceReconData.first.date!.split('-');
          selectedDate.value = DateTime(
            int.parse(dateParts[0]), // year
            int.parse(dateParts[1]), // month
            int.parse(dateParts[2]), // day
          );
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            monthViewKey.currentState?.animateToMonth(selectedDate.value);
          });
        }
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: eventController,
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: "View Attendance",
          body: circularBody(context),
        ),
      ),
    );
  }

  Widget circularBody(BuildContext context) {
    return SingleChildScrollView(
      child: AppFutureBuilder(
        future: getAttendanceReconDataFuture,
        builder: (context, snapshot) {
          return Column(
            children: [
              const SizedBox(height: 12),
              Column(
                spacing: 8,
                children: [
                  Text(
                    widget.student.name ?? "",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.primaryColor,
                    ),
                  ),
                  Text(
                    "Class & Section - ${widget.student.className}-${widget.student.sectionName}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 14,
                      color: ColorConstant.inactiveColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: SizedBox(
                  height: 400,
                  child: ValueListenableBuilder(
                    valueListenable: selectedDate,
                    builder: (context, _, __) {
                      return MonthView(
                        controller: eventController,
                        key: monthViewKey,
                        onPageChange: (date, page) {},
                        pageViewPhysics: const NeverScrollableScrollPhysics(),
                        useAvailableVerticalSpace: true,
                        hideDaysNotInMonth: true,
                        showBorder: false,
                        cellBuilder: (date, event, isToday, isInMonth,
                            hideDaysNotInMonth) {
                          String formattedDate =
                              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          var dayData = attendanceReconData.firstWhere(
                            (element) => element.date == formattedDate,
                            orElse: () =>
                                AttandanceReconcilliationDaywiseModel(),
                          );

                          Color? dotColor;
                          bool isNotApplicable = false;

                          switch (dayData.status) {
                            case "MARKED":
                              dotColor = Colors.green;
                              break;
                            case "NOT MARKED":
                              dotColor = Colors.red;
                              break;
                            case "NOT APPLICABLE":
                              isNotApplicable = true;
                              break;
                          }

                          return Stack(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  child: Text(
                                    date.day.toString(),
                                    textScaler: const TextScaler.linear(1.0),
                                    style: TextStyle(
                                      color: isNotApplicable
                                          ? Colors.grey
                                          : isInMonth
                                              ? ColorConstant.primaryTextColor
                                              : ColorConstant
                                                  .secondaryTextColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ),
                              ),
                              if (dotColor != null)
                                Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    margin:
                                        const EdgeInsets.only(top: 7, right: 7),
                                    height: 15,
                                    width: 15,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: dotColor,
                                    ),
                                    alignment: Alignment.center,
                                    child: dayData.attendance != null
                                        ? Text(
                                            dayData.attendance ?? "",
                                            textAlign: TextAlign.center,
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: const TextStyle(
                                              color: ColorConstant
                                                  .primaryTextColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: fontFamily,
                                            ),
                                          )
                                        : null,
                                  ),
                                ),
                              // if (dayData.attendance != null)
                              //   Align(
                              //     alignment: Alignment.topRight,
                              //     child: Container(
                              //       margin: const EdgeInsets.only(
                              //           top: 10, right: 10),
                              //       height: 12,
                              //       width: 12,
                              //       decoration: BoxDecoration(
                              //         shape: BoxShape.circle,
                              //         color: dotColor,
                              //       ),

                              //     ),
                              //   ),
                            ],
                          );
                        },
                        headerBuilder: (date) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "${monthIntToString(date.month)} ${date.year}",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                color: ColorConstant.secondaryTextColor,
                                thickness: 0.3,
                              ),
                            ],
                          );
                        },
                        weekDayBuilder: (day) {
                          return Container(
                            decoration: const BoxDecoration(),
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                intToWeekDay(day),
                                textScaler: const TextScaler.linear(1.0),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: ColorConstant.secondaryTextColor,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: fontFamily,
                                ),
                              ),
                            ),
                          );
                        },
                        borderColor: ColorConstant.primaryColor,
                        onCellTap: (events, date) async {
                          String formattedDate =
                              "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          var dayData = attendanceReconData.firstWhere(
                            (element) => element.date == formattedDate,
                            orElse: () =>
                                AttandanceReconcilliationDaywiseModel(),
                          );

                          if (dayData.date != null) {
                            bool isUpdate = false;
                            switch (dayData.status) {
                              case "MARKED":
                                isUpdate = true;
                                break;
                              case "NOT MARKED":
                              case "NOT APPLICABLE":
                                break;
                            }
                            await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    AttendanceReconciliationScreen(
                                  isUpdate: isUpdate,
                                  daywiseModel: dayData,
                                  studentModel: widget.student,
                                ),
                              ),
                            );
                            callGetAttendanceReconDataFuture();
                            setState(() {});
                          }
                        },
                      );
                    },
                  ),
                ),
              ),
              // New attendance statistics section
              ValueListenableBuilder(
                  valueListenable: selectedDate,
                  builder: (context, _, __) {
                    return Container(
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.symmetric(horizontal: 12.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: ColorConstant.primaryColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: () {
                            var presentDays = 0;
                            var absentDays = 0;
                            for (var item in attendanceReconData) {
                              if (item.attendance?.toUpperCase() == "P") {
                                presentDays++;
                              } else if (item.attendance != null) {
                                absentDays++;
                              }
                            }
                            return [
                              _buildStatItem(
                                "Working Days",
                                widget.student.workingDays?.toString() ?? "0",
                              ),
                              _buildStatItem(
                                "Present",
                                presentDays.toString(),
                              ),
                              _buildStatItem(
                                "Absent",
                                absentDays.toString(),
                              ),
                            ];
                          }()),
                    );
                  }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            color: ColorConstant.secondaryTextColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstant.primaryColor,
          ),
        ),
      ],
    );
  }
}
