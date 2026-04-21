import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/teacher_time_table/Model/teacher_time_table.dart';
import 'package:school_app/teacher_time_table/ViewModel/teacher_time_table_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/timetable_grid_widget.dart';

class LoggedInTeacherTimetableScreen extends StatelessWidget {
  static const String routeName = '/logged-in-teacher-table-screen';
  final String? title;

  const LoggedInTeacherTimetableScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return TeacherTimeTableScreen(
      teacherId: AuthViewModel.instance.getLoggedInUser()?.username ?? "",
      title: title,
    );
  }
}

class TeacherTimeTableScreen extends StatefulWidget {
  static const String routeName = '/teacher-time-table-screen';

  final String teacherId;
  final String? title;

  const TeacherTimeTableScreen({
    super.key,
    required this.teacherId,
    this.title,
  });

  @override
  State<TeacherTimeTableScreen> createState() => _TeacherTimeTableScreenState();
}

class _TeacherTimeTableScreenState extends State<TeacherTimeTableScreen> {
  int day = 1;
  Future<ApiResponse<TeacherTimetableModel>>? getTeacherTimeTableFuture;
  TeacherTimetableModel? teacherTimetableModel;
  DateTime? currentTime;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    currentTime = DateTime.now();
    int currentWeekday = currentTime!.weekday;
    if (currentWeekday == DateTime.sunday) {
      currentTime!.subtract(const Duration(days: 1));
      day = 5; // Default to Monday if it's Saturday or Sunday
    } else {
      day = currentWeekday - 1;
    }
    getTeacherTimeTableFuture = TeacherTimeTableViewModel.instance
        .getTeacherTimeTableDetails(widget.teacherId)
        .then((response) {
      if (response.success) {
        teacherTimetableModel = response.data;
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "My Timetable",
        body: studentTimeTableBody(context),
      ),
    );
  }

  Widget studentTimeTableBody(BuildContext context) {
    return AppFutureBuilder(
        future: getTeacherTimeTableFuture,
        builder: (context, snapshot) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                spacing: 16.0,
                children: [
                  if (teacherTimetableModel?.schedule?.isNotEmpty ?? false)
                    TimetableGridWidget(
                      schedule: teacherTimetableModel!.schedule ?? [],
                    ),
                ],
              ),
            ),
          );
        });
  }
}
