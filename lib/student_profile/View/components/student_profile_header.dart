import 'package:flutter/material.dart';
import 'package:school_app/student_profile/Model/student_profile.dart';
import 'package:school_app/utils/components/profile_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class StudentProfileHeader extends StatelessWidget {
  final StudentProfile? studentProfile;

  const StudentProfileHeader({
    super.key,
    required this.studentProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: getWidthOfScreen(context) / 2,
          height: getWidthOfScreen(context) / 2,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorConstant.primaryColor,
            image: getProfilePicture(studentProfile?.userImage ?? ""),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          studentProfile?.studentName?.split('(').firstOrNull ??
              studentProfile?.studentName ??
              '',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: ColorConstant.primaryColor,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "${studentProfile?.className ?? ""} | Roll No. ${studentProfile?.rollNo ?? ""}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Adm No. ${studentProfile?.admissionNo ?? ""} | DOB ${studentProfile?.dob ?? ""}",
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: fontFamily,
          ),
        ),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Basic Details",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorConstant.primaryColor,
              fontFamily: fontFamily,
            ),
          ),
        ),
      ],
    );
  }
}
