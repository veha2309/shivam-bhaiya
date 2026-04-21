import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/discipline_passbook/model/discipline_student_model.dart';
import 'package:school_app/discipline_passbook/model/discipline_zone_model.dart';
import 'package:school_app/discipline_passbook/view_model/discipline_passbook_view_model.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/my_discipline_passbook/view/my_discipline_passbook_screen.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class DisciplinePassbookScreen extends StatefulWidget {
  static const String routeName = '/discipline-passbook';
  final String? title;
  const DisciplinePassbookScreen({super.key, this.title});

  @override
  State<DisciplinePassbookScreen> createState() =>
      _DisciplinePassbookScreenState();
}

class _DisciplinePassbookScreenState extends State<DisciplinePassbookScreen> {
  TextEditingController classController = TextEditingController();
  TextEditingController sectionController = TextEditingController();
  TextEditingController studentNameController = TextEditingController();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<DisciplineStudentModel>>>?
      getStudentListForDisciplinePassbookFuture;
  Future<ApiResponse<List<DisciplineZoneModel>>>? getStudentScoreFuture;
  List<DisciplineStudentModel> disciplineList = [];
  List<DisciplineZoneModel> disciplineScoreList = [];
  FocusNode studentNameFocusNode = FocusNode();

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

  ClassModel? selectedClass;
  Section? selectedSection;
  DateTime? selectedDate;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  void callGetStudentScoreList() {
    if (studentNameController.text.isEmpty) {
      if (selectedClass != null && selectedSection != null) {
        getStudentScoreFuture = DisciplinePassbookViewModel.instance
            .getSearchedStudentDisciplineCount(
                selectedClass!.classCode, selectedSection!.sectionCode, "-")
            .then((response) {
          if (response.success) {
            disciplineScoreList = response.data ?? [];
            setState(() {});
          }
          return response;
        });
      }
    } else {
      getStudentScoreFuture = DisciplinePassbookViewModel.instance
          .getSearchedStudentDisciplineCount("", "", studentNameController.text)
          .then((response) {
        if (response.success) {
          disciplineScoreList = response.data ?? [];
          setState(() {});
        }
        return response;
      });
    }
  }

  void callGetStudentListForDisciplinePassbook() {
    disciplineList = [];
    setState(() {});
    if (studentNameController.text.isEmpty) {
      if (selectedClass != null && selectedSection != null) {
        HomeModel? homeModel = AuthViewModel.instance.homeModel;
        getStudentListForDisciplinePassbookFuture = DisciplinePassbookViewModel
            .instance
            .getStudentListForDisciplinePassbook(
                homeModel?.sessionCode ?? "", selectedSection!.sectionCode, "")
            .then(
          (response) {
            if (response.success) {
              disciplineList = response.data ?? [];
              callGetStudentScoreList();
            }
            return response;
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Please select class and section",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamily,
              ),
            ),
          ),
        );
      }
    } else {
      HomeModel? homeModel = AuthViewModel.instance.homeModel;
      getStudentListForDisciplinePassbookFuture = DisciplinePassbookViewModel
          .instance
          .getStudentListForDisciplinePassbook(
              homeModel?.sessionCode ?? "", "", studentNameController.text)
          .then(
        (response) {
          if (response.success) {
            disciplineList = response.data ?? [];
            callGetStudentScoreList();
          }
          return response;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Discipline Passbook",
        body: getMyDisciplinePassBookBody(context),
      ),
    );
  }

  Widget getMyDisciplinePassBookBody(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16),
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
                color: ColorConstant.primaryTextColor,
                fontFamily: fontFamily,
                fontSize: 18,
              ),
            ),
            AppTextfield(
              focusNode: studentNameFocusNode,
              controller: studentNameController,
              hintText: "Student Name",
              enabled: true,
            ),
            SizedBox(
              child: AppButton(
                  onPressed: (_) {
                    callGetStudentListForDisciplinePassbook();
                  },
                  text: "SEARCH"),
            ),
            getDataTableWidget(),
            getTotalCountCard(),
          ],
        ),
      ),
    );
  }

  Widget getDataTableWidget() {
    return Column(
      spacing: 16,
      children: [
        FutureBuilder<ApiResponse<List<DisciplineStudentModel>>>(
          future: getStudentListForDisciplinePassbookFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return getLoaderWidget();
            }

            if (snapshot.hasData &&
                snapshot.data?.data != null &&
                snapshot.data!.data!.isNotEmpty) {
              return DataTableWidget(
                headers: [
                  TableColumnConfiguration(text: "Roll\nNo", width: 32),
                  TableColumnConfiguration(text: "Admission\nNo", width: 65),
                  TableColumnConfiguration(text: "Student\nName", width: 100),
                  TableColumnConfiguration(text: "DP\nScore", width: 50),
                  TableColumnConfiguration(text: "Present\nZone", width: 130),
                ],
                data: snapshot.data!.data!.asMap().entries.map((disciplineMap) {
                  DisciplineStudentModel discipline = disciplineMap.value;

                  onCellTap(int index) => {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MyDisciplinePassbookScreen(
                                studentModel: discipline),
                          ),
                        )
                      };

                  return TableRowConfiguration(
                    rowHeight: 60,
                    onTap: onCellTap,
                    cells: [
                      TableCellConfiguration(
                          text: discipline.rollNo, width: 32),
                      TableCellConfiguration(
                          text: discipline.admissionNo, width: 65),
                      TableCellConfiguration(
                          text: discipline.studentName, width: 100),
                      TableCellConfiguration(text: discipline.bal, width: 50),
                      TableCellConfiguration(text: discipline.zone, width: 130),
                    ],
                  );
                }).toList(),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  Widget getTotalCountCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        child: Column(
          spacing: 16.0,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: disciplineScoreList.isEmpty
              ? []
              : [
                  const Text(
                    "Total Count",
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                      color: ColorConstant.primaryColor,
                      fontSize: 20,
                      fontFamily: fontFamily,
                    ),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: disciplineScoreList.length,
                    itemBuilder: (context, index) {
                      DisciplineZoneModel score = disciplineScoreList[index];
                      return getRowStatCard(score.zone ?? "--",
                          score.zoneCount?.toString() ?? "--");
                    },
                  ),
                ],
        ),
      ),
    );
  }
}
