import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/academic_card/view/academic_card_entry_screen.dart';
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
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/utils.dart';

enum AcademicNavigationType { remark, card }

class AcademicRemarkSearchScreen extends StatefulWidget {
  static const String routeName = '/academic-remark';
  final String? title;
  final AcademicNavigationType navigationType;

  const AcademicRemarkSearchScreen({
    super.key,
    this.title,
    this.navigationType = AcademicNavigationType.remark,
  });

  @override
  State<AcademicRemarkSearchScreen> createState() =>
      _AcademicRemarkSearchScreenState();
}

class _AcademicRemarkSearchScreenState
    extends State<AcademicRemarkSearchScreen> {
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
    final content = Column(
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                const SizedBox(height: 24),
                _buildFilterRow(),
                const SizedBox(height: 20),
                _buildSearchBar(),
                const SizedBox(height: 24),
                if (students.isNotEmpty) _buildStudentList(),
                if (students.isNotEmpty) const SizedBox(height: 24),
                if (students.isNotEmpty) _buildPagination(),
                if (selectedStudents.isNotEmpty) _buildSelectionActions(),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );

    return AppScaffold(
      showAppBar: false,
      showDrawer: false,
      isLoadingNotifier: isLoadingNotifier,
      body: SafeArea(child: content),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          ),
          Row(
            children: [
              Image.asset(ImageConstants.logoImagePath, height: 40),
              const SizedBox(width: 8),
              Text(
                'Vivekanand School',
                style: GoogleFonts.dancingScript(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            icon: const Icon(Icons.home_outlined, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.navigationType == AcademicNavigationType.remark ? 'Academic Remarks' : 'Academic Cards',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTeal,
          ),
        ),
        Text(
          widget.navigationType == AcademicNavigationType.remark 
              ? 'Add academic remarks for students'
              : 'Add academic cards for students',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.outline,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField('Class', selectedClass?.className, classes),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdownField('Section', selectedSection?.sectionName, sections),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.outline,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            if (label == 'Class') {
              openClassBottomSheet(context, classes, (val) {
                isLoadingNotifier.value = true;
                setState(() {
                  selectedClass = val;
                  selectedSection = null;
                  getSectionListFuture = SchoolDetailsViewModel.instance
                      .getSectionList(val.classCode)
                      .then((ApiResponse<List<Section>> response) {
                    isLoadingNotifier.value = false;
                    if (response.success) {
                      sections = response.data ?? [];
                    }
                    return response;
                  });
                });
              });
            } else {
              openSectionBottomSheet(context, sections, (val) {
                setState(() => selectedSection = val);
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value ?? 'Select $label',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: value == null ? AppColors.outline : AppColors.onSurface,
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadows.soft,
            ),
            child: TextField(
              controller: studentNameController,
              decoration: InputDecoration(
                hintText: 'Search student by name...',
                hintStyle: GoogleFonts.inter(color: AppColors.outline, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _handleSearch,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.filter_list_rounded, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _handleSearch() {
    isLoadingNotifier.value = true;
    if (selectedClass != null && selectedSection != null) {
      _performSearch(selectedClass!.classCode, selectedSection!.sectionCode, "-");
    } else if (studentNameController.text.trim().isNotEmpty) {
      _performSearch("", "", studentNameController.text.trim());
    } else {
      isLoadingNotifier.value = false;
      showSnackBarOnScreen(context, "Please select class & section or enter a name.");
    }
  }

  void _performSearch(String classCode, String sectionCode, String name) {
    SearchStudentProfileViewModel.instance
        .searchStudentListForStudentProfile(classCode, sectionCode, name)
        .then((ApiResponse<List<SearchStudentModel>> response) {
      isLoadingNotifier.value = false;
      if (response.success) {
        setState(() => students = response.data ?? []);
      }
    });
  }

  Widget _buildStudentList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildStudentCard(students[index], index + 1);
      },
    );
  }

  Widget _buildStudentCard(SearchStudentModel student, int index) {
    final displayId = index.toString().padLeft(2, '0');
    final isSelected = selectedStudents.contains(student.studentId);

    return InkWell(
      onLongPress: () {
        setState(() {
          if (isSelected) selectedStudents.remove(student.studentId!);
          else selectedStudents.add(student.studentId!);
        });
      },
      onTap: () {
        if (selectedStudents.isNotEmpty) {
          setState(() {
            if (isSelected) selectedStudents.remove(student.studentId!);
            else selectedStudents.add(student.studentId!);
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.tight,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=student'),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                displayId,
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
                    'Adm No. ${student.admissionNo ?? 'N/A'}',
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
                _navigateToEntry([student]);
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
                    widget.navigationType == AcademicNavigationType.remark ? 'Add Remark' : 'Add Card',
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
      ),
    );
  }

  void _navigateToEntry(List<SearchStudentModel> selectedList) {
    navigateToScreen(
      context,
      widget.navigationType == AcademicNavigationType.remark
          ? AcademicRemarkEntryScreen(
              classCode: selectedClass?.classCode,
              sectionCode: selectedSection?.sectionCode,
              students: selectedList,
            )
          : AcademicCardEntryScreen(
              students: selectedList,
              classCode: selectedClass?.classCode ?? "",
              sectionCode: selectedSection?.sectionCode ?? "",
            ),
    );
  }

  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPageButton(Icons.chevron_left_rounded, false),
        const SizedBox(width: 8),
        _buildPageNumber(1, true),
        _buildPageNumber(2, false),
        _buildPageNumber(3, false),
        const SizedBox(width: 8),
        _buildPageButton(Icons.chevron_right_rounded, false),
      ],
    );
  }

  Widget _buildPageButton(IconData icon, bool isActive) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
      ),
      child: Icon(icon, color: isActive ? Colors.white : AppColors.primary, size: 20),
    );
  }

  Widget _buildPageNumber(int number, bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isActive ? Colors.transparent : AppColors.outlineVariant.withOpacity(0.5)),
      ),
      alignment: Alignment.center,
      child: Text(
        number.toString(),
        style: GoogleFonts.plusJakartaSans(
          color: isActive ? Colors.white : AppColors.onSurface,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildSelectionActions() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onPressed: (_) => setState(() => selectedStudents.clear()),
              text: "Cancel",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              onPressed: (_) {
                _navigateToEntry(students.where((s) => selectedStudents.contains(s.studentId)).toList());
              },
              text: "Next",
            ),
          ),
        ],
      ),
    );
  }

  void openClassBottomSheet(BuildContext context, List<ClassModel> items, Function(ClassModel) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Class', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].className),
                    onTap: () {
                      onSelect(items[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void openSectionBottomSheet(BuildContext context, List<Section> items, Function(Section) onSelect) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select Section', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].sectionName),
                    onTap: () {
                      onSelect(items[index]);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    studentNameController.dispose();
    super.dispose();
  }
}
