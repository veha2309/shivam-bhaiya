import 'package:flutter/material.dart';
import 'package:school_app/academic_remark/view/academic_remark_screen.dart';
import 'package:school_app/academic_remark/view/academic_remark_view_screen.dart';
import 'package:school_app/attendance_reconciliation/view/attandance_reconcilliation_search_screen.dart';
import 'package:school_app/attendance_screen/view/attandance_view_screen.dart';
import 'package:school_app/attendance_screen/view/attendance_daily_check_in_search_screen.dart';
import 'package:school_app/attendance_screen/view/attendance_daily_view.dart';
import 'package:school_app/concerns/view/concerns_view.dart';
import 'package:school_app/discipline/view/raise_discipline_search_screen.dart';
import 'package:school_app/home_screen/view/home_screen.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/result_analysis/model/result_analysis_template_model.dart';
import 'package:school_app/result_analysis/view/result_analysis_view.dart';
import 'package:school_app/result_analysis/view_model/result_analysis_view_model.dart';
import 'package:school_app/upload_marks/View/upload_marks_screen.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/attendance_screen/view/attendance_dashboard_screen.dart';
import 'package:school_app/utils/utils.dart';

enum ScreenType {
  discipline,
  resultAnalysis,
  attandance,
  academicRemark,
  academicConcern,
  ruleViolation,
  academicNormViolation,
  uploadMarks
}

final class HomeSubsectionScreen extends StatefulWidget {
  static const String routeName = '/home-subsection';
  final String? title;

  const HomeSubsectionScreen({
    super.key,
    required this.currentScreen,
    this.title,
  });

  final ScreenType currentScreen;

  @override
  State<HomeSubsectionScreen> createState() => _HomeSubsectionScreenState();
}

