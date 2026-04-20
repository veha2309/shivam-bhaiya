import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class SchoolCalendarScreen extends StatefulWidget {
  static const String routeName = '/school-calendar';
  final String? title;
  const SchoolCalendarScreen({super.key, this.title});

  @override
  State<SchoolCalendarScreen> createState() => _SchoolCalendarScreenState();
}

final class _SchoolCalendarScreenState extends State<SchoolCalendarScreen> {
  GlobalKey<MonthViewState> monthViewKey = GlobalKey<MonthViewState>();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return CalendarControllerProvider(
      controller: EventController(),
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        body: AppBody(
          title: widget.title ?? "School Calendar",
          body: getSchoolCalendarBody(),
        ),
      ),
    );
  }

  Widget getSchoolCalendarBody() {
    return Column(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: MonthView(
              key: monthViewKey,
              hideDaysNotInMonth: true,
              cellBuilder:
                  (date, event, isToday, isInMonth, hideDaysNotInMonth) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ColorConstant.primaryColor,
                    ),
                    color: isToday ? ColorConstant.primaryColor : Colors.white,
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          date.day.toString(),
                          textScaler: const TextScaler.linear(1.0),
                          style: TextStyle(
                            color: isToday
                                ? ColorConstant.primaryColor
                                : ColorConstant.primaryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (date.day % 3 == 0)
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: ColorConstant.primaryColor,
                            ),
                            child: const Text(
                              "Event",
                              textScaler: TextScaler.linear(1.0),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                fontFamily: fontFamily,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
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
                          child: const Icon(CupertinoIcons.chevron_left),
                        ),
                        Container(
                          decoration: const BoxDecoration(),
                          child: Center(
                            child: Text(
                              "${monthIntToString(date.month)} ${date.year}",
                              textScaler: TextScaler.linear(1.0),
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
                          child: const Icon(CupertinoIcons.chevron_right),
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
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      intToWeekDay(day),
                      textScaler: TextScaler.linear(1.0),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ),
                );
              },
              borderColor: ColorConstant.primaryColor,
              onCellTap: (events, date) {
                showAdaptiveDialog(
                  context: context,
                  useSafeArea: true,
                  builder: (context) => Dialog(
                    child: Container(
                      decoration: const BoxDecoration(color: Colors.white),
                      height: 500,
                      width: 200,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
