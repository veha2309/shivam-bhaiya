import 'package:flutter/material.dart';
import 'package:school_app/concerns/model/student.dart';
import 'package:school_app/concerns/view_model/concerns_view_model.dart';
import 'package:school_app/concerns_detail/view/concerns_detail_view.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/utils.dart';

enum ConcernsViewScreenType {
  disciplineCard,
  discipline,
  academicDiscipline,
}

extension ConcernsViewScreenTypeNameExt on ConcernsViewScreenType {
  String getScreenTitle() {
    switch (this) {
      case ConcernsViewScreenType.disciplineCard:
        return "Academic Card View";
      case ConcernsViewScreenType.discipline:
        return "Discipline Violation View";
      case ConcernsViewScreenType.academicDiscipline:
        return "Academic Remarks View";
    }
  }
}

enum ConcernsViewScreenOperation {
  add,
  view,
}

class ConcernsView extends StatefulWidget {
  static const String routeName = '/concerns';
  final String? title;
  final ConcernsViewScreenType screenType;
  final ConcernsViewScreenOperation screenOperation;

  const ConcernsView({
    super.key,
    this.title,
    required this.screenType,
    required this.screenOperation,
  });

  @override
  State<ConcernsView> createState() => _ConcernsViewState();
}

class _ConcernsViewState extends State<ConcernsView> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final TextEditingController studentNameController = TextEditingController();
  final ConcernsViewModel _concernsViewModel = ConcernsViewModel();
  ClassModel? selectedClass;
  Section? selectedSection;

  // Add set for selected students
  Set<String> selectedStudents = {};

  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<Student>>>? getStudentListFuture;

  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<Student> students = [];

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
        title: widget.title ?? "Concerns View",
        body: concernsBody(context),
      ),
    );
  }

  Widget concernsBody(BuildContext context) {
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

                if (selectedClass != null && selectedSection != null) {
                  _searchStudents(selectedSection!.sectionCode, "");
                } else {
                  _searchStudents("", studentNameController.text);
                }
              },
              text: "Search",
            ),
            if (students.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: DataTableWidget(
                  headers: (widget.screenOperation ==
                          ConcernsViewScreenOperation.view)
                      ? [
                          TableColumnConfiguration(text: "Adm. No", width: 80),
                          TableColumnConfiguration(text: "Name", width: 130),
                          if (studentNameController.text.isNotEmpty)
                            TableColumnConfiguration(text: "Class", width: 80),
                          TableColumnConfiguration(
                              text: "Violation Cnt", width: 80),
                        ]
                      : [
                          TableColumnConfiguration(text: "Name", width: 130),
                          TableColumnConfiguration(text: "Class", width: 80),
                        ],
                  data: students.map((student) {
                    return TableRowConfiguration(
                      rowHeight: 45,
                      onTap: (_) {
                        navigateToScreen(
                          context,
                          ConcernsDetailView(
                            screenType: widget.screenType,
                            studentId: student.studentId ?? "",
                            studentName: student.studentName ?? "",
                          ),
                        );
                      },
                      cells: (widget.screenOperation ==
                              ConcernsViewScreenOperation.view)
                          ? [
                              TableCellConfiguration(
                                  text: student.admissionNo, width: 80),
                              TableCellConfiguration(
                                text: student.studentName,
                                width: 130,
                              ),
                              if (studentNameController.text.isNotEmpty)
                                TableCellConfiguration(
                                    text: student.className, width: 80),
                              TableCellConfiguration(
                                  text: student.cnt, width: 80),
                            ]
                          : [
                              TableCellConfiguration(
                                  text: student.studentName, width: 130),
                              TableCellConfiguration(
                                  text: student.className, width: 80),
                            ],
                    );
                  }).toList(),
                  headingRowHeight: 35,
                  headingTextStyle: const TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                  headingRowColor: ColorConstant.primaryColor,
                ),
              ),
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
                          _handleStudentSelection(
                            students
                                .where((student) => selectedStudents
                                    .contains(student.studentId))
                                .toList(),
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

  void _searchStudents(String sectionCode, String studentName) async {
    Future<ApiResponse<List<Student>>> future;
    switch (widget.screenType) {
      case ConcernsViewScreenType.disciplineCard:
        future = _concernsViewModel.getStudentDisciplineCardSearchedList(
            sectionCode, studentName);
        break;
      case ConcernsViewScreenType.discipline:
        future = _concernsViewModel.getStudentDisciplineSearchedList(
            sectionCode, studentName);
        break;
      case ConcernsViewScreenType.academicDiscipline:
        future = _concernsViewModel.getStudentAcademicDisciplineSearchedList(
            sectionCode, studentName);
        break;
    }

    getStudentListFuture = future.then((ApiResponse<List<Student>> response) {
      isLoadingNotifier.value = false;
      if (response.success) {
        setState(() {
          students = response.data ?? [];
        });
      }
      return response;
    });
  }

  void _handleStudentSelection(List<Student> selectedStudents) {
    // TODO: Implement navigation to the appropriate screen based on screenType and screenOperation
    // This will be implemented when the destination screens are available
  }

  void openClassBottomSheet(BuildContext context, List<ClassModel> items,
      Function(ClassModel) onSelect) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Select Class",
                textAlign: TextAlign.left,
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      items[index].className,
                      textScaler: const TextScaler.linear(1.0),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    onTap: () {
                      onSelect(items[index]);
                      popScreen(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void openSectionBottomSheet(
      BuildContext context, List<Section> items, Function(Section) onSelect) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Select Section",
                textAlign: TextAlign.left,
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      items[index].sectionName,
                      textScaler: const TextScaler.linear(1.0),
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    onTap: () {
                      onSelect(items[index]);
                      popScreen(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    studentNameController.dispose();
    super.dispose();
  }
}
