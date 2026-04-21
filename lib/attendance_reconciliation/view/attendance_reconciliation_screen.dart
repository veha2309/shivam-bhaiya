import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_app/attendance_daily_check_in/model/attendance_save_response_model.dart';
import 'package:school_app/attendance_daily_check_in/view_model/attendance_check_in_viewmodel.dart';
import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_daywise_model.dart';
import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_student_model.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

enum RadioValueAttendanceReconciliation { P, A, L, ML, N }

class AttendanceReconciliationScreen extends StatefulWidget {
  static const String routeName = '/attendance-reconciliation';
  final AttandanceReconcilliationDaywiseModel daywiseModel;
  final AttandanceReconcilliationStudentModel studentModel;
  final bool isUpdate;
  const AttendanceReconciliationScreen(
      {super.key,
      required this.daywiseModel,
      required this.studentModel,
      required this.isUpdate});

  @override
  State<AttendanceReconciliationScreen> createState() =>
      _AttendanceReconciliationScreenState();
}

class _AttendanceReconciliationScreenState
    extends State<AttendanceReconciliationScreen> {
  Future<ApiResponse<List<AttendanceParam>>>? getAttendanceStatusList;
  AttendanceParam? selectedValue;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  List<AttendanceParam> attendanceStatusList = [];

  @override
  void initState() {
    super.initState();
    callGetAttendanceStatus();
  }

  @override
  didUpdateWidget(AttendanceReconciliationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    callGetAttendanceStatus();
  }

  void callGetAttendanceStatus() {
    getAttendanceStatusList = AttendanceCheckInViewModel.instance
        .getAttendanceStatus()
        .then((response) {
      if (response.success) {
        attendanceStatusList = response.data ?? [];
        try {
          selectedValue = attendanceStatusList.firstWhere((attendance) =>
              attendance.attendanceValue ==
              widget.daywiseModel.attendanceValue);
        } catch (_) {}
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "View Attendance",
        body: AppFutureBuilder(
          future: getAttendanceStatusList,
          builder: (context, snapshot) {
            return getAttendanceReconciliationBody(context);
          },
        ),
      ),
    );
  }

  Widget getAttendanceReconciliationBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: ColorConstant.primaryColor),
                  left: BorderSide(color: ColorConstant.primaryColor),
                  right: BorderSide(color: ColorConstant.primaryColor),
                ),
              ),
              child: Text(
                formatDate(widget.daywiseModel.date ?? ""),
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  color: ColorConstant.primaryColor,
                  fontFamily: fontFamily,
                  fontSize: 16,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: ColorConstant.primaryColor),
                  right: BorderSide(color: ColorConstant.primaryColor),
                ),
              ),
              child: TableWidget(
                showBorder: false,
                rows: [
                  TableRowConfiguration(
                    rowHeight: 25,
                    cells: [
                      TableCellConfiguration(
                        text: "Name",
                        padding: const EdgeInsets.only(left: 10),
                      ),
                      TableCellConfiguration(
                        text: widget.studentModel.name,
                        padding: const EdgeInsets.only(left: 10),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 25,
                    cells: [
                      TableCellConfiguration(
                        text: "Class Section",
                        padding: const EdgeInsets.only(left: 10),
                      ),
                      TableCellConfiguration(
                        text:
                            "${widget.studentModel.className}-${widget.studentModel.sectionName}",
                        padding: const EdgeInsets.only(left: 10),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 25,
                    cells: [
                      TableCellConfiguration(
                        text: "Roll No",
                        padding: const EdgeInsets.only(left: 10),
                      ),
                      TableCellConfiguration(
                        text: widget.studentModel.rollNo,
                        padding: const EdgeInsets.only(left: 10),
                      )
                    ],
                  ),
                  TableRowConfiguration(
                    rowHeight: 25,
                    cells: [
                      TableCellConfiguration(
                        text: "Admission No",
                        padding: const EdgeInsets.only(left: 10),
                      ),
                      TableCellConfiguration(
                        text: widget.studentModel.admissionNo,
                        padding: const EdgeInsets.only(left: 10),
                      )
                    ],
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: ColorConstant.primaryColor),
                  left: BorderSide(color: ColorConstant.primaryColor),
                  right: BorderSide(color: ColorConstant.primaryColor),
                ),
              ),
              child: Scrollbar(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...attendanceStatusList
                          .map((status) => getRadioButtonWidget(status))
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            AppButton(
              onPressed: (isLoading) {
                String date;

                date = formatAnyDateToDDMMYY(widget.daywiseModel.date ?? "",
                    ourputFormat: "dd/MM/yyyy");

                AttendanceSaveResponseModel response =
                    AttendanceSaveResponseModel(
                  studentId: widget.studentModel.id,
                  sectionCode: widget.studentModel.sectionCode,
                  attendance: selectedValue?.paramName,
                  dateOfAttendance: date,
                  isUpdate: widget.isUpdate ? "1" : "0",
                );

                isLoading.value = true;
                AttendanceCheckInViewModel.instance
                    .saveAttendance([response]).then((response) {
                  if (!mounted) return;
                  if (response.success) {
                    popScreen(context);
                    showSnackBarOnScreen(
                        context, "Attendance reconcile successful");
                  } else {
                    showSnackBarOnScreen(context, "Failed to save attendance");
                  }
                }).whenComplete(() {
                  isLoading.value = false;
                });
              },
              text: "Save Attendance",
              textStyle: const TextStyle(
                fontSize: 18,
                fontFamily: fontFamily,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget getRadioButtonWidget(AttendanceParam value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Column(
        children: [
          Radio(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
            groupValue: selectedValue,
            onChanged: (value) {
              setState(() {
                selectedValue = value;
              });
            },
          ),
          Text(
            value.paramName ?? "",
            textScaler: const TextScaler.linear(1.0),
            style: const TextStyle(
              fontSize: 12,
              fontFamily: fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}

String formatDate(String dateString) {
  DateTime date = DateTime.parse(dateString);
  return DateFormat("dd-MMMM-yyyy").format(date);
}
