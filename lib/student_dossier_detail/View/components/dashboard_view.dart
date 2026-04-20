import 'package:flutter/material.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/student_dossier_detail/Model/student_dashboard_model.dart';
import 'package:school_app/student_dossier_detail/ViewModel/student_dossier_detail_view_model.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/profile_widget.dart';
import 'package:school_app/utils/constants.dart';

class DashboardView extends StatefulWidget {
  final String studentId;

  const DashboardView({super.key, required this.studentId});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  Future<ApiResponse<StudentDashboardModel>>? getStudentDossierDashboardDetails;
  StudentDashboardModel? studentDashboardModel;

  @override
  void initState() {
    super.initState();
    callDossierDashboardViewAcademicDetailFuture();
  }

  @override
  void didUpdateWidget(DashboardView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void callDossierDashboardViewAcademicDetailFuture() {
    setState(
      () {
        getStudentDossierDashboardDetails = StudentDossierDetailViewModel
            .instance
            .getStudentDossierDashboardDetails(studentId: widget.studentId)
            .then(
          (response) {
            if (response.success) {
              studentDashboardModel = response.data;
            }
            return response;
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppFutureBuilder(
      future: getStudentDossierDashboardDetails,
      builder: (context, snapshot) {
        return SingleChildScrollView(
            scrollDirection: Axis.horizontal, child: getStudentDetailsList());
      },
    );
  }

  Widget getStudentDetailsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        getStudentDetailCard(),
        const Divider(
          thickness: 0.1,
        ),
        getParentDetailCard(),
      ],
    );
  }

  Widget getStudentDetailCard() {
    return SizedBox(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 10,
        children: [
          SizedBox(
            width: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 90,
                  width: 70,
                  decoration: BoxDecoration(
                      image: getProfilePicture(
                          studentDashboardModel?.studentImage ?? ""),
                      color: ColorConstant.primaryColor,
                      borderRadius: const BorderRadius.all(Radius.circular(8))),
                ),
                const Text(
                  "Student",
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                    color: ColorConstant.primaryColor,
                    fontSize: 14,
                    fontFamily: fontFamily,
                  ),
                ),
                Text(
                  studentDashboardModel?.studentName ?? "",
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    color: ColorConstant.primaryColor,
                    fontSize: 11,
                    fontFamily: fontFamily,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Student ID: ${studentDashboardModel?.studentId ?? ""}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: fontFamily,
                ),
              ),
              Text(
                "Admission No: ${studentDashboardModel?.admissionNo ?? ""}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: fontFamily,
                ),
              ),
              Text(
                "Date Of Birth: ${studentDashboardModel?.dob ?? ""}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: fontFamily,
                ),
              ),
              Text(
                "Class/Section: ${studentDashboardModel?.className ?? ""}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: fontFamily,
                ),
              ),
              Text(
                "Date of Admision: ${studentDashboardModel?.doa ?? ""}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: fontFamily,
                ),
              ),
              Text(
                "Route No: ${studentDashboardModel?.routeName ?? ""}",
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: fontFamily,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget getParentDetailCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      width: 70,
                      decoration: BoxDecoration(
                          color: ColorConstant.primaryColor,
                          image: getProfilePicture(
                              studentDashboardModel?.fatherImage ?? ""),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(8))),
                    ),
                    const Text(
                      "Father",
                      textScaler: TextScaler.linear(1.0),
                      style: TextStyle(
                        color: ColorConstant.primaryColor,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    Text(
                      "Mr. ${studentDashboardModel?.fatherName}",
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 3,
                      style: const TextStyle(
                        color: ColorConstant.primaryColor,
                        fontSize: 11,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mobile No: ${studentDashboardModel?.fMobileNo ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Email ID: ${studentDashboardModel?.fEmail ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Religion: ${studentDashboardModel?.fReligion ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Category: ${studentDashboardModel?.fCaste ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Contact No: ${studentDashboardModel?.fContactNo ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(
          thickness: 0.1,
        ),
        SizedBox(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              SizedBox(
                width: 110,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 90,
                      width: 70,
                      decoration: BoxDecoration(
                        color: ColorConstant.primaryColor,
                        image: getProfilePicture(
                            studentDashboardModel?.motherImage ?? ""),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(8),
                        ),
                      ),
                    ),
                    const Text(
                      "Mother",
                      textScaler: TextScaler.linear(1.0),
                      style: TextStyle(
                        color: ColorConstant.primaryColor,
                        fontSize: 14,
                        fontFamily: fontFamily,
                      ),
                    ),
                    Text(
                      "Mrs. ${studentDashboardModel?.motherName}",
                      textScaler: const TextScaler.linear(1.0),
                      maxLines: 3,
                      style: const TextStyle(
                        color: ColorConstant.primaryColor,
                        fontSize: 11,
                        fontFamily: fontFamily,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Mobile No: ${studentDashboardModel?.mMobileNo ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Email ID: ${studentDashboardModel?.mEmailId ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Religion: ${studentDashboardModel?.mReligion ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Category: ${studentDashboardModel?.mCaste ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                  Text(
                    "Contact No: ${studentDashboardModel?.mContactNo ?? ""}",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: fontFamily,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        const Divider(
          thickness: 0.1,
        ),
      ],
    );
  }
}