class _HomeSubsectionScreenState extends State<HomeSubsectionScreen> {
  Future<ApiResponse<List<ResultAnalysisTemplateModel>>>?
      getResultAnalysisTemplateListFuture;
  List<ResultAnalysisTemplateModel>? resultAnalysisTemplateModel;
  Map<String, List<ResultAnalysisTemplateModel>> resultAnalysisTemplateMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.currentScreen == ScreenType.resultAnalysis) {
      getResultAnalysisTemplateListFuture = ResultAnalysisViewModel.instance
          .getResultAnalysisTemplateList()
          .then((response) {
        if (response.success) {
          resultAnalysisTemplateModel = response.data;
          if (resultAnalysisTemplateModel != null) {
            for (var template in resultAnalysisTemplateModel ?? []) {
              if (resultAnalysisTemplateMap.containsKey(template.reportGroup)) {
                resultAnalysisTemplateMap[template.reportGroup]!.add(template);
              } else {
                resultAnalysisTemplateMap[template.reportGroup] = [template];
              }
            }

            resultAnalysisTemplateMap = Map.fromEntries(
              resultAnalysisTemplateMap.entries.toList()
                ..sort(
                  (a, b) {
                    List<String> order = [
                      "A-1",
                      "A-2",
                      "B-1",
                      "B-2",
                      "C-1",
                      "C-2"
                    ];
                    return order.indexOf(a.key).compareTo(order.indexOf(b.key));
                  },
                ),
            );
            int i = 0;
            const List<String> analysisOptions = [
              'My Section Analysis',
              'My Class Analysis',
              'My Subject Exam-Wise Analysis (All Sections)',
              'My Subject Cumulative Exam Analysis (All Sections)',
              'Section-Wise Exam Analysis (All Subjects)',
              'Section-Wise Cumulative Analysis (All Subjects)',
            ];
            final updatedMap = <String, List<ResultAnalysisTemplateModel>>{};
            for (var entry in resultAnalysisTemplateMap.entries) {
              if (i >= analysisOptions.length) break;
              updatedMap[analysisOptions[i]] = entry.value;
              i++;
            }
            resultAnalysisTemplateMap = updatedMap;
          }
        }
        return response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ??
            switch (widget.currentScreen) {
              ScreenType.discipline => "Discipline",
              ScreenType.attandance => "Attendance",
              ScreenType.academicRemark => "Academic Remark",
              ScreenType.resultAnalysis => "Result Analysis",
              ScreenType.ruleViolation => "Rules Violation",
              ScreenType.academicConcern => "Academic Concern",
              ScreenType.academicNormViolation => "Academic Norm Violation",
              ScreenType.uploadMarks => "Upload Marks",
            },
        body: studentProfileBody(context),
      ),
    );
  }

  Widget studentProfileBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            if (widget.currentScreen == ScreenType.attandance)
              getAttendanceView(context),
            if (widget.currentScreen == ScreenType.discipline)
              getDisciplineView(context),
            if (widget.currentScreen == ScreenType.resultAnalysis)
              getResultAnalysicView(context),
            if (widget.currentScreen == ScreenType.academicRemark)
              getAcademicRemarkView(context),
            if (widget.currentScreen == ScreenType.ruleViolation)
              getRuleViolationView(context),
            // if (widget.currentScreen == ScreenType.academicConcern)
            //   getAcademicConcernView(context),
            if (widget.currentScreen == ScreenType.uploadMarks)
              getUploadMarksView(context),
            if (widget.currentScreen == ScreenType.academicNormViolation)
              getAcademicNormViolationView(context)
          ],
        ),
      ),
    );
  }

  Widget getAcademicRemarkView(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        RectangleTileComponent(
          title: "Add Record",
          onTap: () => navigateToScreen(
              context,
              const AcademicRemarkSearchScreen(
                navigationType: AcademicNavigationType.remark,
              )),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
        RectangleTileComponent(
          title: "View Record",
          onTap: () =>
              navigateToScreen(context, const AcademicRemarkViewScreen()),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
      ],
    );
  }

  // Widget getAcademicConcernView(BuildContext context) {
  //   return Column(
  //     spacing: 16.0,
  //     children: [
  //       RectangleTileComponent(
  //
  //         title: "Add Academic Card",
  //         icon: IconConstants.schoolCalendar,
  //         onTap: () => navigateToScreen(
  //             context,
  //             ConcernsView(screenType: ConcernsViewScreenType.disciplineCard, screenOperation: ConcernsViewScreenOperation.add) ,
  //       ),
  //     ],
  //   );
  // }

  Widget getAttendanceView(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        RectangleTileComponent(
          title: "Mark Attendance",
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(
              context, const AttendanceDashboardScreen()),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
        RectangleTileComponent(
          title: "View Daily Attendance",
          textColor: Colors.white,
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(context, const AttendanceDailyView()),
          isTitleCentered: true,
        ),
        RectangleTileComponent(
          title: "View Cumulative Attendance",
          textColor: Colors.white,
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(context, const AttandanceViewScreen()),
          isTitleCentered: true,
        ),
        RectangleTileComponent(
          title: "Reconcile Attendance",
          textColor: Colors.white,
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(
              context, const AttandanceReconcilliationSearchScreen()),
          isTitleCentered: true,
        ),
      ],
    );
  }

  Widget getDisciplineView(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        RectangleTileComponent(
          title: "Add Record",
          onTap: () {
            if (DateTime.now().hour > 16) {
              showSnackBarOnScreen(context,
                  "You are not allowed to add discipline record after 4 PM");
              return;
            }
            navigateToScreen(
                context,
                const RaiseDisciplineSearchScreen(
                  title: "Add Discipline Violation Record",
                ));
          },
          isTitleCentered: true,
          textColor: Colors.white,
        ),
        RectangleTileComponent(
          title: "View Record",
          onTap: () {
            navigateToScreen(
                context,
                const ConcernsView(
                    screenType: ConcernsViewScreenType.discipline,
                    screenOperation: ConcernsViewScreenOperation.view,
                    title: "View Discipline Violation Record"));
          },
          isTitleCentered: true,
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget getResultAnalysicView(BuildContext context) {
    return AppFutureBuilder(
      future: getResultAnalysisTemplateListFuture,
      builder: (context, snapshot) {
        if (resultAnalysisTemplateModel?.isEmpty ?? true) {
          return const NoDataWidget();
        }
        return Column(
          children: [
            ...resultAnalysisTemplateMap.entries.map((e) {
              String key = e.key;

              List<ResultAnalysisTemplateModel> value = e.value;

              String reportName = key;
              // value.isNotEmpty ? value.first.reportName ?? "" : "";

              bool show = true;

              for (var template in value) {
                show = (template.showHide?.toUpperCase() == "YES") && show;
              }

              int backgroundIndex = hashKeyToIndex(key, 4);

              return show
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: RectangleTileComponent(
                        title: reportName,
                        textColor: ColorConstant.backgroundColor,
                        onTap: () => navigateToScreen(
                          context,
                          ResultAnalysisScreen(
                            resultAnalysisTemplateModel: value,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox();
            }),
          ],
        );
      },
    );
  }

  Widget getRuleViolationView(BuildContext context) {
    return Column(spacing: 16.0, children: [
      RectangleTileComponent(
        title: "Add Record",
        // icon: IconConstants.curricullam,
        onTap: () => navigateToScreen(
          context,
          const AcademicRemarkSearchScreen(
            navigationType: AcademicNavigationType.card,
            title: "Add Rule Violation Record",
          ),
        ),
        isTitleCentered: true,
        textColor: Colors.white,
      ),
      RectangleTileComponent(
        title: "View Record",
        // icon: IconConstants.curricullam,
        onTap: () => navigateToScreen(
            context,
            const ConcernsView(
                screenType: ConcernsViewScreenType.disciplineCard,
                screenOperation: ConcernsViewScreenOperation.view,
                title: "View Rule Violation Record")),
        isTitleCentered: true,
        textColor: Colors.white,
      ),
    ]);
  }

  Widget getAcademicNormViolationView(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        RectangleTileComponent(
          title: "Add Record",
          onTap: () => navigateToScreen(
            context,
            const AcademicRemarkSearchScreen(
              navigationType: AcademicNavigationType.remark,
              title: "Add Academic Norm Violation Record",
            ),
          ),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
        RectangleTileComponent(
          title: "View Record",
          onTap: () => navigateToScreen(
              context,
              const ConcernsView(
                screenType: ConcernsViewScreenType.academicDiscipline,
                screenOperation: ConcernsViewScreenOperation.view,
                title: "View Academic Norm Violation Record",
              )),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
      ],
    );
  }

  Widget getUploadMarksView(BuildContext context) {
    return Column(
      spacing: 16.0,
      children: [
        RectangleTileComponent(
          title: "Upload Marks",
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(
            context,
            const UploadMarksScreen(
              screenState: UploadMarksScreenState.marksToBeUploaded,
              screenName: "Upload Marks",
            ),
          ),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
        RectangleTileComponent(
          title: "Edit Marks",
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(
            context,
            const UploadMarksScreen(
              screenState: UploadMarksScreenState.marksEntered,
              screenName: "Edit Marks",
            ),
          ),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
        RectangleTileComponent(
          title: "Locked/Expired Marks",
          // icon: IconConstants.schoolCalendar,
          onTap: () => navigateToScreen(
            context,
            const UploadMarksScreen(
              screenState: UploadMarksScreenState.expired,
              screenName: "Locked/Expired Marks",
            ),
          ),
          isTitleCentered: true,
          textColor: Colors.white,
        ),
      ],
    );
  }

  int hashKeyToIndex(String key, int modValue) {
    int seed = 0x9747b28c; // Random seed for variation
    int hash = seed;

    for (int i = 0; i < key.length; i++) {
      int k = key.codeUnitAt(i);
      k *= 0xcc9e2d51; // Murmur-inspired multiplication
      k = (k << 15) | (k >> 17); // Left rotate by 15 bits
      k *= 0x1b873593;

      hash ^= k;
      hash = (hash << 13) | (hash >> 19); // Left rotate by 13 bits
      hash = hash * 5 + 0xe6546b64;
    }

    // Final mixing
    hash ^= key.length;
    hash ^= (hash >> 16);
    hash *= 0x85ebca6b;
    hash ^= (hash >> 13);
    hash *= 0xc2b2ae35;
    hash ^= (hash >> 16);

    // Ensure non-negative index within the given range
    return (hash & 0x7FFFFFFF) % modValue;
  }
}
