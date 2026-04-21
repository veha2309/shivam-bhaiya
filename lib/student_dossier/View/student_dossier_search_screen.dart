import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/student_dossier/ViewModel/student_dossier_view_model.dart';
import 'package:school_app/student_dossier_detail/View/student_dossier_detail_screen.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

class StudentDossierSearchScreen extends StatefulWidget {
  static const String routeName = '/student-dossier-search';
  final String? title;
  const StudentDossierSearchScreen({super.key, this.title});

  @override
  State<StudentDossierSearchScreen> createState() =>
      _StudentDossierSearchScreenState();
}

final class _StudentDossierSearchScreenState
    extends State<StudentDossierSearchScreen> {
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<StudentDossier>>>? getStudentListFuture;
  TextEditingController studentNameController = TextEditingController();
  TextEditingController studentAdmissionController = TextEditingController();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  ValueNotifier<List<StudentDossier>> studentNotifier = ValueNotifier([]);

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

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>();
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: context.read<LanguageProvider>().translate(widget.title ?? "Student Dossier Search"),
        body: studentDossierSearchScreenBody(context),
      ),
    );
  }

  Widget studentDossierSearchScreenBody(BuildContext context) {
    return AppFutureBuilder(
        future: getClassListFuture,
        builder: (context, snapshot) {
          if (classes.isEmpty) {
            return const NoDataWidget();
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return getLoaderWidget();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 20,
                  fontFamily: fontFamily,
                ),
              ),
            );
          } else if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  spacing: 10,
                  children: [
                    AppTextfield(
                      controller: studentNameController,
                      enabled: true,
                      showIcon: false,
                      hintText: context.read<LanguageProvider>().translate("Student Name"),
                    ),
                    AppTextfield(
                      controller: studentAdmissionController,
                      enabled: true,
                      showIcon: false,
                      hintText: context.read<LanguageProvider>().translate("Student Admission No"),
                    ),
                    AppTextfield(
                      onTap: () {
                        openClassBottomSheet(context, classes, (classModel) {
                          setState(() {
                            selectedClass = classModel;
                            selectedSection = null;
                            getSectionListFuture = SchoolDetailsViewModel
                                .instance
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
                      hintText: selectedClass?.className ?? context.read<LanguageProvider>().translate('Select Class'),
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
                      hintText:
                          selectedSection?.sectionName ?? context.read<LanguageProvider>().translate('Select Section'),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: AppButton(
                        onPressed: (_) {
                          isLoadingNotifier.value = true;

                          if (selectedClass == null &&
                              selectedSection == null &&
                              studentNameController.text.trim().isEmpty &&
                              studentAdmissionController.text.trim().isEmpty) {
                            isLoadingNotifier.value = false;
                            showSnackBarOnScreen(context,
                                "Please select class and section, or search via name or admission number.");
                            return;
                          }

                          getStudentListFuture = StudentDossierSearchViewModel
                              .instance
                              .getDossierAcademicDetail(
                                  selectedClass?.classCode ?? "-",
                                  selectedSection?.sectionCode ?? "-",
                                  studentAdmissionController.text.trim().isEmpty
                                      ? "-"
                                      : studentAdmissionController.text,
                                  studentNameController.text.trim().isEmpty
                                      ? "-"
                                      : studentNameController.text)
                              .then(
                                  (ApiResponse<List<StudentDossier>> response) {
                            isLoadingNotifier.value = false;
                            if (response.success) {
                              setState(() {
                                studentNotifier.value = response.data!;
                              });
                            }
                            return response;
                          });
                        },
                        text: context.read<LanguageProvider>().translate("Search"),
                      ),
                    ),
                    ValueListenableBuilder(
                        valueListenable: studentNotifier,
                        builder: (context, value, _) {
                          return Column(
                            children: [
                              ...value.map((student) {
                                return Container(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: TableWidget(
                                    rows: [
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Id/Name",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            onTap: (_) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StudentDossierDetailScreen(
                                                          studentDossier:
                                                              student),
                                                ),
                                              );
                                            },
                                            text:
                                                "${student.studentId}/${student.studentName}",
                                            textStyle: const TextStyle(
                                                color:
                                                    ColorConstant.primaryColor,
                                                decoration:
                                                    TextDecoration.underline,
                                                decorationColor:
                                                    ColorConstant.primaryColor),
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Class/Section",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            text:
                                                "${student.className}/${student.sectionName}",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Father's Name",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            text: "Mr. ${student.fatherName}",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Mother's Name",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            text: "Mrs. ${student.motherName}",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Mobile/Email",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            onTap: (_) {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      StudentDossierDetailScreen(
                                                          studentDossier:
                                                              student),
                                                ),
                                              );
                                            },
                                            text:
                                                "${student.mobileNo}/${student.emailId}",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Status",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            text:
                                                "${student.status}/${selectedClass?.className}-${selectedSection?.sectionName}",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Fee Concession Type",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            text: student.feeConcession,
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                      TableRowConfiguration(
                                        rowHeight: 45,
                                        cells: [
                                          TableCellConfiguration(
                                            text: "Transport",
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          ),
                                          TableCellConfiguration(
                                            text: student.transport,
                                            padding:
                                                const EdgeInsets.only(left: 10),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        }),
                  ],
                ),
              ),
            );
          } else {
            return getLoaderWidget();
          }
        });
  }
}
