import 'package:flutter/material.dart';
import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_student_model.dart';
import 'package:school_app/attendance_reconciliation/view/attandance_reconcilliation_data_screen.dart';
import 'package:school_app/attendance_reconciliation/view_model/attendance_recon_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/model/session.dart';
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

enum UpdationType { classWise, studentWise }

class AttandanceReconcilliationSearchScreen extends StatefulWidget {
  static const String routeName = '/attendance-reconciliation-search';

  const AttandanceReconcilliationSearchScreen({super.key});

  @override
  State<AttandanceReconcilliationSearchScreen> createState() =>
      _AttandanceReconcilliationSearchScreenState();
}

class _AttandanceReconcilliationSearchScreenState
    extends State<AttandanceReconcilliationSearchScreen> {
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<AttandanceReconcilliationStudentModel>>>?
      getStudentListFuture;
  Future<ApiResponse<List<Session>>>? getSessionListFuture;

  TextEditingController studentNameController = TextEditingController();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  UpdationType selectedUpdationType = UpdationType.classWise;

  @override
  void initState() {
    super.initState();
    getSessionListFuture = SchoolDetailsViewModel.instance
        .getSessionList()
        .then((ApiResponse<List<Session>> response) {
      if (response.success) {
        sessions = response.data ?? [];
        selectedSession = sessions.first;
      }
      return response;
    });

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

  Session? selectedSession;
  ClassModel? selectedClass;
  Section? selectedSection;
  String? selectedMonth;

  List<Session> sessions = [];
  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<AttandanceReconcilliationStudentModel> students = [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "Reconcile Attendance",
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
                      openMonthBottomSheet(context, monthsMMM, (month) {
                        setState(() {
                          selectedMonth = month;
                        });
                      });
                    },
                    enabled: false,
                    hintText: selectedMonth ?? 'Select Month',
                  ),
                  AppButton(
                    onPressed: (_) {
                      isLoadingNotifier.value = true;

                      if (selectedClass == null ||
                          selectedSection == null ||
                          selectedMonth == null) {
                        isLoadingNotifier.value = false;
                        showSnackBarOnScreen(context,
                            "Please select class, section, and month.");
                        return;
                      }

                      if (selectedClass != null && selectedSection != null) {
                        getStudentListFuture = AttendanceReconViewmodel.instance
                            .fetchAttendanceData(
                          selectedSession!.sessionCode,
                          selectedClass!.classCode,
                          selectedSection!.sectionCode,
                          selectedMonth!,
                        )
                            .then((ApiResponse<
                                    List<AttandanceReconcilliationStudentModel>>
                                response) {
                          isLoadingNotifier.value = false;
                          if (response.success) {
                            setState(() {
                              students = response.data ?? [];
                            });
                          }
                          return response;
                        });
                      }
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
                              text: "Working\nDays", width: 50),
                          TableColumnConfiguration(text: "Marked", width: 50),
                          TableColumnConfiguration(
                              text: "Not\nMarked", width: 50),
                        ],
                        data: students.asMap().entries.map((entry) {
                          final student = entry.value;
                          return TableRowConfiguration(
                            rowHeight: 50,
                            onTap: (_) {},
                            cells: [
                              TableCellConfiguration(
                                  text: student.rollNo, width: 40),
                              TableCellConfiguration(
                                  onTap: (p0) async {
                                    await navigateToScreen(
                                        context,
                                        AttandanceReconcilliationDataScreen(
                                          student: student,
                                          month: selectedMonth ?? "--",
                                        ));

                                    isLoadingNotifier.value = true;
                                    getStudentListFuture = AttendanceReconViewmodel
                                        .instance
                                        .fetchAttendanceData(
                                      selectedSession!.sessionCode,
                                      selectedClass!.classCode,
                                      selectedSection!.sectionCode,
                                      selectedMonth!,
                                    )
                                        .then((ApiResponse<
                                                List<
                                                    AttandanceReconcilliationStudentModel>>
                                            response) {
                                      isLoadingNotifier.value = false;
                                      if (response.success) {
                                        setState(() {
                                          students = response.data ?? [];
                                        });
                                      }
                                      return response;
                                    });
                                  },
                                  textStyle: const TextStyle(
                                    color: ColorConstant.primaryColor,
                                    decoration: TextDecoration.underline,
                                    fontFamily: fontFamily,
                                    fontSize: 12,
                                  ),
                                  text: student.name,
                                  width: 120),
                              TableCellConfiguration(
                                  text: student.workingDays.toString(),
                                  width: 60),
                              TableCellConfiguration(
                                  text: student.present.toString(), width: 60),
                              TableCellConfiguration(
                                  text: ((student.workingDays ?? 0) -
                                          (student.present ?? 0))
                                      .toString(),
                                  width: 60),
                            ],
                          );
                        }).toList(),
                        headingRowHeight: 35,
                        headingTextStyle: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 12),
                        headingRowColor: ColorConstant.primaryColor,
                      ),
                    ),
                  if (students.isNotEmpty)
                    AppButton(
                      onPressed: (_) async {
                        ApiResponse response = await AttendanceReconViewmodel
                            .instance
                            .saveMonthlyAttendanceRecord(students);

                        Navigator.of(context).pop();
                        String message;
                        if (response.success) {
                          message = "Monthly attendance reconcile successful";
                        } else {
                          message = "Something went wrong";
                        }

                        showSnackBarOnScreen(context, message);
                      },
                      text: "SAVE & SUBMIT",
                    ),
                ],
              ),
            ),
          );
        });
  }
}
