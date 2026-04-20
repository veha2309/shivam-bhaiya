import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/curriculum_screen/model/curriculam.dart';
import 'package:school_app/curriculum_screen/model/curriculam_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class CurriculumScreen extends StatefulWidget {
  static const String routeName = '/curriculum';
  final String? title;
  const CurriculumScreen({super.key, this.title});

  @override
  State<CurriculumScreen> createState() => _CurriculumScreenState();
}

class _CurriculumScreenState extends State<CurriculumScreen> {
  List<Curriculam> curriculamList = [];
  Map<String, List<Curriculam>> curriculamMap = {};
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<Curriculam>>>? getCurriculamFuture;

  @override
  void initState() {
    super.initState();
    fetchCurriculumData();
  }

  void fetchCurriculumData() {
    isLoadingNotifier.value = true;
    getCurriculamFuture =
        CurriculamViewModel.instance.getStudentCurriculam().then((response) {
      if (response.success) {
        curriculamList = response.data ?? [];
        // Group curriculum by examName
        curriculamMap = {};
        for (var curriculum in curriculamList) {
          String key = curriculum.examName ?? "Other";
          if (curriculamMap.containsKey(key)) {
            curriculamMap[key]!.add(curriculum);
          } else {
            curriculamMap[key] = [curriculum];
          }
        }
      }
      isLoadingNotifier.value = false;
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Curriculum",
        body: curriculumBody(context),
      ),
    );
  }

  Widget curriculumBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppFutureBuilder(
        future: getCurriculamFuture,
        builder: (context, snapshot) {
          if (curriculamMap.isEmpty) {
            return const NoDataWidget();
          }

          return ListView(
            children: curriculamMap.entries.map((entry) {
              return curriculumExamSection(entry.key, entry.value);
            }).toList(),
          );
        },
      ),
    );
  }

  Widget curriculumExamSection(
      String examName, List<Curriculam> curriculumList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...curriculumList.asMap().entries.map((entry) {
            int index = entry.key;
            var curriculum = entry.value;

            int backgroundIndex = 0;

            if (index % 4 == 0) {
              backgroundIndex = 0;
            } else if (index % 4 == 1) {
              backgroundIndex = 1;
            } else if (index % 4 == 2) {
              backgroundIndex = 2;
            } else if (index % 4 == 3) {
              backgroundIndex = 3;
            }

            String backgroundImage = getBackgroundPath[backgroundIndex];

            return curriculumItem(curriculum, backgroundImage, examName);
          }),
        ],
      ),
    );
  }

  Widget curriculumItem(
      Curriculam curriculam, String backgroundImage, String examName) {
    bool isExpanded = false;
    return StatefulBuilder(builder: (context, setChildState) {
      return Container(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: DecorationImage(
                  image: AssetImage(backgroundImage),
                  fit: BoxFit.cover,
                ),
              ),
              child: ListTile(
                style: ListTileStyle.list,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  examName,
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstant.backgroundColor,
                    fontFamily: fontFamily,
                  ),
                ),
                onTap: () => setChildState(() => isExpanded = !isExpanded),
                trailing: Icon(
                  isExpanded
                      ? CupertinoIcons.chevron_up
                      : CupertinoIcons.chevron_down,
                  color: ColorConstant.backgroundColor,
                ),
              ),
            ),
            if (isExpanded)
              Container(
                padding: const EdgeInsets.only(top: 16.0),
                child: DataTableWidget(
                  headers: [
                    TableColumnConfiguration(text: "Subject", width: 60),
                    TableColumnConfiguration(text: "Upload Date", width: 100),
                    TableColumnConfiguration(
                        text: "Revised Upload Date", width: 150),
                  ],
                  data: [
                    TableRowConfiguration(
                      rowHeight: 40,
                      cells: [
                        TableCellConfiguration(
                            text: curriculam.subjectName ?? "-"),
                        TableCellConfiguration(
                            text: curriculam.uploadDate ?? "-"),
                        TableCellConfiguration(
                            text: curriculam.revisedUploadDate ?? "-"),
                      ],
                    ),
                  ],
                  headingTextStyle: const TextStyle(
                    fontSize: 12,
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w500,
                  ),
                  dataTextStyle: const TextStyle(
                    fontSize: 14,
                    fontFamily: fontFamily,
                  ),
                  headingRowHeight: 40,
                ),
              )
          ],
        ),
      );
    });
  }
}

List<String> getBackgroundPath = [
  ImageConstants.purpleHorizontalBoxImagePath,
  ImageConstants.blueHorizontalBoxImagePath,
  ImageConstants.yellowHorizontalBoxImagePath,
  ImageConstants.grayHorizontalBoxImagePath,
];
