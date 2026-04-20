import 'package:flutter/material.dart';
import 'package:school_app/teacher_time_table/Model/teacher_time_table.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class TimetableGridWidget extends StatelessWidget {
  final List<DaySchedule> schedule;
  final List<String> days;
  final List<int> lectureSlots;

  const TimetableGridWidget({
    super.key,
    required this.schedule,
    this.days = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'],
    this.lectureSlots = const [
      0,
      1,
      2,
      3,
      4,
      5,
      6,
    ],
  });

  Map<String, Map<int, Lecture?>> generateDayLectureMap() {
    final map = <String, Map<int, Lecture?>>{};
    for (final day in days) {
      map[day] = {for (var slot in lectureSlots) slot: null};
    }
    for (final daySchedule in schedule) {
      final day = _resolveDayKey(daySchedule.day);
      if (day == null || !map.containsKey(day)) continue;
      for (final lecture in daySchedule.timetable ?? []) {
        final slot = _slotFromLecture(lecture);
        if (slot != null && map[day]!.containsKey(slot)) {
          map[day]![slot] = lecture;
        }
      }
    }
    return map;
  }

  int? _slotFromLecture(Lecture lecture) {
    final lectureLabel = lecture.lectureName?.trim();
    if (lectureLabel != null && lectureLabel.isNotEmpty) {
      final match = RegExp(r"\d+").firstMatch(lectureLabel);
      if (match != null) {
        final slot = int.tryParse(match.group(0)!);
        if (slot != null) {
          return slot;
        }
      }
    }
    return int.tryParse(lecture.lecture ?? "");
  }

  String? _resolveDayKey(String? rawDay) {
    if (rawDay == null) return null;
    final normalizedTarget = _normalizeDayLabel(rawDay);
    if (normalizedTarget.isEmpty) return null;
    for (final configuredDay in days) {
      if (_normalizeDayLabel(configuredDay) == normalizedTarget) {
        return configuredDay;
      }
    }
    return null;
  }

  String _normalizeDayLabel(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) return "";
    final end = trimmed.length < 3 ? trimmed.length : 3;
    return trimmed.substring(0, end);
  }

  @override
  Widget build(BuildContext context) {
    final dayLectureMap = generateDayLectureMap();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 60,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ColorConstant.primaryColor,
                    border: Border.all(color: ColorConstant.primaryColor),
                  ),
                  child: const Text(
                    'Day',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: ColorConstant.onPrimary,
                    ),
                  ),
                ),
                ...lectureSlots.map((slot) => Container(
                      width: 90,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryColor,
                        border: Border.all(color: ColorConstant.primaryColor),
                      ),
                      child: Text(
                        slot == 0 ? "Enrichment" : getOrdinalNumber(slot),
                        style: const TextStyle(
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: ColorConstant.onPrimary,
                        ),
                      ),
                    )),
              ],
            ),
            // Body rows
            ...days.map((day) {
              final lectures = dayLectureMap[day]!;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: ColorConstant.backgroundColor,
                      border: Border.all(color: ColorConstant.primaryColor),
                    ),
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontFamily: fontFamily,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                        color: ColorConstant.primaryTextColor,
                      ),
                    ),
                  ),
                  ...lectureSlots.map((slot) {
                    final lecture = lectures[slot];
                    return Container(
                      width: 90,
                      height: 60,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: ColorConstant.backgroundColor,
                        border: Border.all(color: ColorConstant.primaryColor),
                      ),
                      child: lecture == null
                          ? const SizedBox.shrink()
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  lecture.subject ?? "",
                                  style: const TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: 12,
                                    color: ColorConstant.primaryTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  lecture.className ?? "",
                                  style: const TextStyle(
                                    fontFamily: fontFamily,
                                    fontSize: 10,
                                    color: ColorConstant.secondaryTextColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                    );
                  }),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
