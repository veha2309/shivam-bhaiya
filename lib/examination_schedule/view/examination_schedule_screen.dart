import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/examination_schedule/model/examination_schedule.dart';
import 'package:school_app/examination_schedule/view_model/examination_schedule_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class ExaminationScheduleScreen extends StatefulWidget {
  static const String routeName = '/examination-schedule';
  final String? title;
  const ExaminationScheduleScreen({super.key, this.title});

  @override
  State<ExaminationScheduleScreen> createState() =>
      _ExaminationScheduleScreenState();
}

class _ExaminationScheduleScreenState extends State<ExaminationScheduleScreen> {
  List<ExaminationSchedule> scheduleList = [];
  Map<String, List<ExaminationSchedule>> scheduleMap = {};
  Future<ApiResponse<List<ExaminationSchedule>>>? getScheduleFuture;
  String expandedSection = "";

  @override
  void initState() {
    super.initState();
    fetchExaminationScheduleData();
  }

  void fetchExaminationScheduleData() {
    getScheduleFuture = ExaminationScheduleViewModel.instance
        .getExaminationSchedule()
        .then((response) {
      if (response.success) {
        scheduleList = response.data ?? [];
        // Group schedules by examName
        scheduleMap = {};
        for (var schedule in scheduleList) {
          String key = schedule.examName ?? "Other";
          if (scheduleMap.containsKey(key)) {
            scheduleMap[key]!.add(schedule);
          } else {
            scheduleMap[key] = [schedule];
          }
        }
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: AppBody(
        title: widget.title ?? "Examination Schedule",
        body: scheduleBody(context),
      ),
    );
  }

  Widget scheduleBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppFutureBuilder(
        future: getScheduleFuture,
        builder: (context, snapshot) {
          if (scheduleMap.isEmpty) {
            return const NoDataWidget();
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  children: scheduleMap.entries.map((entry) {
                    return examScheduleSection(entry.key, entry.value);
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // launchURLString(schedule.documentUrl ?? "");
                },
                child: const Text(
                  'Examination Policy',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget examScheduleSection(
      String examName, List<ExaminationSchedule> scheduleList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...scheduleList.asMap().entries.map((entry) {
            int index = scheduleList.indexOf(entry.value);

            var schedule = entry.value;

            // Get background image based on index
            int backgroundIndex = index % 4;
            String backgroundImage = getBackgroundPath[backgroundIndex];

            return scheduleItem(schedule, backgroundImage,
                examName == expandedSection, examName);
          }),
        ],
      ),
    );
  }

  Widget scheduleItem(ExaminationSchedule schedule, String backgroundImage,
      bool isExpanded, String examName) {
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
                schedule.examName ?? "Examination Schedule",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstant.backgroundColor,
                  fontFamily: fontFamily,
                ),
              ),
              onTap: () => setState(() => expandedSection = examName),
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
              width: getWidthOfScreen(context),
              padding: const EdgeInsets.only(top: 16.0),
              child: Column(
                children: [
                  DataTableWidget(
                    headers: [
                      TableColumnConfiguration(
                          text: "Date Of Exam",
                          width: (getWidthOfScreen(context) - 64) / 2.5),
                      TableColumnConfiguration(
                          text: "Subject",
                          width: (getWidthOfScreen(context) - 64) / 2),
                    ],
                    data: [
                      TableRowConfiguration(
                        rowHeight: 40,
                        cells: [
                          TableCellConfiguration(
                            text: formatAnyDateToDDMMYY(
                                schedule.uploadDate ?? "-"),
                          ),
                          TableCellConfiguration(text: schedule.remarks ?? "-"),
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
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      launchURLString(schedule.documentUrl ?? "");
                    },
                    child: const Text(
                      'General Instructions',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

List<String> getBackgroundPath = [
  ImageConstants.purpleHorizontalBoxImagePath,
  ImageConstants.blueHorizontalBoxImagePath,
  ImageConstants.yellowHorizontalBoxImagePath,
  ImageConstants.grayHorizontalBoxImagePath,
];
