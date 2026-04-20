import 'package:flutter/material.dart';
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
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/utils.dart';

class ViewDisciplineScreen extends StatefulWidget {
  static const String routeName = '/view-discipline';
  final String? title;
  const ViewDisciplineScreen({super.key, this.title});

  @override
  State<ViewDisciplineScreen> createState() => _ViewDisciplineScreenState();
}

class _ViewDisciplineScreenState extends State<ViewDisciplineScreen> {
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
        title: widget.title ?? 'View Discipline',
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
              SizedBox(
                width: double.infinity,
                child: DataTableWidget(
                  headers: [
                    TableColumnConfiguration(text: "Class", width: 80),
                    TableColumnConfiguration(text: "Name", width: 130),
                  ],
                  data: students.map((student) {
                    return TableRowConfiguration(
                      rowHeight: 45,
                      backgroundColor:
                          selectedStudents.contains(student.studentId)
                              ? ColorConstant.primaryColor
                              : null,
                      onTap: (_) {
                        navigateToScreen(
                          context,
                          AcademicRemarkEntryScreen(
                            students: [student],
                            classCode: selectedClass?.classCode,
                            sectionCode: selectedSection?.sectionCode,
                          ),
                        );
                      },
                      cells: [
                        TableCellConfiguration(text: student.className),
                        TableCellConfiguration(text: student.studentName),
                      ],
                    );
                  }).toList(),
                  headingRowHeight: 35,
                  headingTextStyle: const TextStyle(
                      fontWeight: FontWeight.w300, fontSize: 12),
                  headingRowColor: ColorConstant.primaryColor,
                ),
              ),
          ],
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
