import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/document/viewmodel/upload_document_viewmodel.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/homework_screen/model/examSchedule_model.dart';
import 'package:school_app/homework_screen/model/homework_model.dart';
import 'package:school_app/homework_screen/view_model/homework_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class HomeWorkScreen extends StatefulWidget {
  static const String routeName = '/homework';
  final String? title;
  const HomeWorkScreen({super.key, this.title});

  @override
  State<HomeWorkScreen> createState() => _HomeWorkScreenState();
}

class _HomeWorkScreenState extends State<HomeWorkScreen> {
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<HomeworkModel>>>? getHomeWorkFuture;
  Future<ApiResponse<ExamScheduleModel>>? getExamSchedule;
  List<HomeworkModel>? currentMonthHomework;
  ExamScheduleModel? examSchedule;
  Set<String> daysHavingHomework = {};
  Map<String, List<HomeworkData>> currentMonthHomeWorkMap = {};
  List<HomeworkData>? selectedDayHomeWorkItems;
  Set<String> dueDates = {};
  Map<String, List<HomeworkData>> testDates = {};

  @override
  void initState() {
    super.initState();
    updateData(DateTime.now());
  }

  void callGetExamScheduleFuture() {
    HomeModel? homeModel = AuthViewModel.instance.homeModel;

    getExamSchedule = HomeworkViewModel.instance
        .getExamSchedule(homeModel?.sectionCode ?? "")
        .then((response) {
      if (response.success) {
        examSchedule = response.data;
        selectedDate.value = selectedDate.value.copyWith();
      }
      return response;
    });
  }

  void clearAllData() {
    currentMonthHomework = null;
    currentMonthHomeWorkMap.clear();
    daysHavingHomework.clear();
    selectedDayHomeWorkItems = [];
  }

