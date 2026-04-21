import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/main.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';
import 'package:school_app/upload_marks/Model/student_marks.dart';
import 'package:school_app/upload_marks/Model/upload_marks_response_model.dart';
import 'package:school_app/upload_marks/Model/upload_subject_marks.dart';
import 'package:school_app/upload_marks/View/upload_marks_screen.dart';
import 'package:school_app/upload_marks/ViewModel/upload_marks_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class UploadMarksEntryScreen extends StatefulWidget {
  static const String routeName = '/upload-marks-entry';
  final bool marksEntryEnabled;
  final UploadMarksScreenState screenState;
  final UploadSubjectMarks subject;

  const UploadMarksEntryScreen(
      {super.key,
      required this.subject,
      this.marksEntryEnabled = true,
      required this.screenState});

  @override
  State<UploadMarksEntryScreen> createState() => _UploadMarksEntryScreenState();
}

class _UploadMarksEntryScreenState extends State<UploadMarksEntryScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<StudentMarks>>>? getUploadMarksData;
  Future<ApiResponse<List<AttendanceParam>>>? getAttendanceParams;
  List<AttendanceParam> attendanceParams = [];
  AttendanceParam? defaultAttendanceParam;
  List<StudentMarks> studentMarks = [];

  bool get isGradeType => widget.subject.entryType?.toLowerCase() == "grade";

  @override
  void initState() {
    super.initState();
    getAttendanceParams =
        UploadMarksViewModel.instance.getAttendanceParams().then((response) {
      if (response.success) {
        attendanceParams = response.data ?? [];
        try {
          defaultAttendanceParam = attendanceParams.firstWhere(
            (param) => param.paramId?.compareTo("14") == 0,
          );
        } catch (_) {}
        callGetUploadMarksData();
      }
      return response;
    });
  }

  void callGetUploadMarksData() {
    setState(() {
      getUploadMarksData = UploadMarksViewModel.instance
          .getStudentListForSubject(widget.subject)
          .then((response) {
        if (response.success) {
          studentMarks = response.data ?? [];
          for (int i = 0; i < studentMarks.length; i++) {
            if (studentMarks[i].attendance?.isNotEmpty ?? false) {
              try {
                AttendanceParam attendanceParam;
                if (studentMarks[i].ml == "1" &&
                    studentMarks[i].attendance == "P") {
                  attendanceParam = attendanceParams
                      .firstWhere((param) => param.paramName == "ML");
                } else {
                  attendanceParam = attendanceParams.firstWhere((param) =>
                      param.paramValue == studentMarks[i].attendance);
                }

                studentMarks[i].attendanceParam = attendanceParam;
              } catch (_) {}
            } else {
              studentMarks[i].attendanceParam = defaultAttendanceParam;
            }
            String text = "";
            if (studentMarks[i].testMarks?.isNotEmpty ?? false) {
              text = studentMarks[i].testMarks ?? "";
            } else if (studentMarks[i].ml == "1") {
              text =
                  "${studentMarks[i].attendanceParam?.paramName ?? "ML"} Applied";
            } else {
              text = "";
            }
            studentMarks[i].controller = TextEditingController(
              text: text,
            );
          }
        }
        return response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "Upload Marks",
        body: uploadMarksEntryBody(context),
      ),
    );
  }

  Widget uploadMarksEntryBody(BuildContext context) {
    return AppFutureBuilder(
      future: getUploadMarksData,
      builder: (context, snapshot) {
        if (studentMarks.isEmpty) {
          return const NoDataWidget();
        }
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              spacing: 16.0,
              children: [
                TableWidget(rows: rows(widget.subject)),
                if (studentMarks.isNotEmpty)
                  DataTableWidget(
                    headingRowHeight: 35,
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
                      TableColumnConfiguration(text: "Roll\nNo.", width: 30),
                      TableColumnConfiguration(text: "Adm\nNo.", width: 60),
                      TableColumnConfiguration(text: "Name", width: 75),
                      TableColumnConfiguration(
                          text: "Marks Obtained", width: 100),
                      ...attendanceParams.map((param) {
                        return TableColumnConfiguration(
                            text: param.paramName, width: 35);
                      }),
                    ],
                    data: studentMarks.map(
                      (row) {
                        return TableRowConfiguration(rowHeight: 45, cells: [
                          TableCellConfiguration(
                              text: row.rollNo.toString(), width: 30),
                          TableCellConfiguration(
                              text: row.admissionNo, width: 60),
                          TableCellConfiguration(
                              text: row.studentName, width: 75),
                          TableCellConfiguration(
                            padding: const EdgeInsets.all(5),
                            child: AppTextfield(
                              textStyle: TextStyle(
                                  fontSize: row.ml == "1" ? 10 : null),
                              hintText: "",
                              contentPadding: EdgeInsets.zero,
                              controller: row.controller,
                              enabled: (row.attendanceParam?.paramName == "P" ||
                                      row.attendanceParam == null) &&
                                  widget.marksEntryEnabled,
                              showIcon: false,
                              keyboardType: isGradeType
                                  ? TextInputType.text
                                  : const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (p0) {
                                row.testMarks = p0;
                                row.controller?.value = TextEditingValue(
                                  text: p0,
                                );
                              },
                            ),
                            width: 100,
                          ),
                          ...attendanceParams.map((param) {
                            return TableCellConfiguration(
                              onTap: (p0) {
                                if (!widget.marksEntryEnabled) {
                                  return;
                                }
                                setState(() {
                                  row.attendanceParam = param;
                                  if (row.attendanceParam?.paramName != "P") {
                                    if (row.attendanceParam?.paramId
                                            ?.compareTo("15") ==
                                        0) {
                                      row.testMarks = "0";
                                    } else {
                                      row.testMarks = null;
                                    }
                                    row.controller?.value = TextEditingValue(
                                      text: row.testMarks ?? "",
                                    );
                                  }
                                });
                              },
                              width: 35,
                              child: AbsorbPointer(
                                absorbing: true,
                                child: Radio(
                                  value: param.paramName?.compareTo(
                                          row.attendanceParam?.paramName ??
                                              "") ==
                                      0,
                                  groupValue: true,
                                  onChanged: (value) {},
                                ),
                              ),
                            );
                          }),
                        ]);
                      },
                    ).toList(),
                  ),
                if (widget.marksEntryEnabled)
                  AppButton(
                    onPressed: (_) => callSaveUploadMarksApi(),
                    text: "SAVE",
                  )
              ],
            ),
          ),
        );
      },
    );
  }

  void callSaveUploadMarksApi() {
    bool validate = true;

    for (int i = 0; i < studentMarks.length; i++) {
      if (studentMarks[i].attendanceParam?.paramId?.compareTo("14") == 0) {
        if (studentMarks[i].testMarks?.trim().isEmpty ?? true) {
          validate = false;
          break;
        } else {
          String studentGivenMarks = studentMarks[i].testMarks ?? "";
          num? studentParsedMarks = num.tryParse(studentGivenMarks);
          if (isGradeType) {
            if (studentGivenMarks.isEmpty) {
              showSnackBarOnScreen(
                  context, "Please enter valid grades for present students");
              return;
            }
          } else if ((studentParsedMarks == null ||
              studentParsedMarks < 0 ||
              studentParsedMarks >
                  (num.tryParse(widget.subject.maxMarks ?? "") ?? 100))) {
            showSnackBarOnScreen(
                context, "Please enter valid marks for present students");
            return;
          }
        }
      } else if (studentMarks[i].attendanceParam?.paramId?.compareTo("15") ==
          0) {
        String studentGivenMarks = studentMarks[i].testMarks ?? "";

        if (studentGivenMarks.isNotEmpty) {
          int? studentParsedMarks = int.tryParse(studentGivenMarks);
          if (studentParsedMarks != null && studentParsedMarks > 0) {
            showSnackBarOnScreen(
                context, "Please enter 0 marks for absent students");
            return;
          }
        }
      }
    }

    if (!validate) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter marks for all present students",
            textScaler: TextScaler.linear(1.0),
            style: TextStyle(
              fontSize: 14,
              fontFamily: fontFamily,
            ),
          ),
        ),
      );
      return;
    }

    List<String> studentIdList = [];

    List<UploadMarksStudentMark> uploadMarksStudentMarks =
        studentMarks.map((marks) {
      studentIdList.add(marks.studentId ?? "");

      String? marksValue;

      if (marks.attendanceParam?.paramId?.compareTo("14") == 0) {
        marksValue = marks.testMarks;
      } else if (marks.attendanceParam?.paramId?.compareTo("15") == 0) {
        marksValue = "0";
      }

      return UploadMarksStudentMark(
          studentId: marks.studentId ?? "",
          marks: marksValue,
          paramValue: marks.attendanceParam?.paramValue ?? "",
          attendanceValue: marks.attendanceParam?.attendanceValue ?? "",
          group: "-");
    }).toList();

    String? teacherId = AuthViewModel.instance.getLoggedInUser()?.username;

    UploadMarksResponseModel responseModel = UploadMarksResponseModel(
      session: widget.subject.sessionCode,
      classCode: widget.subject.classCode,
      section: widget.subject.sectionCode,
      examNameCode: widget.subject.examCode,
      subjectCode: widget.subject.subjectCode,
      examActivityCode: widget.subject.activityCode,
      subActivityCode: widget.subject.subActivityCode,
      maxMarks: widget.subject.maxMarks,
      createdBy: teacherId ?? "",
      mode: widget.screenState == UploadMarksScreenState.marksToBeUploaded
          ? "NOTSTARTED"
          : "STARTED",
      entryType: widget.subject.entryType,
      subjectName: widget.subject.subjectCode,
      className: widget.subject.className,
      examName: widget.subject.exam,
      activityName: widget.subject.activity,
      studentMarks: uploadMarksStudentMarks,
      studentIds: studentIdList,
    );

    UploadMarksViewModel.instance.uploadMarks(responseModel).then((response) {
      if (response.success) {
        popScreen(context);
        showSnackBarOnScreen(context, "Record saved");
      } else {
        showSnackBarOnScreen(context, "An error occurred");
      }
    });
  }

  List<TableRowConfiguration> rows(UploadSubjectMarks subject) => [
        TableRowConfiguration(
          rowHeight: 35,
          cells: [
            TableCellConfiguration(
                text: "Class", padding: const EdgeInsets.only(left: 10)),
            TableCellConfiguration(
                text: subject.className,
                padding: const EdgeInsets.only(left: 10)),
          ],
        ),
        TableRowConfiguration(
          rowHeight: 35,
          cells: [
            TableCellConfiguration(
                text: "Exam", padding: const EdgeInsets.only(left: 10)),
            TableCellConfiguration(
                text: subject.exam, padding: const EdgeInsets.only(left: 10)),
          ],
        ),
        TableRowConfiguration(
          rowHeight: 35,
          cells: [
            TableCellConfiguration(
                text: "Max Marks", padding: const EdgeInsets.only(left: 10)),
            TableCellConfiguration(
                text: isGradeType ? "-" : subject.maxMarks,
                padding: const EdgeInsets.only(left: 10)),
          ],
        ),
        TableRowConfiguration(
          rowHeight: 35,
          cells: [
            TableCellConfiguration(
                text: "Activity Name",
                padding: const EdgeInsets.only(left: 10)),
            TableCellConfiguration(
                text: subject.activity,
                padding: const EdgeInsets.only(left: 10)),
          ],
        ),
      ];
}
