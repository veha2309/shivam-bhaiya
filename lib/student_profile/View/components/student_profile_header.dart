import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
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
        Stack(
          alignment: Alignment.bottomRight,
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
            PopupMenuButton<String>(
              position: PopupMenuPosition.under,
              color: Colors.white.withOpacity(0.95),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              onSelected: (value) async {
                if (value == 'library') {
                  final ImagePicker picker = ImagePicker();
                  await picker.pickImage(source: ImageSource.gallery);
                } else if (value == 'camera') {
                  final ImagePicker picker = ImagePicker();
                  await picker.pickImage(source: ImageSource.camera);
                } else if (value == 'file') {
                  await FilePicker.platform.pickFiles();
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'library',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.photo_on_rectangle, color: Colors.black87, size: 22),
                      SizedBox(width: 12),
                      Text('Photo Library', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'camera',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.camera, color: Colors.black87, size: 22),
                      SizedBox(width: 12),
                      Text('Take Photo', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'file',
                  child: Row(
                    children: [
                      Icon(CupertinoIcons.folder, color: Colors.black87, size: 22),
                      SizedBox(width: 12),
                      Text('Choose File', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w500, fontFamily: fontFamily)),
                    ],
                  ),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 8, bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstant.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
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
