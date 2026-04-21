import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/student_profile/Model/student_profile.dart';
import 'package:school_app/student_profile/View/components/student_profile_header.dart';
import 'package:school_app/student_profile/ViewModel/student_profile_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

class StudentProfileScreen extends StatefulWidget {
  static const String routeName = '/student-profile';
  final String studentId;

  const StudentProfileScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<StudentProfile>>? getStudentProfileDetailsFuture;
  StudentProfile? studentProfile;

  @override
  void initState() {
    super.initState();
    getStudentProfileDetailsFuture = StudentProfileDetailViewModel.instance
        .getStudentProfileDetails(widget.studentId)
        .then((ApiResponse<StudentProfile> response) {
      if (response.success) {
        studentProfile = response.data;
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: "Student's Profile",
        body: AppFutureBuilder(
          future: getStudentProfileDetailsFuture,
          builder: (context, snapshot) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  StudentProfileHeader(studentProfile: studentProfile),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TableWidget(rows: rows),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<TableRowConfiguration> get rows => [
        TableRowConfiguration(rowHeight: 45, cells: [
          TableCellConfiguration(
              text: "Teacher's Name",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              text: studentProfile?.teacherName ?? '',
              padding: const EdgeInsets.only(left: 10.0))
        ]),
        TableRowConfiguration(rowHeight: 45, cells: [
          TableCellConfiguration(
              text: "Father's Name",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              text: "Mr. ${studentProfile?.fatherName ?? ''}",
              padding: const EdgeInsets.only(left: 10.0))
        ]),
        TableRowConfiguration(rowHeight: 45, cells: [
          TableCellConfiguration(
              text: "Father's Phone No.",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              text: studentProfile?.fmobileno ?? '',
              padding: const EdgeInsets.only(left: 10.0))
        ]),
        TableRowConfiguration(rowHeight: 45, cells: [
          TableCellConfiguration(
              text: "Mother's Name",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              text: "Mrs. ${studentProfile?.motherName ?? ''}",
              padding: const EdgeInsets.only(left: 10.0))
        ]),
        TableRowConfiguration(rowHeight: 45, cells: [
          TableCellConfiguration(
              text: "Mother's Phone No.",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              text: studentProfile?.mmobileno ?? '',
              padding: const EdgeInsets.only(left: 10.0))
        ]),
        TableRowConfiguration(cells: [
          TableCellConfiguration(
              height: 45,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Address",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    textAlign: TextAlign.left,
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: fontFamily,
                      color: ColorConstant.inactiveColor,
                    ),
                  ),
                ],
              ),
              // text: "Address",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              // text: studentProfile?.address ?? '',
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text(
                  studentProfile?.address ?? '',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 6,
                  textAlign: TextAlign.left,
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: fontFamily,
                    color: ColorConstant.inactiveColor,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: 10.0)),
        ]),
        TableRowConfiguration(cells: [
          TableCellConfiguration(
              height: 45,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Mode of Transport",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 5,
                    textAlign: TextAlign.left,
                    textScaler: TextScaler.linear(1.0),
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: fontFamily,
                      color: ColorConstant.inactiveColor,
                    ),
                  ),
                ],
              ),
              // text: "Address",
              padding: const EdgeInsets.only(left: 10.0)),
          TableCellConfiguration(
              // text: studentProfile?.address ?? '',
              child: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text(
                  studentProfile?.routeName ?? '--',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 6,
                  textAlign: TextAlign.left,
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: fontFamily,
                    color: ColorConstant.inactiveColor,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(left: 10.0)),
        ]),
      ];
}
