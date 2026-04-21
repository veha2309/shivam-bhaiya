import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html_table/flutter_html_table.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/news_events/Model/news_event.dart';
import 'package:school_app/news_events/ViewModel/news_event_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SchoolPlannerScreen extends StatefulWidget {
  static const String routeName = '/school-planner';
  final String? title;
  const SchoolPlannerScreen({super.key, this.title});

  @override
  State<SchoolPlannerScreen> createState() => SchoolPlannerScreenState();
}

class SchoolPlannerScreenState extends State<SchoolPlannerScreen> {
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  NewsData? currentMonthNewsAndEventData;
  Future<ApiResponse<NewsData>>? getNewsAndEventFuture;
  MonthData? currentMonthData;
  List<NewsItem>? currentMonthNewsData;
  Map<String, List<NewsItem>> currentMonthNewsDataMap = {};
  List<NewsItem>? selectedDayNewsItems = [];
  EventController eventController = EventController();

  @override
  void initState() {
    super.initState();
    updateData(DateTime.now());
  }

  void clearAllData() {
    currentMonthNewsAndEventData = null;
    currentMonthData = null;
    currentMonthNewsData = null;
    currentMonthNewsDataMap = {};
  }

  void updateData(DateTime selectedMonthData) async {
    clearAllData();
    selectedDate.value = selectedMonthData;
    getNewsAndEventFuture = NewsEventViewModel.instance
        .getNewsAndEvent(selectedDate.value)
        .then((response) {
      if (response.success) {
        currentMonthNewsAndEventData = response.data;
        currentMonthData =
            currentMonthNewsAndEventData?.months?.firstWhere((month) {
          return month.monthName ==
              "${getMonthIntToStringShort(selectedDate.value.month)}-${selectedDate.value.year}";
        });
        currentMonthNewsData = currentMonthData?.news;
        currentMonthNewsData?.forEach((item) {
          if (currentMonthNewsDataMap[item.fromDate] == null) {
            currentMonthNewsDataMap[item.fromDate ?? ""] = [item];
          } else {
            currentMonthNewsDataMap[item.fromDate]?.add(item);
          }
        });
      }

      monthViewKey.currentState?.setState(() {});
      selectedDayNewsItems =
          currentMonthNewsDataMap[getDateInDDMMMYYYY(selectedDate.value)];
      selectedDate.value = selectedMonthData.copyWith();
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: eventController,
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: widget.title ?? "School Planner",
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              child: AppFutureBuilder(
                future: getNewsAndEventFuture,
                builder: (context, snapshot) {
                  return newsEventBody(context);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget newsEventBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 12.0, top: 12.0),
            child: SizedBox(
              height: 400,
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
                        return Stack(
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                padding: isSelected
                                    ? const EdgeInsets.all(8)
                                    : const EdgeInsets.all(0),
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
                            if (currentMonthNewsDataMap[
                                    getDateInDDMMMYYYY(date)] !=
                                null)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 10, right: 10),
                                  height: 10,
                                  width: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorConstant.primaryColor,
                                  ),
                                ),
                              ),
                            if (isToday) Container()
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
                        selectedDayNewsItems =
                            currentMonthNewsDataMap[getDateInDDMMMYYYY(date)];
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
          getEventDayData(),
        ],
      ),
    );
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
                    textScaler: const TextScaler.linear(1.0),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ColorConstant.onPrimary,
                      fontFamily: fontFamily,
                    ),
                  ),
                ),
                selectedDayNewsItems == null || selectedDayNewsItems!.isEmpty
                    ? const Column(
                        children: [
                          SizedBox(height: 50),
                          Text(
                            "No Events",
                            textScaler: TextScaler.linear(1.0),
                            style: TextStyle(
                              fontSize: 18,
                              color: ColorConstant.secondaryTextColor,
                              fontFamily: fontFamily,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Container(
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
                            children: selectedDayNewsItems?.map((newsItem) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${newsItem.fromDate} to ${newsItem.toDate}",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                ColorConstant.primaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                        Text(
                                          newsItem.subject ?? "-",
                                          textScaler:
                                              const TextScaler.linear(1.0),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: ColorConstant
                                                .secondaryTextColor,
                                            fontFamily: fontFamily,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Html(
                                          data: newsItem.message ?? "-",
                                          style: {
                                            "*": Style(
                                              fontSize: FontSize(14),
                                              color: ColorConstant
                                                  .secondaryTextColor,
                                              fontFamily: fontFamily,
                                            ),
                                          },
                                          extensions: const [
                                            TableHtmlExtension(),
                                          ],
                                        ),
                                        if (newsItem.attachment?.isNotEmpty ??
                                            false)
                                          InkWell(
                                            onTap: () {
                                              launchUrlString(
                                                  newsItem.attachment ?? "");
                                            },
                                            child: Container(
                                              margin:
                                                  const EdgeInsets.only(top: 8),
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  width: 1,
                                                  color: ColorConstant
                                                      .secondaryTextColor,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.download,
                                                color: ColorConstant
                                                    .secondaryTextColor,
                                                size: 11,
                                              ),
                                            ),
                                          ),
                                        const Divider(
                                          color:
                                              ColorConstant.secondaryTextColor,
                                          thickness: 0.3,
                                        )
                                      ],
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ),
                      )
              ],
            ),
          );
        });
  }

  String getEventHeaderString(DateTime dateTime) {
    return "${intToDayFull(dateTime.weekday)}, ${dateTime.day} ${monthIntToString(dateTime.month)} ${dateTime.year}";
  }
}
