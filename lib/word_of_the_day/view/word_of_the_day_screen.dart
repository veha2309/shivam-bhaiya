import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';
import 'package:school_app/word_of_the_day/model/word_of_the_day.dart';
import 'package:school_app/word_of_the_day/viewmodel/word_of_the_day_viewmodel.dart';

class WordOfTheDayScreen extends StatefulWidget {
  static const String routeName = '/word-of-the-day';
  final String? title;
  const WordOfTheDayScreen({super.key, this.title});

  @override
  State<WordOfTheDayScreen> createState() => WordOfTheDayScreenState();
}

class WordOfTheDayScreenState extends State<WordOfTheDayScreen> {
  ValueNotifier<DateTime> selectedDate = ValueNotifier(DateTime.now());
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<List<WordOfTheDayModel>>>? getWordOfTheDayFuture;
  List<WordOfTheDayModel>? wordOfTheDayModel;
  Set<String> datesHavingEvents = {};
  Map<String, WordOfTheDayModel> eventMap = {};

  @override
  void initState() {
    super.initState();
    getWordOfTheDayFuture =
        WordOfTheDayViewmodel.instance.getWordOfTheDay().then((response) {
      if (response.success) {
        wordOfTheDayModel = response.data!;
        for (var element in wordOfTheDayModel!) {
          datesHavingEvents.add(element.messageDate ?? "");
          eventMap[element.messageDate ?? ""] = element;
        }
      }
      return response;
    });
  }

  String formatDateTime(DateTime dateTime) {
    return DateFormat("MMM d, y").format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: widget.title ?? "Word of the Day",
          body: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              child: AppFutureBuilder(
                future: getWordOfTheDayFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: getLoaderWidget());
                  } else if (snapshot.hasError) {
                    return SizedBox(
                      child: Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          textScaler: const TextScaler.linear(1.0),
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.hasData) {
                    return newsEventBody(context);
                  } else {
                    return const SizedBox();
                  }
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
              height: 350,
              child: ValueListenableBuilder(
                  valueListenable: selectedDate,
                  builder: (context, _, __) {
                    return MonthView(
                      key: monthViewKey,
                      onPageChange: (date, page) {},
                      useAvailableVerticalSpace: true,
                      hideDaysNotInMonth: true,
                      showBorder: false,
                      cellBuilder: (date, event, isToday, isInMonth,
                          hideDaysNotInMonth) {
                        bool isSelected = checkSelectedDay(date);
                        bool containsEvent =
                            datesHavingEvents.contains(formatDateTime(date));
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
                                      ? ColorConstant.secondaryColor
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
                            if (containsEvent)
                              Align(
                                alignment: Alignment.topRight,
                                child: Container(
                                  margin:
                                      const EdgeInsets.only(top: 10, right: 10),
                                  height: 10,
                                  width: 10,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ColorConstant.secondaryColor,
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
          WordOfTheDayModel? newsItem = eventMap[formatDateTime(state)];
          return SizedBox(
            child: Column(
              children: newsItem != null
                  ? [
                      Text(
                        "\"${newsItem.message}\"",
                        maxLines: 3,
                        textScaler: const TextScaler.linear(1.0),
                        style: const TextStyle(
                          fontSize: 22,
                          overflow: TextOverflow.ellipsis,
                          color: ColorConstant.secondaryTextColor,
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        ImageConstants.wordOfTheDay,
                        height: 200,
                        width: 200,
                      ),
                    ]
                  : [
                      const Text(
                        "No message for the day",
                        textScaler: TextScaler.linear(1.0),
                        style: TextStyle(
                          fontSize: 20,
                          color: ColorConstant.secondaryTextColor,
                          fontFamily: fontFamily,
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
