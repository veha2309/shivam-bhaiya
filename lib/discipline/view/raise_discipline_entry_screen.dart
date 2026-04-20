import 'package:flutter/material.dart';
import '../../../utils/utils.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/discipline/model/discipline_data.dart';
import 'package:school_app/discipline/model/save_discipline_model.dart';
import 'package:school_app/discipline/model/student_discipline_model.dart';
import 'package:school_app/discipline/viewmodel/discipline_view_model.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class RaiseDisciplineEntryScreen extends StatefulWidget {
  static const String routeName = '/raise-discipline-entry';
  final String? title;
  final bool isForEntry;
  final ClassModel classModel;
  final Section section;
  final List<StudentDisciplineModel> students;
  final DateTime disciplineDate;

  const RaiseDisciplineEntryScreen({
    super.key,
    this.title,
    this.isForEntry = false,
    required this.students,
    required this.classModel,
    required this.section,
    required this.disciplineDate,
  });

  @override
  State<RaiseDisciplineEntryScreen> createState() =>
      _RaiseDisciplineEntryScreenState();
}

class _RaiseDisciplineEntryScreenState
    extends State<RaiseDisciplineEntryScreen> {
  Future<ApiResponse<DisciplineData>>? getStudentDisciplineDataForEntry;
  DisciplineData? disciplineData;
  int totalStudents = 0;
  List<StudentDisciplineModel> students = [];

  @override
  void initState() {
    super.initState();
    callGetStudentDisciplineDataForEntry();
  }

  void callGetStudentDisciplineDataForEntry() {
    if (widget.students.isEmpty) {
      return;
    }
    getStudentDisciplineDataForEntry = DisciplineViewModel.instance
        .getStudentDisciplineDataForView(
            widget.students.first.studentId ?? "", widget.disciplineDate)
        .then((response) {
      if (response.success) {
        disciplineData = response.data;
        totalStudents = widget.students.length;
        int index = 1;
        students = widget.students.map((student) {
          student.sNo = index++;
          student.disciplineData = disciplineData?.copy();
          return student;
        }).toList();
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          popScreen(context);
        }
      },
      child: AppScaffold(
        body: AppBody(
          title: widget.title ?? "Discipline Violation Entry",
          body: AppFutureBuilder(
              future: getStudentDisciplineDataForEntry,
              builder: (context, snapshot) {
                return getStudentDisciplineBody(context);
              }),
        ),
      ),
    );
  }

  Widget getStudentDisciplineBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          spacing: 16.0,
          children: [
            AppTextfield(
              hintText: "Class: ${widget.classModel.className}",
              enabled: false,
              showIcon: false,
            ),
            AppTextfield(
              hintText: "Section: ${widget.section.sectionName}",
              enabled: false,
              showIcon: false,
            ),
            AbsorbPointer(
              absorbing: !widget.isForEntry,
              child: Column(children: [
                ...students.map((student) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${student.sNo} / $totalStudents",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textScaler: const TextScaler.linear(1.0),
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: fontFamily,
                              color: ColorConstant.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        TableWidget(rows: [
                          TableRowConfiguration(
                            rowHeight: 50,
                            cells: [
                              TableCellConfiguration(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 4.0,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    spacing: 2.0,
                                    children: [
                                      const Text(
                                        "Student Name",
                                        textScaler: TextScaler.linear(1.0),
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: fontFamily,
                                          fontWeight: FontWeight.w700,
                                          color: ColorConstant.primaryColor,
                                        ),
                                      ),
                                      Text(
                                        "${student.studentName}",
                                        textScaler:
                                            const TextScaler.linear(1.0),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontFamily: fontFamily,
                                          color: ColorConstant.inactiveColor,
                                        ),
                                      )
                                    ],
                                  )),
                            ],
                          ),
                          ...(student.disciplineData?.superCategories
                                  ?.map((element) {
                                return TableRowConfiguration(
                                  cells: [
                                    TableCellConfiguration(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                          vertical: 4.0,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          spacing: 16.0,
                                          children: [
                                            Text(
                                              element.superCategory ?? "",
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: fontFamily,
                                                fontWeight: FontWeight.w700,
                                                color:
                                                    ColorConstant.primaryColor,
                                              ),
                                            ),
                                            Column(
                                              spacing: 2.0,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                ...(element.categories
                                                        ?.map((subcat) {
                                                      return Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            subcat.category ??
                                                                "",
                                                            textScaler:
                                                                const TextScaler
                                                                    .linear(
                                                                    1.0),
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 14,
                                                              fontFamily:
                                                                  fontFamily,
                                                              color: ColorConstant
                                                                  .inactiveColor,
                                                            ),
                                                          ),
                                                          Checkbox(
                                                            value: subcat
                                                                .isSelected,
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            semanticLabel:
                                                                subcat.category,
                                                            side:
                                                                const BorderSide(
                                                              color: ColorConstant
                                                                  .inactiveColor,
                                                              width: 1,
                                                            ),
                                                            onChanged: (value) {
                                                              setState(() {
                                                                subcat.isSelected =
                                                                    value ??
                                                                        false;
                                                              });
                                                            },
                                                            activeColor:
                                                                ColorConstant
                                                                    .primaryColor,
                                                            checkColor:
                                                                ColorConstant
                                                                    .onPrimary,
                                                            materialTapTargetSize:
                                                                MaterialTapTargetSize
                                                                    .shrinkWrap,
                                                          ),
                                                        ],
                                                      );
                                                    }).toList() ??
                                                    []),
                                              ],
                                            )
                                          ],
                                        )),
                                  ],
                                );
                              }).toList() ??
                              []),
                        ]),
                      ],
                    ),
                  );
                })
              ]),
            ),
            if (widget.isForEntry)
              AppButton(
                text: "Save",
                onPressed: (isLoading) async {
                  HomeModel? homeModel = AuthViewModel.instance.homeModel;
                  List<SaveDisciplineModel> saveDisciplineData = [];

                  final formattedDate =
                      "${widget.disciplineDate.day.toString().padLeft(2, '0')}-${widget.disciplineDate.month.toString().padLeft(2, '0')}-${widget.disciplineDate.year}";
                  if (disciplineData == null) return;

                  for (var student in students) {
                    for (var element
                        in student.disciplineData?.superCategories ?? []) {
                      for (var subcat in element.categories) {
                        if (subcat.isSelected) {
                          saveDisciplineData.add(SaveDisciplineModel(
                            classCode: widget.classModel.classCode,
                            sectionCode: widget.section.sectionCode,
                            sessionCode: homeModel?.sessionCode ?? "",
                            createdBy: AuthViewModel.instance
                                    .getLoggedInUser()
                                    ?.username ??
                                "",
                            disciplineCode: subcat.categoryCode,
                            entryDate: formattedDate,
                            marks: subcat.marks.toString(),
                            remark: student
                                    .disciplineData?.remarksController.text ??
                                "",
                            remedial: student
                                    .disciplineData?.remedialController.text ??
                                "",
                            studentId: student.studentId ?? "",
                          ));
                        }
                      }
                    }
                  }
                  isLoading.value = true;
                  await DisciplineViewModel.instance
                      .saveDisciplineDate(saveDisciplineData)
                      .then((response) {
                    if (!mounted) return response;
                    if (response.success) {
                      isLoading.value = false;
                      popScreen(context);
                      showSnackBarOnScreen(
                          context, "Student Discipline Marked");
                    } else {
                      isLoading.value = false;
                      showSnackBarOnScreen(context,
                          "Something went wrong, please try again later");
                    }
                    return response;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}
