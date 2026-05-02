import 'package:flutter/material.dart';
import 'package:school_app/discipline/model/student_discipline_model.dart';
import 'package:school_app/discipline/view/raise_discipline_entry_screen.dart';
import 'package:school_app/discipline/viewmodel/discipline_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class RaiseDisciplineSearchScreen extends StatefulWidget {
  static const String routeName = '/raise-discipline-search';
  final String? title;
  const RaiseDisciplineSearchScreen({super.key, this.title});

  @override
  State<RaiseDisciplineSearchScreen> createState() =>
      _RaiseDisciplineSearchScreenState();
}

class _RaiseDisciplineSearchScreenState
    extends State<RaiseDisciplineSearchScreen> {
  Future<ApiResponse<List<ClassModel>>>? getClassListFuture;
  Future<ApiResponse<List<Section>>>? getSectionListFuture;
  ValueNotifier<bool> showCheckBox = ValueNotifier(false);
  List<StudentDisciplineModel> studentDisciplineList = [];
  bool checkBoxSelected = false;
  Set<String> selectedStudent = {};

  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

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
  void dispose() {
    super.dispose();
  }

  ClassModel? selectedClass;
  Section? selectedSection;

  List<ClassModel> classes = [];
  List<Section> sections = [];

  void checkIfAllFieldsAreFilled() {
    if (selectedClass != null && selectedSection != null) {
      showCheckBox.value = true;
    } else {
      showCheckBox.value = false;
    }
  }

  final TextEditingController studentNameController = TextEditingController();

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
                const SizedBox(height: 20),
                _buildDefaulterToggle(),
                const SizedBox(height: 24),
                if (studentDisciplineList.isNotEmpty && !checkBoxSelected) _buildStudentList(),
                if (studentDisciplineList.isNotEmpty && !checkBoxSelected) const SizedBox(height: 24),
                if (studentDisciplineList.isNotEmpty && !checkBoxSelected) _buildPagination(),
                if (selectedStudent.isNotEmpty) _buildSelectionActions(),
                if (checkBoxSelected) _buildSubmitButton(),
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
          'Raise Discipline',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.darkTeal,
          ),
        ),
        Text(
          'Select students to report disciplinary actions',
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
                  checkIfAllFieldsAreFilled();
                });
              });
            } else {
              openSectionBottomSheet(context, sections, (val) {
                setState(() {
                  selectedSection = val;
                  checkIfAllFieldsAreFilled();
                });
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

  Widget _buildDefaulterToggle() {
    return ValueListenableBuilder<bool>(
      valueListenable: showCheckBox,
      builder: (context, value, child) {
        if (!value) return const SizedBox();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: checkBoxSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: checkBoxSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Checkbox(
                value: checkBoxSelected,
                checkColor: Colors.white,
                activeColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: (val) => setState(() => checkBoxSelected = val ?? false),
              ),
              Text(
                'There is no defaulter today',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: checkBoxSelected ? AppColors.primary : AppColors.outline,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleSearch() {
    if (selectedClass == null || selectedSection == null) {
      showSnackBarOnScreen(context, "Please select class and section first.");
      return;
    }
    isLoadingNotifier.value = true;
    DisciplineViewModel.instance
        .searchStudentDisplineList(selectedSection!.sectionCode, DateTime.now())
        .then((response) {
      isLoadingNotifier.value = false;
      if (response.success) {
        setState(() => studentDisciplineList = response.data?.studentData ?? []);
      }
    });
  }

  Widget _buildStudentList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: studentDisciplineList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildStudentCard(studentDisciplineList[index], index + 1);
      },
    );
  }

  Widget _buildStudentCard(StudentDisciplineModel student, int index) {
    final displayId = index.toString().padLeft(2, '0');
    final isSelected = selectedStudent.contains(student.studentId);

    return InkWell(
      onLongPress: () {
        setState(() {
          if (isSelected) selectedStudent.remove(student.studentId!);
          else selectedStudent.add(student.studentId!);
        });
      },
      onTap: () {
        if (selectedStudent.isNotEmpty) {
          setState(() {
            if (isSelected) selectedStudent.remove(student.studentId!);
            else selectedStudent.add(student.studentId!);
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
                    student.studentName ?? '',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'ID: ${student.studentId ?? 'N/A'}',
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
                    'Report',
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

  void _navigateToEntry(List<StudentDisciplineModel> selectedList) {
    navigateToScreen(
      context,
      RaiseDisciplineEntryScreen(
        students: selectedList,
        isForEntry: true,
        classModel: selectedClass!,
        section: selectedSection!,
        disciplineDate: DateTime.now(),
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
              onPressed: (_) => setState(() => selectedStudent.clear()),
              text: "Cancel",
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AppButton(
              onPressed: (_) {
                _navigateToEntry(studentDisciplineList.where((s) => selectedStudent.contains(s.studentId)).toList());
              },
              text: "Next",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: AppButton(
        onPressed: (isLoading) async {
          if (selectedSection == null) return;
          isLoading.value = true;
          var response = await DisciplineViewModel.instance.markNoDefaults(selectedSection!.sectionCode, DateTime.now());
          isLoading.value = false;
          if (response.success) {
            Navigator.pop(context);
            showSnackBarOnScreen(context, "No defaulter marked successfully");
          } else {
            showSnackBarOnScreen(context, "An error occurred");
          }
        },
        text: "Submit No Defaulters",
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
}