  void updateData(DateTime selectedMonthData) {
    clearAllData();

    getHomeWorkFuture =
        HomeworkViewModel.instance.getHomeWork(selectedMonthData).then(
      (response) {
        if (response.success) {
          currentMonthHomework = response.data;
          currentMonthHomework?.forEach((item) {
            item.homeworkData?.forEach((item) {
              if (item.dueDate != null) {
                dueDates.add(item.dueDate!);
              }
              if (item.testDate != null) {
                if (testDates[item.testDate] != null) {
                  testDates[item.testDate]?.add(item);
                } else {
                  testDates[item.testDate ?? ""] = [item];
                }
              }
            });
            daysHavingHomework.add(item.homeworkDate ?? "");
            if (currentMonthHomeWorkMap[item.homeworkDate] == null) {
              currentMonthHomeWorkMap[item.homeworkDate ?? ""] =
                  item.homeworkData ?? [];
            } else {
              currentMonthHomeWorkMap[item.homeworkDate]
                  ?.addAll(item.homeworkData ?? []);
            }
          });
          selectedDayHomeWorkItems =
              currentMonthHomeWorkMap[getDDMMYYYYInNum(selectedMonthData)];
        }
        selectedDate.value = selectedMonthData;
        return response;
      },
    );

    callGetExamScheduleFuture();
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: widget.title ?? "Homework",
          subtext: "Assignment / Class Test / Revision Test",
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              child: AppFutureBuilder(
                future: getHomeWorkFuture,
                builder: (context, snapshot) {
                  return homeWorkScreenBody(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget homeWorkScreenBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
            child: SizedBox(
              height: 350,
              child: ValueListenableBuilder(
                  valueListenable: selectedDate,
                  builder: (context, _, __) {
                    return MonthView(
                      key: monthViewKey,
                      onPageChange: (date, page) {
                        updateData(date.copyWith(day: 01));
                      },
                      useAvailableVerticalSpace: true,
                      hideDaysNotInMonth: true,
                      showBorder: false,
                      cellBuilder: (date, event, isToday, isInMonth,
                          hideDaysNotInMonth) {
                        bool isSelected = checkSelectedDay(date);

                        bool hasExamScheduled = examSchedule?.scheduleByDate
                                ?.containsKey(getDDMMYYYYInNum(date)) ??
                            false;

                        bool haveCheckDateAndStatus = false;
                        bool haveUncheckedTest = false;

                        List<HomeworkData>? testHomeworkModel =
                            testDates[getDDMMYYYYInNum(date)];

                        testHomeworkModel?.forEach((item) {
                          if (item.checkStatus?.toLowerCase() == 'y') {
                            haveCheckDateAndStatus = true;
                          }
                          if (item.checkStatus?.toLowerCase() == 'n') {
                            haveUncheckedTest = true;
                          }
                        });

                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: isSelected
                                    ? const EdgeInsets.all(8)
                                    : EdgeInsets.zero,
                                decoration: BoxDecoration(
                                  shape: isSelected
                                      ? BoxShape.circle
                                      : BoxShape.rectangle,
                                  color: isSelected
                                      ? ColorConstant.primaryColor
                                      : null,
                                ),
                                child: Text(
                                  date.day.toString(),
                                  textScaler: const TextScaler.linear(1.0),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isInMonth
                                            ? ColorConstant.primaryTextColor
                                            : ColorConstant.secondaryTextColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: fontFamily,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.topRight,
                              child: Column(
                                children: [
                                  if (currentMonthHomeWorkMap[
                                          getDDMMYYYYInNum(date)] !=
                                      null)
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 5, right: 5),
                                      height: 8,
                                      width: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: date.isBefore(DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day))
                                            ? Colors.grey
                                            : ColorConstant.primaryColor,
                                      ),
                                    ),
                                  if (testDates
                                      .containsKey(getDDMMYYYYInNum(date))) ...[
                                    if (haveCheckDateAndStatus)
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 2, right: 5),
                                        height: 8,
                                        width: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                        ),
                                      ),
                                    if (haveUncheckedTest)
                                      Container(
                                        margin: const EdgeInsets.only(
                                            top: 2, right: 5),
                                        height: 8,
                                        width: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: ColorConstant.errorColor,
                                        ),
                                      ),
                                  ],
                                  if (dueDates.contains(getDDMMYYYYInNum(date)))
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 2, right: 5),
                                      height: 8,
                                      width: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: date.isBefore(DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day + 1))
                                            ? null
                                            : Colors.orange,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              left: 0,
                              right: 0,
                              child: Align(
                                // alignment: Alignment.bottomCenter,
                                child: Container(
                                  constraints:
                                      const BoxConstraints(maxWidth: 20),
                                  decoration: BoxDecoration(
                                    border: hasExamScheduled
                                        ? const Border(
                                            bottom: BorderSide(width: 2))
                                        : null,
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                      headerStringBuilder: (date, {secondaryDate}) {
                        return "${monthIntToString(date.month)} ${date.year}";
                      },
                      headerStyle: const HeaderStyle(
                        headerTextStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamily,
                        ),
                      ),
                      weekDayStringBuilder: (int index) {
                        return " ";
                        return intToWeekDay(index);
                      },
                      headerBuilder: (date) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    monthViewKey.currentState?.previousPage();
                                  },
                                  child:
                                      const Icon(CupertinoIcons.chevron_left),
                                ),
                                Container(
                                  decoration: const BoxDecoration(),
                                  child: Center(
                                    child: Text(
                                      "${monthIntToString(date.month)} ${date.year}",
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
                                    monthViewKey.currentState?.nextPage();
                                  },
                                  child:
                                      const Icon(CupertinoIcons.chevron_right),
                                ),
                              ],
                            ),
                            const Divider(
                              color: ColorConstant.secondaryTextColor,
                              thickness: 0.3,
                            ),
                          ],
                        );
                      },
                      startDay: WeekDays.sunday,
                      weekDayBuilder: (day) {
                        return Container(
                          decoration: const BoxDecoration(),
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              intToWeekDay(day),
                              textScaler: const TextScaler.linear(1.0),
                              style: const TextStyle(
                                fontSize: 10,
                                color: ColorConstant.secondaryTextColor,
                                fontWeight: FontWeight.bold,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                        );
                      },
                      borderColor: ColorConstant.primaryColor,
                      onCellTap: (events, date) {
                        selectedDate.value = date;
                        selectedDayHomeWorkItems =
                            currentMonthHomeWorkMap[getDDMMYYYYInNum(date)];
                      },
                      safeAreaOption: const SafeAreaOption(
                        bottom: false,
                        maintainBottomViewPadding: false,
                        minimum: EdgeInsets.zero,
                      ),
                    );
                  }),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 0, bottom: 10, left: 16.0, right: 16.0),
            child: Table(
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  children: [
                    _legendItem(
                      color: ColorConstant.inactiveColor,
                      label: 'Homework assigned earlier',
                      border: const BorderSide(color: Colors.black26),
                    ),
                    _legendItem(
                      color: ColorConstant.primaryColor,
                      label: 'Homework assigned today',
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _legendItem(
                      color: const Color(0xFFFF9800),
                      label: 'Homework due',
                    ),
                    _legendItem(
                      color: ColorConstant.errorColor,
                      label: 'Test scheduled',
                    ),
                  ],
                ),
                TableRow(
                  children: [
                    _legendItem(
                      color: const Color(0xFF4CAF50),
                      label: 'Test checked and returned',
                    ),
                    _legendLine(
                      label: 'Formal exam scheduled',
                    ),
                  ],
                ),
              ],
            ),
          ),
          getEventDayData(),
        ],
      ),
    );
  }

  Widget _legendItem(
      {required Color color, required String label, BorderSide? border}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: border != null ? Border.fromBorderSide(border) : null,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '– $label',
              style: const TextStyle(fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendLine({required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 2,
            decoration: const BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.all(Radius.circular(2)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '– $label',
              style: const TextStyle(fontSize: 9),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<HomeworkData> getTodayDueHomeworks(DateTime selectedDate) {
    final todayStr = getDDMMYYYYInNum(selectedDate);
    final List<HomeworkData> todayDueHomeworks = [];

    if (currentMonthHomework != null) {
      for (final HomeworkModel model in currentMonthHomework!) {
        if (model.homeworkData != null) {
          for (final HomeworkData data in model.homeworkData!) {
            if (data.dueDate == todayStr &&
                !selectedDate.isBefore(DateTime.now())) {
              todayDueHomeworks.add(data);
            }
          }
        }
      }
    }
    return todayDueHomeworks;
  }

  List<HomeworkData> getTodayDueTest(
      DateTime selectedDate, List<HomeworkData> homework) {
    final todayStr = getDDMMYYYYInNum(selectedDate);
    final List<HomeworkData> todayDueHomeworks = [];

    if (currentMonthHomework != null) {
      for (final HomeworkModel model in currentMonthHomework!) {
        if (model.homeworkData != null) {
          for (final HomeworkData data in model.homeworkData!) {
            if (data.testDate == todayStr) {
              int index = homework.indexWhere((homework) {
                return data.testDate == homework.testDate &&
                    data.subject == homework.subject &&
                    homework.testDate == homework.dueDate;
              });
              if (index == -1) todayDueHomeworks.add(data);
            }
          }
        }
      }
    }
    return todayDueHomeworks;
  }

  List<ExamSchedule> getTodayScheduledExam(DateTime selectedDate) {
    final todayStr = getDDMMYYYYInNum(selectedDate);
    List<ExamSchedule> exams = [];

    if (examSchedule?.scheduleByDate?.containsKey(todayStr) ?? false) {
      exams = examSchedule?.scheduleByDate?[todayStr] ?? [];
    }
    return exams;
  }

  bool checkSelectedDay(DateTime date) {
    return date.day == selectedDate.value.day &&
        date.month == selectedDate.value.month &&
        date.year == selectedDate.value.year;
  }

  Widget getEventDayData() {
    return ValueListenableBuilder(
        valueListenable: selectedDate,
        builder: (context, state, _) {
          // Get homework due today
          List<HomeworkData> todayDueHomeWork = getTodayDueHomeworks(state);
          List<HomeworkData> todayDueTest =
              getTodayDueTest(state, todayDueHomeWork);
          List<ExamSchedule> examSchedule = getTodayScheduledExam(state);

          // Combine homework items, avoiding duplicates
          List<HomeworkData> allHomeworksForDay = [
            ...todayDueHomeWork,
            ...todayDueTest,
            ...(selectedDayHomeWorkItems ?? [])
          ];

          return SizedBox(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                    color: ColorConstant.primaryColor,
                  ),
                  child: Text(
                    getEventHeaderString(state),
                    textAlign: TextAlign.center,
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.onPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                Container(
                  color: ColorConstant.primaryColor,
                  child: Container(
                    padding: const EdgeInsets.only(top: 16.0),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.0),
                        topRight: Radius.circular(12.0),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Homework Section
                        if (allHomeworksForDay.isNotEmpty) ...[
                          ...allHomeworksForDay.map((homeItem) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    homeItem.subject ?? "",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ColorConstant.primaryTextColor,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  () {
                                    if (homeItem.dueDate == null &&
                                        (homeItem.homework == null ||
                                            (homeItem.homework?.isEmpty ??
                                                false))) {
                                      return const SizedBox.shrink();
                                    }
                                    if (homeItem.dueDate == null) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          "${homeItem.homework}",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant
                                                .secondaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      );
                                    }

                                    DateTime? dueDate;
                                    try {
                                      dueDate = formatAnyDateIntoDateTime(
                                          homeItem.dueDate ?? "");
                                    } catch (_) {}

                                    if (dueDate == null) {
                                      return const SizedBox();
                                    }

                                    DateTime now = DateTime.now();
                                    DateTime currentTime =
                                        DateTime(now.year, now.month, now.day);

                                    if (dueDate.isBefore(currentTime)) {
                                      if (currentMonthHomeWorkMap[
                                              getDDMMYYYYInNum(
                                                  selectedDate.value)] !=
                                          null) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            "${homeItem.homework}${(homeItem.dueDate != null) ? " (Due Date: ${homeItem.dueDate})" : ""}",
                                            textScaler:
                                                const TextScaler.linear(1.0),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: ColorConstant
                                                  .secondaryTextColor,
                                              fontFamily: fontFamily,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    } else {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          "${homeItem.homework}${(homeItem.dueDate != null) ? " (Due Date: ${homeItem.dueDate})" : ""}",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant
                                                .secondaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      );
                                    }
                                  }(),
                                  () {
                                    if (homeItem.documentName != null &&
                                        homeItem.documentName!.isNotEmpty) {
                                      return InkWell(
                                        onTap: () async {
                                          final response =
                                              await UploadDocumentViewModel
                                                  .instance
                                                  .viewUploadedHomework(
                                            fileName: homeItem.documentName!,
                                          );
                                          if (response.success) {
                                            launchURLString(
                                                response.data ?? "");
                                          }
                                        },
                                        child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: RichText(
                                              textScaler:
                                                  const TextScaler.linear(1.0),
                                              text: TextSpan(
                                                text: "Attachment: ",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: ColorConstant
                                                      .secondaryTextColor,
                                                  fontFamily: fontFamily,
                                                ),
                                                children: [
                                                  TextSpan(
                                                    text:
                                                        "${homeItem.documentName}",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: ColorConstant
                                                          .primaryColor,
                                                      decoration: TextDecoration
                                                          .underline,
                                                      fontFamily: fontFamily,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            )

                                            // Text(
                                            //   "${homeItem.documentName}",

                                            // ),
                                            ),
                                      );
                                    } else {
                                      return const SizedBox.shrink();
                                    }
                                  }(),
                                  () {
                                    if (homeItem.testDate == null) {
                                      return const SizedBox();
                                    }

                                    DateTime? testDate;
                                    try {
                                      testDate = formatAnyDateIntoDateTime(
                                          homeItem.testDate ?? "");
                                    } catch (_) {}

                                    if (testDate == null) {
                                      return const SizedBox();
                                    }

                                    DateTime now = DateTime.now();
                                    DateTime currentTime =
                                        DateTime(now.year, now.month, now.day);

                                    if (testDate.isBefore(currentTime)) {
                                      return const SizedBox();
                                    } else {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(top: 5.0),
                                        child: Text(
                                          "Test Schedule (${homeItem.testDate})",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant
                                                .secondaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                      );
                                    }
                                  }(),
                                  if (homeItem.book?.isNotEmpty ?? false)
                                    Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Text(
                                          "Books to carry: (${homeItem.book})",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant
                                                .secondaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        )
                                      ],
                                    ),
                                  if (homeItem.notebook?.isNotEmpty ?? false)
                                    Column(
                                      children: [
                                        const SizedBox(height: 5),
                                        Text(
                                          "Notebooks to carry: (${homeItem.notebook})",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant
                                                .secondaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        )
                                      ],
                                    ),
                                  const SizedBox(height: 5),
                                  const Divider(
                                    color: ColorConstant.secondaryTextColor,
                                    thickness: 0.3,
                                  )
                                ],
                              ),
                            );
                          }),
                        ],

                        if (allHomeworksForDay.isEmpty &&
                            examSchedule.isEmpty) ...[
                          const SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                SizedBox(height: 50),
                                Text(
                                  "No Homework",
                                  textScaler: TextScaler.linear(1.0),
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: ColorConstant.secondaryTextColor,
                                    fontFamily: fontFamily,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],

                        // Exam Schedule Section
                        if (examSchedule.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          ...examSchedule.map((exam) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Exam - ${exam.subjectName}",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: ColorConstant.primaryTextColor,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  Text(
                                    exam.examName ?? "",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: ColorConstant.secondaryTextColor,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  Text(
                                    "Session: ${exam.sessionName}",
                                    textScaler: const TextScaler.linear(1.0),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: ColorConstant.secondaryTextColor,
                                      fontFamily: fontFamily,
                                    ),
                                  ),
                                  const Divider(
                                    color: ColorConstant.secondaryTextColor,
                                    thickness: 0.3,
                                  )
                                ],
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  String getEventHeaderString(DateTime dateTime) {
    return "${intToDayFull(dateTime.weekday)}, ${dateTime.day} ${monthIntToString(dateTime.month)} ${dateTime.year}";
  }
}
