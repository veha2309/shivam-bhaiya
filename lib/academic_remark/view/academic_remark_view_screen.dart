import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/academic_remark/view/academic_remark_entry_screen.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/search_student_profile/ViewModel/search_student_profile_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/utils.dart';

class AcademicRemarkViewScreen extends StatefulWidget {
  static const String routeName = '/academic-remark-view';
  final String? title;
  const AcademicRemarkViewScreen({super.key, this.title});

  @override
  State<AcademicRemarkViewScreen> createState() =>
      _AcademicRemarkViewScreenState();
}

class _AcademicRemarkViewScreenState extends State<AcademicRemarkViewScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  final TextEditingController studentNameController = TextEditingController();
  ClassModel? selectedClass;
  Section? selectedSection;

  // Add set for selected students
  Set<String> selectedStudents = {};

  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  Future<ApiResponse<List<SearchStudentModel>>>? getStudentListFuture;

  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<SearchStudentModel> students = [];

  @override
  void initState() {
    super.initState();
    getClassListFuture = SchoolDetailsViewModel.instance
        .getClassList()
        .then((ApiResponse<List<ClassModel>> response) {
      if (response.success) {
        classes = response.data ?? [];
      }
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? 'View Academic Remarks',
        body: academicRemarkBody(context),
      ),
    );
  }

  Widget academicRemarkBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 16,
          children: [
            AppTextfield(
              onTap: () => openClassBottomSheet(context, classes, (value) {
                isLoadingNotifier.value = true;
                studentNameController.clear();
                setState(() {
                  selectedClass = value;
                  selectedSection = null;
                  getSectionListFuture = SchoolDetailsViewModel.instance
                      .getSectionList(value.classCode)
                      .then((ApiResponse<List<Section>> response) {
                    isLoadingNotifier.value = false;
                    if (response.success) {
                      sections = response.data ?? [];
                    }
                    return response;
                  });
                });
              }),
              hintText: selectedClass?.className ?? 'Select Class',
            ),
            AppTextfield(
              onTap: () => openSectionBottomSheet(context, sections, (value) {
                studentNameController.clear();
                setState(() {
                  selectedSection = value;
                });
              }),
              hintText: selectedSection?.sectionName ?? 'Select Section',
            ),
            const Text(
              "OR",
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(
                fontSize: 16,
                fontFamily: fontFamily,
                color: ColorConstant.inactiveColor,
              ),
            ),
            AppTextfield(
              controller: studentNameController,
              hintText: "Student Name",
              enabled: true,
            ),
            AppButton(
              onPressed: (_) {
                isLoadingNotifier.value = true;

                if (selectedClass == null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(context,
                      "Please select class, section, or search via name.");
                  return;
                }

                if (selectedClass != null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(
                      context, "Please select section to search.");
                  return;
                }

                if (selectedClass != null &&
                    selectedSection == null &&
                    studentNameController.text.trim().isNotEmpty) {
                  isLoadingNotifier.value = false;
                  showSnackBarOnScreen(context,
                      "Please select section or search via name only.");
                  return;
                }

                if (selectedClass != null && selectedSection != null) {
                  getStudentListFuture = SearchStudentProfileViewModel.instance
                      .searchStudentListForStudentProfile(
                          selectedClass!.classCode,
                          selectedSection!.sectionCode,
                          "-")
                      .then((ApiResponse<List<SearchStudentModel>> response) {
                    isLoadingNotifier.value = false;
                    if (response.success) {
                      setState(() {
                        students = response.data ?? [];
                      });
                    }
                    return response;
                  });
                } else {
                  getStudentListFuture = SearchStudentProfileViewModel.instance
                      .searchStudentListForStudentProfile(
                    "",
                    "",
                    studentNameController.text,
                  )
                      .then((ApiResponse<List<SearchStudentModel>> response) {
                    isLoadingNotifier.value = false;
                    if (response.success) {
                      setState(() {
                        students = response.data ?? [];
                      });
                    }
                    return response;
                  });
                }
              },
              text: "Search",
            ),
            if (students.isNotEmpty)
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: students.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildStudentCard(students[index]);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(SearchStudentModel student) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadows.tight,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=student'),
          ),
          const SizedBox(width: 12),
          if (student.admissionNo != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                student.admissionNo!,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.primary,
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  student.className ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              navigateToScreen(
                context,
                AcademicRemarkEntryScreen(
                  students: [student],
                  classCode: selectedClass?.classCode,
                  sectionCode: selectedSection?.sectionCode,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Remark',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_rounded, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    studentNameController.dispose();
    super.dispose();
  }
}
