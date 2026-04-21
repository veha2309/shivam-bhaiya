import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/search_student_profile/ViewModel/search_student_profile_view_model.dart';
import 'package:school_app/student_profile/View/student_profile_screen.dart';
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

class SearchStudentProfileScreen extends StatefulWidget {
  static const String routeName = '/search-student-profile';
  final String? title;

  const SearchStudentProfileScreen({
    super.key,
    this.title,
  });

  @override
  State<SearchStudentProfileScreen> createState() =>
      _SearchStudentProfileScreenState();
}

class _SearchStudentProfileScreenState
    extends State<SearchStudentProfileScreen> {
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<SearchStudentModel>>>? getStudentListFuture;

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
  DateTime? selectedDate;

  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<SearchStudentModel> students = [];

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Student Profile",
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
                        !studentNameController.text.trim().isEmpty) {
                      isLoadingNotifier.value = false;
                      showSnackBarOnScreen(context,
                          "Please select section or search via name only.");
                      return;
                    }

                    if (selectedClass != null && selectedSection != null) {
                      getStudentListFuture = SearchStudentProfileViewModel
                          .instance
                          .searchStudentListForStudentProfile(
                              selectedClass!.classCode,
                              selectedSection!.sectionCode,
                              "-")
                          .then(
                              (ApiResponse<List<SearchStudentModel>> response) {
                        isLoadingNotifier.value = false;
                        if (response.success) {
                          setState(() {
                            students = response.data ?? [];
                          });
                        }
                        return response;
                      });
                    } else {
                      getStudentListFuture = SearchStudentProfileViewModel
                          .instance
                          .searchStudentListForStudentProfile(
                        "",
                        "",
                        studentNameController.text,
                      )
                          .then(
                              (ApiResponse<List<SearchStudentModel>> response) {
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
                    child: DataTableWidget(
                      headers: [
                        TableColumnConfiguration(text: "Class", width: 120),
                        TableColumnConfiguration(text: "Name", width: 130),
                        TableColumnConfiguration(text: "Action", width: 60),
                      ],
                      data: students.map((student) {
                        return TableRowConfiguration(
                          onTap: (_) {
                            navigateToScreen(
                              context,
                              StudentProfileScreen(
                                studentId: student.studentId ?? "",
                              ),
                            );
                          },
                          cells: [
                            TableCellConfiguration(
                                text: student.className, width: 120),
                            TableCellConfiguration(
                                text: student.studentName, width: 130),
                            TableCellConfiguration(
                                child: TextButton(
                                  onPressed: () {
                                    navigateToScreen(
                                      context,
                                      StudentProfileScreen(
                                        studentId: student.studentId ?? "",
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "View",
                                    textScaler: TextScaler.linear(1.0),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
