import 'package:flutter/material.dart';
import 'package:school_app/discipline/model/student_discipline_model.dart';
import 'package:school_app/discipline/view/raise_discipline_entry_screen.dart';
import 'package:school_app/discipline/viewmodel/discipline_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
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

class RaiseDisciplineSearchScreen extends StatefulWidget {
  static const String routeName = '/raise-discipline-search';
  final String? title;
  const RaiseDisciplineSearchScreen({super.key, this.title});

  @override
  State<RaiseDisciplineSearchScreen> createState() =>
      _RaiseDisciplineSearchScreenState();
}

class _RaiseDisciplineSearchScreenState
    extends State<RaiseDisciplineSearchScreen> {
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  ValueNotifier<bool> showCheckBox = ValueNotifier(false);
  List<StudentDisciplineModel> studentDisciplineList = [];
  bool checkBoxSelected = false;
  Set<String> selectedStudent = {};

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
    super.dispose();
  }

  ClassModel? selectedClass;
  Section? selectedSection;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  void checkIfAllFieldsAreFilled() {
    if (selectedClass != null && selectedSection != null) {
      showCheckBox.value = true;
    } else {
      showCheckBox.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Raise Discipline",
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
                          checkIfAllFieldsAreFilled();
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
                          checkIfAllFieldsAreFilled();
                        });
                      });
                    },
                    enabled: false,
                    hintText: selectedSection?.sectionName ?? 'Select Section',
                  ),
                  ValueListenableBuilder<bool>(
                    valueListenable: showCheckBox,
                    builder: (context, value, child) {
                      if (value) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: checkBoxSelected,
                              checkColor: ColorConstant.onPrimary,
                              activeColor: ColorConstant.primaryColor,
                              side: const BorderSide(
                                  color: ColorConstant.inactiveColor),
                              onChanged: (value) {
                                setState(() {
                                  checkBoxSelected = value!;
                                });
                              },
                            ),
                            const Text(
                              'There is no defaulter today',
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: fontFamily,
                                color: ColorConstant.inactiveColor,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  selectedStudent.isNotEmpty
                      ? const SizedBox()
                      : AppButton(
                          onPressed: (isLoading) async {
                            if (checkBoxSelected) {
                              if (selectedSection == null &&
                                  selectedClass == null) {
                                showSnackBarOnScreen(context,
                                    "Please select class and section to search.");
                                return;
                              }

                              if (selectedSection == null) {
                                showSnackBarOnScreen(context,
                                    "Please select section to search.");
                                return;
                              }

                              isLoading.value = true;
                              var response = await DisciplineViewModel.instance
                                  .markNoDefaults(selectedSection!.sectionCode,
                                      DateTime.now());
                              isLoading.value = false;
                              if (response.success) {
                                Navigator.pop(context);
                                showSnackBarOnScreen(context,
                                    "No defaulter marked successfully");
                              } else {
                                showSnackBarOnScreen(
                                    context, "An error occurred");
                              }
                            } else {
                              if (selectedClass == null ||
                                  selectedSection == null) {
                                showSnackBarOnScreen(
                                    context, "Please fill all the fields");
                                return;
                              }
                              DisciplineViewModel.instance
                                  .searchStudentDisplineList(
                                      selectedSection?.sectionCode ?? "",
                                      DateTime.now())
                                  .then((response) {
                                if (response.success) {
                                  setState(() {
                                    studentDisciplineList =
                                        response.data?.studentData ?? [];
                                  });
                                }
                                return response;
                              });
                            }
                          },
                          text: checkBoxSelected ? "Submit" : "Search",
                        ),
                  ValueListenableBuilder(
                    valueListenable: showCheckBox,
                    builder: (context, value, _) {
                      if (studentDisciplineList.isNotEmpty &&
                          !checkBoxSelected) {
                        return SizedBox(
                          width: double.infinity,
                          child: DataTableWidget(
                            headers: [
                              TableColumnConfiguration(text: "S.No", width: 30),
                              TableColumnConfiguration(
                                  text: "Name", width: 160),
                            ],
                            data: studentDisciplineList
                                .asMap()
                                .entries
                                .map((entry) {
                              int key = entry.key + 1;
                              StudentDisciplineModel value = entry.value;
                              return TableRowConfiguration(
                                  rowHeight: 45,
                                  backgroundColor:
                                      selectedStudent.contains(value.studentId)
                                          ? ColorConstant.primaryColor
                                              .withOpacity(0.2)
                                          : null,
                                  onLongRowLongPress: () {
                                    setState(() {
                                      if (selectedStudent
                                          .contains(value.studentId)) {
                                        selectedStudent
                                            .remove(value.studentId ?? "");
                                      } else {
                                        selectedStudent
                                            .add(value.studentId ?? "");
                                      }
                                    });
                                  },
                                  onTap: (_) {
                                    if (selectedStudent.isNotEmpty) {
                                      setState(() {
                                        if (selectedStudent
                                            .contains(value.studentId)) {
                                          selectedStudent
                                              .remove(value.studentId ?? "");
                                        } else {
                                          selectedStudent
                                              .add(value.studentId ?? "");
                                        }
                                      });
                                    } else {
                                      navigateToScreen(
                                        context,
                                        RaiseDisciplineEntryScreen(
                                          students: [value],
                                          isForEntry: true,
                                          classModel: selectedClass!,
                                          section: selectedSection!,
                                          disciplineDate: DateTime.now(),
                                        ),
                                      );
                                    }
                                  },
                                  cells: [
                                    TableCellConfiguration(
                                      text: "$key",
                                      width: 30,
                                    ),
                                    TableCellConfiguration(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              "${value.studentName}",
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontFamily: fontFamily,
                                                color:
                                                    ColorConstant.primaryColor,
                                                decoration:
                                                    TextDecoration.underline,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]);
                            }).toList(),
                          ),
                        );
                      } else {
                        return const SizedBox();
                      }
                    },
                  ),
                  if (selectedStudent.isNotEmpty)
                    Row(
                      children: [
                        Expanded(
                            child: AppButton(
                          onPressed: (_) {
                            setState(() {
                              selectedStudent.clear();
                            });
                          },
                          text: "Cancel",
                        )),
                        const SizedBox(width: 16),
                        Expanded(
                            child: AppButton(
                                onPressed: (_) {
                                  navigateToScreen(
                                    context,
                                    RaiseDisciplineEntryScreen(
                                      students: studentDisciplineList
                                          .where((element) => selectedStudent
                                              .contains(element.studentId))
                                          .toList(),
                                      isForEntry: true,
                                      classModel: selectedClass!,
                                      section: selectedSection!,
                                      disciplineDate: DateTime.now(),
                                    ),
                                  );
                                },
                                text: "Next")),
                      ],
                    )
                ],
              ),
            ),
          );
        });
  }
}
