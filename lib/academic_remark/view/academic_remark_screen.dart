import 'package:flutter/material.dart';
import 'package:school_app/academic_card/view/academic_card_entry_screen.dart';
import 'package:school_app/academic_remark/view/academic_remark_entry_screen.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/search_student_profile/ViewModel/search_student_profile_view_model.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/utils.dart';

enum AcademicNavigationType { remark, card }

class AcademicRemarkSearchScreen extends StatefulWidget {
  static const String routeName = '/academic-remark';
  final String? title;
  final AcademicNavigationType navigationType;

  const AcademicRemarkSearchScreen({
    super.key,
    this.title,
    this.navigationType = AcademicNavigationType.remark,
  });

  @override
  State<AcademicRemarkSearchScreen> createState() =>
      _AcademicRemarkSearchScreenState();
}

class _AcademicRemarkSearchScreenState
    extends State<AcademicRemarkSearchScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final TextEditingController studentNameController = TextEditingController();
  ClassModel? selectedClass;
  Section? selectedSection;

  // Add set for selected students
  Set<String> selectedStudents = {};

  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<SearchStudentModel>>>? getStudentListFuture;

  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<SearchStudentModel> students = [];

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
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Academic Remarks",
        body: academicRemarkBody(context),
      ),
    );
  }

  Widget academicRemarkBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            AppTextfield(
              onTap: () => openClassBottomSheet(context, classes, (value) {
                isLoadingNotifier.value = true;
                studentNameController.clear();
                setState(() {
                  selectedClass = value;
                  selectedSection = null;
                  getSectionListFuture = SchoolDetailsViewModel.instance
                      .getSectionList(value.classCode)
                      .then((ApiResponse<List<Section>> response) {
                    isLoadingNotifier.value = false;
                    if (response.success) {
                      sections = response.data ?? [];
                    }
                    return response;
                  });
                });
              }),
              hintText: selectedClass?.className ?? 'Select Class',
            ),
            AppTextfield(
              onTap: () => openSectionBottomSheet(context, sections, (value) {
                studentNameController.clear();
                setState(() {
                  selectedSection = value;
                });
              }),
              hintText: selectedSection?.sectionName ?? 'Select Section',
            ),
            const Text(
              "OR",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 16,
                fontFamily: fontFamily,
                color: ColorConstant.inactiveColor,
              ),
            ),
            AppTextfield(
              controller: studentNameController,
              hintText: "Student Name",
              enabled: true,
            ),
            AppButton(
              onPressed: (_) {
                isLoadingNotifier.value = true;

                if (selectedClass == null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(context,
                      "Please select class, section, or search via name.");
                  return;
                }

                if (selectedClass != null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(
                      context, "Please select section to search.");
                  return;
                }

                if (selectedClass != null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isNotEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(context,
                      "Please select section or search via name only.");
                  return;
                }

                if (selectedClass == null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(context,
                      "Please select class, section, or search via name.");
                  return;
                }

                if (selectedClass != null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(
                      context, "Please select section to search.");
                  return;
                }

                if (selectedClass != null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isNotEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(context,
                      "Please select section or search via name only.");
                  return;
                }

                if (selectedClass != null && selectedSection != null) {
                  getStudentListFuture = SearchStudentProfileViewModel.instance
                      .searchStudentListForStudentProfile(
                          selectedClass!.classCode,
                          selectedSection!.sectionCode,
                          "-")
                      .then((ApiResponse<List<SearchStudentModel>> response) {
                    isLoadingNotifier.value = false;
                    if (response.success) {
                      setState(() {
                        students = response.data ?? [];
                      });
                    }
                    return response;
                  });
                } else {
                  getStudentListFuture = SearchStudentProfileViewModel.instance
                      .searchStudentListForStudentProfile(
                    "",
                    "",
                    studentNameController.text,
                  )
                      .then((ApiResponse<List<SearchStudentModel>> response) {
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
              text: "Search",
            ),
            if (students.isNotEmpty)
              DataTableWidget(
                headers: [
                  TableColumnConfiguration(text: "Class", width: 100),
                  TableColumnConfiguration(text: "Name", width: 150),
                ],
                data: students.map((student) {
                  return TableRowConfiguration(
                    rowHeight: 45,
                    backgroundColor:
                        selectedStudents.contains(student.studentId)
                            ? ColorConstant.primaryColor.withOpacity(0.2)
                            : null,
                    onLongRowLongPress: () {
                      if (studentNameController.text.isNotEmpty) {
                        return;
                      }
                      setState(() {
                        if (selectedStudents.contains(student.studentId)) {
                          selectedStudents.remove(student.studentId ?? "");
                        } else {
                          selectedStudents.add(student.studentId ?? "");
                        }
                      });
                    },
                    onTap: (_) {
                      if (selectedStudents.isNotEmpty) {
                        setState(() {
                          if (selectedStudents.contains(student.studentId)) {
                            selectedStudents.remove(student.studentId ?? "");
                          } else {
                            selectedStudents.add(student.studentId ?? "");
                          }
                        });
                      } else {
                        navigateToScreen(
                          context,
                          widget.navigationType == AcademicNavigationType.remark
                              ? AcademicRemarkEntryScreen(
                                  students: [student],
                                  classCode: selectedClass?.classCode,
                                  sectionCode: selectedSection?.sectionCode,
                                )
                              : AcademicCardEntryScreen(
                                  students: [student],
                                  classCode: selectedClass?.classCode ?? "",
                                  sectionCode:
                                      selectedSection?.sectionCode ?? "",
                                ),
                        );
                      }
                    },
                    cells: [
                      TableCellConfiguration(text: student.className),
                      TableCellConfiguration(text: student.studentName),
                    ],
                  );
                }).toList(),
                headingRowHeight: 35,
                headingTextStyle:
                    const TextStyle(fontWeight: FontWeight.w300, fontSize: 12),
                headingRowColor: ColorConstant.primaryColor,
                enableHorizontalScroll: true,
                minColumnWidth: 80,
              ),

            // Add buttons for selected students
            if (selectedStudents.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        onPressed: (_) {
                          setState(() {
                            selectedStudents.clear();
                          });
                        },
                        text: "Cancel",
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        onPressed: (_) {
                          navigateToScreen(
                            context,
                            widget.navigationType ==
                                    AcademicNavigationType.remark
                                ? AcademicRemarkEntryScreen(
                                    classCode: selectedClass?.classCode,
                                    sectionCode: selectedSection?.sectionCode,
                                    students: students
                                        .where((student) => selectedStudents
                                            .contains(student.studentId))
                                        .toList(),
                                  )
                                : AcademicCardEntryScreen(
                                    students: students
                                        .where((student) => selectedStudents
                                            .contains(student.studentId))
                                        .toList(),
                                    classCode: selectedClass?.classCode ?? "",
                                    sectionCode:
                                        selectedSection?.sectionCode ?? "",
                                  ),
                          );
                        },
                        text: "Next",
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void openClassBottomSheet(BuildContext context, List<ClassModel> classes,
      Function(ClassModel) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: classes.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(classes[index].className),
              onTap: () {
                onSelect(classes[index]);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  void openSectionBottomSheet(BuildContext context, List<Section> sections,
      Function(Section) onSelect) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(sections[index].sectionName),
              onTap: () {
                onSelect(sections[index]);
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    studentNameController.dispose();
    super.dispose();
  }
}
