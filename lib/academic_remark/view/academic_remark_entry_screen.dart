import 'package:flutter/material.dart';
import 'package:school_app/academic_concerns/model/academic_concern_category_model.dart';
import 'package:school_app/academic_remark/model/academic_remark_save_model.dart';
import 'package:school_app/academic_remark/view_model/academic_remark_view_model.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/homework_screen/model/subject_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class AcademicRemarkEntryScreen extends StatefulWidget {
  static const String routeName = '/academic-remark-entry';
  final List<SearchStudentModel> students;
  final String? classCode;
  final String? sectionCode;

  const AcademicRemarkEntryScreen({
    super.key,
    required this.students,
    this.classCode,
    this.sectionCode,
  });

  @override
  State<AcademicRemarkEntryScreen> createState() =>
      _AcademicRemarkEntryScreenState();
}

class _AcademicRemarkEntryScreenState extends State<AcademicRemarkEntryScreen> {
  Future<ApiResponse<List<SubjectModel>>>? getSubjectListFuture;
  List<SubjectModel> subjects = [];
  SubjectModel? selectedSubject;

  Future<ApiResponse<List<AcademicConcernCategoryModel>>>?
      getAcademicConcernDetailsFuture;
  List<AcademicConcernCategoryModel> categories = [];

  int totalStudents = 0;
  List<SearchStudentModel> students = [];

  @override
  void initState() {
    super.initState();
    callGetSubjectListFuture();
  }

  void callGetAcademicConcernDetailsFuture() {
    if (selectedSubject == null) return;

    getAcademicConcernDetailsFuture = AcademicRemarkViewModel.instance
        .getDisciplineDtlsForEntry(widget.students.first.studentId ?? "")
        .then((ApiResponse<List<AcademicConcernCategoryModel>> response) {
      if (response.success) {
        setState(() {
          categories = response.data ?? [];
          totalStudents = widget.students.length;
          int index = 1;
          students = widget.students.map((student) {
            student.sNo = index++;
            student.categories = categories.map((e) => e.copy()).toList();
            student.remarkController = TextEditingController();
            return student;
          }).toList();
        });
      }
      return response;
    });
  }

  void callGetSubjectListFuture() {
    User? user = AuthViewModel.instance.getLoggedInUser();
    getSubjectListFuture = AcademicRemarkViewModel.instance
        .getSubjectComboByStudentId(
            widget.students.first.sectionCode ?? "", user?.username ?? "")
        .then((ApiResponse<List<SubjectModel>> response) {
      if (response.success) {
        setState(() {
          subjects = response.data ?? [];
        });
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: "Academic Remarks Entry",
        body: AppFutureBuilder(
            future: getSubjectListFuture,
            builder: (context, snapshot) {
              return getAcademicRemarkEntryBody();
            }),
      ),
    );
  }

  Widget getAcademicRemarkEntryBody() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          spacing: 16.0,
          children: [
            AppTextfield(
              onTap: () {
                openSubjectModelBottomSheet(context, subjects, (value) {
                  setState(() {
                    selectedSubject = value;
                    callGetAcademicConcernDetailsFuture();
                  });
                });
              },
              hintText: selectedSubject?.subjectName ?? 'Select Subject',
            ),
            if (students.isNotEmpty) ...[
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
                          cells: [
                            TableCellConfiguration(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                  vertical: 4.0,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8.0,
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
                                      student.studentName,
                                      textScaler: const TextScaler.linear(1.0),
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
                        ...(student.categories?.map((category) {
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
                                        spacing: 8.0,
                                        children: [
                                          Text(
                                            category.categoryName ?? "--",
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontFamily: fontFamily,
                                              fontWeight: FontWeight.w700,
                                              color: ColorConstant.primaryColor,
                                            ),
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            spacing: 8.0,
                                            children: [
                                              ...(category.subCategoryDetail
                                                      ?.map((subcat) {
                                                    return Row(
                                                      children: [
                                                        Text(
                                                          subcat.subCategoryName ??
                                                              "--",
                                                          textScaler:
                                                              const TextScaler
                                                                  .linear(1.0),
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 14,
                                                            fontFamily:
                                                                fontFamily,
                                                            color: ColorConstant
                                                                .inactiveColor,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Checkbox(
                                                          value:
                                                              subcat.isSelected,
                                                          visualDensity:
                                                              VisualDensity
                                                                  .compact,
                                                          semanticLabel: subcat
                                                              .subCategoryCode,
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
              }),
              AppButton(
                text: "Save",
                onPressed: (_) async {
                  List<AcademicRemarkSaveModel> saveModels = [];
                  for (var student in students) {
                    String categoryCode = "";

                    for (AcademicConcernCategoryModel category
                        in student.categories ?? []) {
                      for (AcademicConcernSubCategoryModel sub
                          in category.subCategoryDetail ?? []) {
                        if (sub.isSelected) {
                          categoryCode += "${sub.subCategoryCode}~";
                        }
                      }
                    }

                    categoryCode =
                        categoryCode.substring(0, categoryCode.length - 1);

                    String sessionCode =
                        AuthViewModel.instance.homeModel?.sessionCode ?? "";

                    AcademicRemarkSaveModel saveModel = AcademicRemarkSaveModel(
                      studentId: student.studentId,
                      categoryCode: categoryCode,
                      sessionCode: sessionCode,
                      classCode: student.classCode ?? widget.classCode,
                      sectionCode: student.sectionCode ?? widget.sectionCode,
                      subjectCode: selectedSubject?.subjectCode,
                      disciplineDate: getDDMMYYYYInNum(
                        DateTime.now(),
                      ),
                    );

                    saveModels.add(saveModel);
                  }

                  ApiResponse response = await AcademicRemarkViewModel.instance
                      .saveAcademicRemark(saveModels);

                  if (response.success) {
                    Navigator.of(context).pop();

                    showSnackBarOnScreen(
                        context, "Academic Discipline raised successfully");
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
