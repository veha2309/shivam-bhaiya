import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/result_analysis/model/query_payload.dart';
import 'package:school_app/result_analysis/model/result_analysis_drop_down_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_field_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_template_model.dart';
import 'package:school_app/result_analysis/view_model/result_analysis_view_model.dart';

import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/utils.dart';

class ResultAnalysisScreen extends StatefulWidget {
  static const String routeName = '/result-analysis';
  final List<ResultAnalysisTemplateModel> resultAnalysisTemplateModel;

  const ResultAnalysisScreen(
      {super.key, required this.resultAnalysisTemplateModel});

  @override
  State<ResultAnalysisScreen> createState() => _ResultAnalysisScreenState();
}

class _ResultAnalysisScreenState extends State<ResultAnalysisScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  String teacherCode = "";

  Future<ApiResponse<List<ResultAnalysisFieldModel>>>?
      getResultAnalysisFieldModelFuture;
  List<ResultAnalysisDropDownModel> sessions = [];
  List<ResultAnalysisDropDownModel> classes = [];
  List<ResultAnalysisDropDownModel> sections = [];
  List<ResultAnalysisDropDownModel> subjects = [];
  List<ResultAnalysisDropDownModel> exams = [];

  ResultAnalysisDropDownModel? selectedSession;
  ResultAnalysisDropDownModel? selectedClass;
  ResultAnalysisDropDownModel? selectedSection;
  ResultAnalysisDropDownModel? selectedSubject;
  ResultAnalysisDropDownModel? selectedExam;
  TextEditingController fromMarks = TextEditingController();
  TextEditingController toMarks = TextEditingController();
  bool isFromMarksVisible = false;

  @override
  void initState() {
    super.initState();
    resultAnalysisTemplateModel = widget.resultAnalysisTemplateModel;
    teacherCode = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
  }

  ResultAnalysisTemplateModel? selectedTemplate;
  List<ResultAnalysisTemplateModel> resultAnalysisTemplateModel = [];
  List<ResultAnalysisFieldModel> resultAnalysisFieldModel = [];

  void setSelectedTemplate(ResultAnalysisTemplateModel model) {
    setState(() {
      selectedTemplate = model;
    });

    getResultAnalysisFieldModelFuture = ResultAnalysisViewModel.instance
        .getResultAnalysisFieldModel(selectedTemplate?.jasperName ?? "")
        .then((response) {
      if (response.success) {
        setState(() {
          resultAnalysisFieldModel = response.data ?? [];
          resultAnalysisFieldModel.sort((a, b) {
            List<String> order = [
              "sessionCode",
              "classCode",
              "sectionCode",
              "subjectCode",
              "activityCode",
              "fromDate",
              "toDate"
            ];
            return order
                .indexOf(a.parameterName ?? "")
                .compareTo(order.indexOf(b.parameterName ?? ""));
          });
        });

        String? queryPart;
        String? fieldName;

        (queryPart, fieldName) =
            getQueryPartAndFieldIdUsingParamName("teacherCode");

        ResultAnalysisViewModel.instance
            .getDynamicDropDownValue(generateQueryJsonForSession(
          teacherCode,
          queryPart: queryPart,
          fieldIds: fieldName,
        ))
            .then((response) {
          if (response.success) {
            setState(() {
              sessions = response.data ?? [];
            });
          }
          return response;
        });
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "Result Analysis",
        body: getResultAnalysisScreenBody(context),
      ),
    );
  }

  Widget getResultAnalysisScreenBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            AppTextfield(
              onTap: () => openResultAnalysisTemplateBottomSheet(
                context,
                resultAnalysisTemplateModel,
                (model) => setSelectedTemplate(model),
              ),
              hintText: selectedTemplate?.reportName ?? 'Select Template',
            ),
            const SizedBox(height: 16),
            if (resultAnalysisFieldModel.isNotEmpty) getOptions(),
            const SizedBox(height: 16),
            AppButton(
              onPressed: (_) {
                if (isFromMarksVisible) {
                  if (fromMarks.text.isEmpty || toMarks.text.isEmpty) {
                    showSnackBarOnScreen(
                        context, "Please enter from and to marks");
                    return;
                  }

                  int? fromMarksDouble = int.tryParse(fromMarks.text);

                  int? toMarksDouble = int.tryParse(toMarks.text);

                  if (fromMarksDouble != null &&
                      toMarksDouble != null &&
                      toMarksDouble < fromMarksDouble) {
                    showSnackBarOnScreen(
                        context, "To marks should be greater than from marks");
                    return;
                  }

                  if (toMarksDouble != null && toMarksDouble > 100) {
                    showSnackBarOnScreen(
                        context, "To marks should be less than 100");
                    return;
                  }
                }
                ResultAnalysisViewModel.instance.searchResultAnalysisReport(
                  jasperUrl: selectedTemplate?.jasperName ?? "",
                  teacherCode: teacherCode,
                  sessionCode: selectedSession?.value ?? "",
                  classCode: selectedClass?.value ?? "",
                  sectionCode: selectedSection?.value ?? "",
                  subjectCode: selectedSubject?.value ?? "",
                  activityCode: selectedExam?.value ?? "",
                  fromDate: fromMarks.text,
                  toDate: toMarks.text,
                  reportOpenMode: 1,
                );
              },
              text: "Open",
            ),
          ],
        ),
      ),
    );
  }

  Widget getOptions() {
    List<Widget> dropDownOptions = [];
    for (ResultAnalysisFieldModel model in resultAnalysisFieldModel) {
      if ((int.tryParse(model.parameterValue ?? "") ?? 0) == 1) {
        dropDownOptions.add(
          getDropDownValue(model.parameterName ?? ""),
        );
      }
    }
    return Column(
      spacing: 16,
      children: dropDownOptions,
    );
  }

  Map<String, dynamic> generateQueryJsonForSession(String teacherCode,
      {String? queryPart, String? fieldIds}) {
    QueryPayload payload = QueryPayload(
      fieldIds: fieldIds ?? "teacherCode",
      queryPart: queryPart ??
          "SELECT DISTINCT SESSIONCODE AS VALUE, GETSESSIONNAME(SESSIONCODE) AS LABEL FROM TEACHERSECTIONSUBJECTMAPPING WHERE TEACHERCODE = ? ORDER BY LABEL DESC",
      parameters: {
        "teacherCode": teacherCode,
      },
    );
    return payload.toJson();
  }

  Map<String, dynamic> generateQueryJsonForClass(
      String sessionCode, String teacherCode,
      {String? queryPart, String? fieldIds}) {
    QueryPayload payload = QueryPayload(
      fieldIds: fieldIds ?? "sessionCode,teacherCode",
      queryPart: queryPart ??
          "SELECT distinct classcode as value, getclassname(classcode) as label, (select display_order from ses_classmaster ac where ac.classcode=tc.classcode) FROM teachersectionsubjectmapping  tc WHERE sessioncode=? AND teachercode=?  order by display_order",
      parameters: {
        "sessionCode": sessionCode,
        "teacherCode": teacherCode,
      },
    );
    return payload.toJson();
  }

  Map<String, dynamic> generateQueryJsonForSection(
      String teacherCode, String sessionCode, String classCode,
      {String? queryPart, String? fieldIds}) {
    QueryPayload payload = QueryPayload(
      fieldIds: fieldIds ?? "teacherCode, sessionCode, classCode",
      queryPart: queryPart ??
          "SELECT distinct sectioncode as value, getsectionname(sectioncode) as label FROM teachersectionsubjectmapping WHERE teachercode =? and sessioncode =? AND classcode =? order by label",
      parameters: {
        "teacherCode": teacherCode,
        "sessionCode": sessionCode,
        "classCode": classCode,
      },
    );
    return payload.toJson();
  }

  Map<String, dynamic> generateQueryJsonForSubject(String teacherCode,
      String sessionCode, String classCode, String sectionCode,
      {String? queryPart, String? fieldIds}) {
    QueryPayload payload = QueryPayload(
      fieldIds: fieldIds ??
          "teacherCode, sessionCode, classCode${sectionCode.isEmpty ? "" : ", sectionCode"}",
      queryPart: queryPart ??
          "SELECT distinct subjectcode as value ,getsubjectname(subjectcode) as label FROM teachersectionsubjectmapping WHERE teachercode =? and sessioncode =? AND classcode =? ${sectionCode.isEmpty ? "" : "AND sectioncode = ? "}order by label",
      parameters: {
        "teacherCode": teacherCode,
        "sessionCode": sessionCode,
        "classCode": classCode,
        "sectionCode": sectionCode,
      },
    );
    return payload.toJson();
  }

  Map<String, dynamic> generatePayloadForActivity(String sessionCode,
      String classCode, String sectionCode, String subjectCode,
      {String? queryPart, String? fieldIds}) {
    QueryPayload payload = QueryPayload(
      fieldIds: fieldIds ??
          "sessionCode, classCode${sectionCode.isEmpty ? "" : ", sectionCode"}${subjectCode.isEmpty ? "" : ", subjectCode"}",
      queryPart: queryPart ??
          "WITH main AS (SELECT upper(activityname) as activity, activitycode, coalesce(orderno,'1')::numeric as ord FROM examactivitymaster WHERE sessioncode = ? AND classcode = ? ${sectionCode.isEmpty ? "" : "AND sectioncode = ? "}${subjectCode.isEmpty ? "" : "AND subjectcode = ? "}AND subjecttype = 'Theory') SELECT activitycode as value, activity as label FROM main ORDER BY ord",
      parameters: {
        "sessionCode": sessionCode,
        "classCode": classCode,
        "sectionCode": sectionCode,
        "subjectCode": subjectCode,
      },
    );
    return payload.toJson();
  }

  Widget getDropDownValue(String parameterName) {
    switch (parameterName) {
      case "sessionCode":
        return getSessionDropDown();
      case "classCode":
        return getClassDropDown();
      case "sectionCode":
        return getSectionDropDown();
      case "subjectCode":
        return getSubjectDropDown();
      case "activityCode":
        return getExamDropDown();
      case "fromDate":
        isFromMarksVisible = true;
        return getFromMarksDropDown();
      case "toDate":
        return getToMarksDropDown();
      default:
        return Container();
    }
  }

  (String?, String?) getQueryPartAndFieldIdUsingParamName(String paramName) {
    // Find the model with the matching parameter name
    for (ResultAnalysisFieldModel model in resultAnalysisFieldModel) {
      if (model.parameterName == paramName) {
        // Return queryPart and functionName as a record/tuple
        return (model.queryPart, model.functionName);
      }
    }

    // Return null values if no matching model is found
    return (null, null);
  }

  Widget getSessionDropDown() {
    return AppTextfield(
      onTap: () => openResultAnalysisDropDownBottomSheet(context, sessions,
          (selectedSession) {
        setState(() {
          this.selectedSession = selectedSession;

          String? queryPart;
          String? fieldName;

          (queryPart, fieldName) =
              getQueryPartAndFieldIdUsingParamName("sessionCode");

          ResultAnalysisViewModel.instance
              .getDynamicDropDownValue(generateQueryJsonForClass(
                  selectedSession.value ?? "", teacherCode,
                  queryPart: queryPart, fieldIds: fieldName))
              .then((response) {
            if (response.success) {
              setState(() {
                classes = response.data ?? [];
              });
            }
            return response;
          });
        });
      }),
      hintText: selectedSession?.label ?? 'Session',
    );
  }

  Widget getClassDropDown() {
    return AppTextfield(
      onTap: () => openResultAnalysisDropDownBottomSheet(context, classes,
          (selectedClass) {
        setState(() {
          this.selectedClass = selectedClass;

          // Check if sectionCode field is visible in resultAnalysisFieldModel
          bool isSectionVisible = false;
          for (ResultAnalysisFieldModel model in resultAnalysisFieldModel) {
            if (model.parameterName == "sectionCode" &&
                (int.tryParse(model.parameterValue ?? "") ?? 0) == 1) {
              isSectionVisible = true;
              break;
            }
          }

          if (isSectionVisible) {
            String? queryPart;
            String? fieldName;

            (queryPart, fieldName) =
                getQueryPartAndFieldIdUsingParamName("classCode");
            // If section is visible, load sections normally
            ResultAnalysisViewModel.instance
                .getDynamicDropDownValue(generateQueryJsonForSection(
                    teacherCode,
                    selectedSession?.value ?? "",
                    selectedClass.value ?? "",
                    queryPart: queryPart,
                    fieldIds: fieldName))
                .then((response) {
              if (response.success) {
                setState(() {
                  sections = response.data ?? [];
                });
              }
              return response;
            });
          } else {
            String? queryPart;
            String? fieldName;

            (queryPart, fieldName) =
                getQueryPartAndFieldIdUsingParamName("classCode");
            // If section is not visible, call subject API directly
            ResultAnalysisViewModel.instance
                .getDynamicDropDownValue(generateQueryJsonForSubject(
                    teacherCode,
                    selectedSession?.value ?? "",
                    selectedClass.value ?? "",
                    "",
                    queryPart: queryPart,
                    fieldIds:
                        fieldName)) // Empty sectionCode since section is not visible
                .then((response) {
              if (response.success) {
                setState(() {
                  subjects = response.data ?? [];
                });
              }
              return response;
            });
          }
        });
      }),
      hintText: selectedClass?.label ?? 'Class',
    );
  }

  Widget getSectionDropDown() {
    return AppTextfield(
      onTap: () => openResultAnalysisDropDownBottomSheet(context, sections,
          (selectedSection) {
        setState(() {
          this.selectedSection = selectedSection;

          // Check if subjectCode field is visible in resultAnalysisFieldModel
          bool isSubjectVisible = false;
          for (ResultAnalysisFieldModel model in resultAnalysisFieldModel) {
            if (model.parameterName == "subjectCode" &&
                (int.tryParse(model.parameterValue ?? "") ?? 0) == 1) {
              isSubjectVisible = true;
              break;
            }
          }

          if (isSubjectVisible) {
            String? queryPart;
            String? fieldName;

            (queryPart, fieldName) =
                getQueryPartAndFieldIdUsingParamName("sectionCode");
            // If subject is visible, load subjects normally
            ResultAnalysisViewModel.instance
                .getDynamicDropDownValue(generateQueryJsonForSubject(
                    teacherCode,
                    selectedSession?.value ?? "",
                    selectedClass?.value ?? "",
                    selectedSection.value ?? "",
                    queryPart: queryPart,
                    fieldIds: fieldName))
                .then((response) {
              if (response.success) {
                setState(() {
                  subjects = response.data ?? [];
                });
              }
              return response;
            });
          } else {
            String? queryPart;
            String? fieldName;

            (queryPart, fieldName) =
                getQueryPartAndFieldIdUsingParamName("sectionCode");
            // If subject is not visible, call exam API directly
            ResultAnalysisViewModel.instance
                .getDynamicDropDownValue(generatePayloadForActivity(
                    selectedSession?.value ?? "",
                    selectedClass?.value ?? "",
                    selectedSection.value ?? "",
                    "",
                    queryPart: queryPart,
                    fieldIds:
                        fieldName)) // Empty subjectCode since subject is not visible
                .then((response) {
              if (response.success) {
                setState(() {
                  exams = response.data ?? [];
                });
              }
              return response;
            });
          }
        });
      }),
      hintText: selectedSection?.label ?? 'Section',
    );
  }

  Widget getSubjectDropDown() {
    return AppTextfield(
      onTap: () => openResultAnalysisDropDownBottomSheet(context, subjects,
          (selectedSubject) {
        setState(() {
          this.selectedSubject = selectedSubject;

          String? queryPart;
          String? fieldName;

          (queryPart, fieldName) =
              getQueryPartAndFieldIdUsingParamName("subjectCode");

          ResultAnalysisViewModel.instance
              .getDynamicDropDownValue(generatePayloadForActivity(
                  selectedSession?.value ?? "",
                  selectedClass?.value ?? "",
                  selectedSection?.value ?? "",
                  selectedSubject.value ?? "",
                  queryPart: queryPart,
                  fieldIds: fieldName))
              .then((response) {
            if (response.success) {
              setState(() {
                exams = response.data ?? [];
              });
            }
            return response;
          });
        });
      }),
      hintText: selectedSubject?.label ?? 'Subject',
    );
  }

  Widget getExamDropDown() {
    return AppTextfield(
      onTap: () =>
          openResultAnalysisDropDownBottomSheet(context, exams, (selectedExam) {
        setState(() {
          this.selectedExam = selectedExam;
        });
      }),
      hintText: selectedExam?.label ?? 'Exam',
    );
  }

  Widget getFromMarksDropDown() {
    return AppTextfield(
      controller: fromMarks,
      enabled: true,
      showIcon: false,
      hintText: 'From Marks',
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
    );
  }

  Widget getToMarksDropDown() {
    return AppTextfield(
      controller: toMarks,
      enabled: true,
      showIcon: false,
      hintText: 'To Marks',
      keyboardType:
          const TextInputType.numberWithOptions(signed: false, decimal: false),
    );
  }
}
