import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/student_time_table/Model/student_time_table.dart';
import 'package:school_app/student_time_table/ViewModel/student_time_table_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class StudentTimeTableScreen extends StatefulWidget {
  static const String routeName = '/student-timetable';
  final String? title;
  const StudentTimeTableScreen({super.key, this.title});

  @override
  State<StudentTimeTableScreen> createState() => _StudentTimeTableScreenState();
}

class _StudentTimeTableScreenState extends State<StudentTimeTableScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  ValueNotifier<WeekDay> selectedDayNotifier = ValueNotifier(WeekDay.Mon);
  Future<ApiResponse<List<Lecture>>>? getDayScheduleFuture;
  List<Lecture> currentDayLecture = [];
  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();

    // Get current weekday and set initial selected day
    final currentTime = DateTime.now();
    final currentWeekday = currentTime.weekday;

    // If Sunday (weekday 7), select Saturday (weekday 6)
    // Subtract 1 because WeekDay enum is 0-based (Mon = 0, Tue = 1, etc.)
    final initialDay = currentWeekday == DateTime.sunday
        ? WeekDay.values[5] // Saturday
        : WeekDay.values[currentWeekday - 1];

    selectedDayNotifier.value = initialDay;
    // Initialize PageController to show the current day
    pageController =
        PageController(initialPage: WeekDay.values.indexOf(initialDay));

    // Initial fetch for the current day
    fetchDaySchedule(initialDay);
  }

  void fetchDaySchedule(WeekDay day) {
    setState(() {
      getDayScheduleFuture = StudentTimeTableViewModel.instance
          .getStudentTimeTable(day.fullLowercase)
          .then((response) {
        if (response.success) {
          // Initialize map with empty lists for all weekdays
          currentDayLecture = response.data ?? [];
        }
        return response;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Time Table",
        body: AppFutureBuilder(
          future: getDayScheduleFuture,
          builder: (context, snapshot) => studentTimeTableBody(context),
        ),
      ),
    );
  }

  Widget studentTimeTableBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: [
          ValueListenableBuilder(
              valueListenable: selectedDayNotifier,
              builder: (context, selectedDay, _) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        final currentIndex =
                            WeekDay.values.indexOf(selectedDayNotifier.value);
                        if (currentIndex > 0) {
                          pageController.animateToPage(
                            currentIndex - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                          final newDay = WeekDay.values[currentIndex - 1];
                          selectedDayNotifier.value = newDay;
                          fetchDaySchedule(newDay);
                        }
                      },
                      child: const Icon(CupertinoIcons.chevron_left),
                    ),
                    Container(
                      decoration: const BoxDecoration(),
                      child: Center(
                        child: Text(
                          selectedDay.toString().split('.').last,
                          textScaler: const TextScaler.linear(1.0),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: ColorConstant.primaryTextColor,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        final currentIndex =
                            WeekDay.values.indexOf(selectedDayNotifier.value);
                        if (currentIndex < WeekDay.values.length - 1) {
                          pageController.animateToPage(
                            currentIndex + 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );

                          final newDay = WeekDay.values[currentIndex + 1];
                          selectedDayNotifier.value = newDay;
                          fetchDaySchedule(newDay);
                        }
                      },
                      child: const Icon(CupertinoIcons.chevron_right),
                    ),
                  ],
                );
              }),
          const Divider(
            color: ColorConstant.secondaryTextColor,
            thickness: 0.3,
          ),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: WeekDay.values.length,
              onPageChanged: (index) {},
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final day = WeekDay.values[index];

                if (currentDayLecture.isEmpty) {
                  return const NoDataWidget();
                }

                return DataTableWidget(
                  headingRowHeight: 35,
                  headingTextStyle: const TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w300,
                    fontSize: 12,
                  ),
                  headingRowColor: ColorConstant.primaryColor,
                  dataTextStyle: const TextStyle(
                    fontFamily: fontFamily,
                    fontSize: 12,
                  ),
                  headers: [
                    TableColumnConfiguration(text: "Period", width: 60),
                    TableColumnConfiguration(text: "Subject", width: 100),
                    TableColumnConfiguration(text: "Teacher", width: 160),
                  ],
                  data: currentDayLecture.map((lecture) {
                    return TableRowConfiguration(
                      rowHeight: 45,
                      cells: [
                        TableCellConfiguration(
                          text: lecture.lecture == "Zero Period"
                              ? "Enrichment"
                              : lecture.lecture,
                        ),
                        TableCellConfiguration(text: lecture.subject),
                        TableCellConfiguration(text: lecture.teacher),
                      ],
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
