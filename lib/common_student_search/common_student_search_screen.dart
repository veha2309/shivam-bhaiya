import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/student_dossier/View/student_dossier_screen.dart';
import 'package:school_app/student_dossier/ViewModel/student_dossier_view_model.dart';
import 'package:school_app/concerns/view/concerns_view.dart';
import 'package:school_app/concerns_detail/view/concerns_detail_view.dart';
import 'package:school_app/user/view/user_list_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

/// Determines which module opened the Student Search Screen.
/// Controls the title, subtitle, action button label, and destination.
enum StudentSearchMode {
  addUser,
  userProfile,
  ruleViolation,
  academicViolation,
}

extension StudentSearchModeExt on StudentSearchMode {
  String get title {
    switch (this) {
      case StudentSearchMode.addUser:
        return 'Add User';
      case StudentSearchMode.userProfile:
        return 'Student Profile';
      case StudentSearchMode.ruleViolation:
        return 'Rule Violation';
      case StudentSearchMode.academicViolation:
        return 'Academic Violation';
    }
  }

  String get subtitle {
    switch (this) {
      case StudentSearchMode.addUser:
        return 'Search and add a student user to the system';
      case StudentSearchMode.userProfile:
        return 'View and manage student profiles';
      case StudentSearchMode.ruleViolation:
        return 'Manage disciplinary rules and violations';
      case StudentSearchMode.academicViolation:
        return 'Manage academic remarks and violations';
    }
  }

  String get actionLabel {
    switch (this) {
      case StudentSearchMode.addUser:
        return 'Add User';
      case StudentSearchMode.userProfile:
        return 'View Profile';
      case StudentSearchMode.ruleViolation:
        return 'Add Violation';
      case StudentSearchMode.academicViolation:
        return 'Add Remark';
    }
  }

  IconData get headerIcon {
    switch (this) {
      case StudentSearchMode.addUser:
        return Icons.person_add_rounded;
      case StudentSearchMode.userProfile:
        return Icons.manage_accounts_rounded;
      case StudentSearchMode.ruleViolation:
        return Icons.gavel_rounded;
      case StudentSearchMode.academicViolation:
        return Icons.school_rounded;
    }
  }
}

class CommonStudentSearchScreen extends StatefulWidget {
  static const String routeName = '/common-student-search';

  final StudentSearchMode mode;
  final bool isInsideParent;

  const CommonStudentSearchScreen({
    super.key,
    required this.mode,
    this.isInsideParent = false,
  });

  @override
  State<CommonStudentSearchScreen> createState() =>
      _CommonStudentSearchScreenState();
}

class _CommonStudentSearchScreenState
    extends State<CommonStudentSearchScreen> {
  // ─── State ───────────────────────────────────────────────────────────────────
  ClassModel? selectedClass;
  Section? selectedSection;

  List<ClassModel> classes = [];
  List<Section> sections = [];
  List<StudentDossier> students = [];

  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  int _currentPage = 1;
  static const int _pageSize = 10;

  // ─── Lifecycle ───────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _loadDummyStudents();
    _loadClasses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void _loadDummyStudents() {
    students = [
      StudentDossier(studentId: '001', studentName: 'Aabhya Jain', fatherName: 'Suresh Jain', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '002', studentName: 'Aachman Singhal', fatherName: 'Rahul Singhal', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '003', studentName: 'Aadarsh Kumar Dubey', fatherName: 'Manoj Dubey', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '004', studentName: 'Aadhavan Dhankar', fatherName: 'Vikram Dhankar', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '005', studentName: 'Aadhira Tomar', fatherName: 'Ajay Tomar', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '006', studentName: 'Aadhya Agnihotri', fatherName: 'Sanjay Agnihotri', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '007', studentName: 'Aadhya Bajaj', fatherName: 'Ramesh Bajaj', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '008', studentName: 'Aadhya Chaurasia', fatherName: 'Dinesh Chaurasia', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '009', studentName: 'Aadhya Gupta', fatherName: 'Praveen Gupta', className: 'VI', sectionName: 'C'),
      StudentDossier(studentId: '010', studentName: 'Aadhyam Jain', fatherName: 'Ankit Jain', className: 'VI', sectionName: 'C'),
    ];
  }

  void _loadClasses() {
    SchoolDetailsViewModel.instance.getClassList().then((response) {
      if (response.success && mounted) {
        setState(() => classes = response.data ?? []);
      }
    });
  }

  // ─── Search ──────────────────────────────────────────────────────────────────
  void _handleSearch() {
    final name = _searchController.text.trim();
    final hasClass = selectedClass != null && selectedSection != null;
    final hasName = name.isNotEmpty;

    if (!hasClass && !hasName) {
      showSnackBarOnScreen(context, 'Please select class & section or enter a name.');
      return;
    }

    _isLoading.value = true;
    setState(() => _currentPage = 1);

    StudentDossierSearchViewModel.instance
        .getDossierAcademicDetail(
          selectedClass?.classCode ?? '-',
          selectedSection?.sectionCode ?? '-',
          '-',
          hasName ? name : '-',
        )
        .then((ApiResponse<List<StudentDossier>> response) {
      _isLoading.value = false;
      if (response.success && mounted) {
        setState(() {
          students = response.data ?? [];
          _currentPage = 1;
        });
      }
    });
  }

  // ─── Action on student card button ───────────────────────────────────────────
  void _onStudentAction(StudentDossier student) {
    switch (widget.mode) {
      case StudentSearchMode.addUser:
        // Open user switcher/add-user list so admin can assign this student
        navigateToScreen(context, const UserListScreen());
        break;

      case StudentSearchMode.userProfile:
        // Open the rich student profile / dossier screen
        navigateToScreen(context, StudentDossierScreen(studentDossier: student));
        break;

      case StudentSearchMode.ruleViolation:
        // Open the Rule Violation detail view for this specific student
        navigateToScreen(
          context,
          ConcernsDetailView(
            studentId: student.studentId ?? '',
            studentName: student.studentName,
            screenType: ConcernsViewScreenType.discipline,
            title: 'Rule Violation — ${student.studentName ?? 'Student'}',
          ),
        );
        break;

      case StudentSearchMode.academicViolation:
        // Open the Academic Violation detail view for this specific student
        navigateToScreen(
          context,
          ConcernsDetailView(
            studentId: student.studentId ?? '',
            studentName: student.studentName,
            screenType: ConcernsViewScreenType.academicDiscipline,
            title: 'Academic Violation — ${student.studentName ?? 'Student'}',
          ),
        );
        break;
    }
  }

  // ─── Pagination ───────────────────────────────────────────────────────────────
  List<StudentDossier> get _pagedStudents {
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize).clamp(0, students.length);
    if (start >= students.length) return [];
    return students.sublist(start, end);
  }

  int get _totalPages => (students.length / _pageSize).ceil().clamp(1, 99);

  // ─── Bottom sheet helpers ─────────────────────────────────────────────────────
  void _openClassSheet() {
    if (classes.isEmpty) {
      showSnackBarOnScreen(context, 'No classes available. Please wait.');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PickerSheet(
        title: 'Select Class',
        items: classes.map((c) => c.className).toList(),
        onSelect: (i) {
          final val = classes[i];
          _isLoading.value = true;
          setState(() {
            selectedClass = val;
            selectedSection = null;
            sections = [];
          });
          SchoolDetailsViewModel.instance
              .getSectionList(val.classCode)
              .then((r) {
            _isLoading.value = false;
            if (r.success && mounted) setState(() => sections = r.data ?? []);
          });
        },
      ),
    );
  }

  void _openSectionSheet() {
    if (sections.isEmpty) {
      showSnackBarOnScreen(context, 'Please select a class first.');
      return;
    }
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _PickerSheet(
        title: 'Select Section',
        items: sections.map((s) => s.sectionName).toList(),
        onSelect: (i) => setState(() => selectedSection = sections[i]),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildTopBar(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTitleSection(),
                const SizedBox(height: 24),
                _buildFilterRow(),
                const SizedBox(height: 16),
                _buildSearchBar(),
                const SizedBox(height: 24),
                if (students.isNotEmpty) ...[
                  _buildStudentList(),
                  const SizedBox(height: 24),
                  _buildPagination(),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.isInsideParent) return content;

    return AppScaffold(
      showAppBar: false,
      showDrawer: true,
      activeDrawerItem: widget.mode.title,
      isLoadingNotifier: _isLoading,
      body: content,
    );
  }

  // ─── Top bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      child: Row(
        children: [
          Builder(
            builder: (innerContext) => _iconBtn(
                Icons.menu_rounded, () => Scaffold.of(innerContext).openDrawer()),
          ),
          const Spacer(),
          Image.asset(ImageConstants.logoImagePath, height: 34),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              'Vivekanand School',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dancingScript(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const Spacer(),
          _iconBtn(Icons.home_outlined,
              () => Navigator.popUntil(context, (r) => r.isFirst)),
        ],
      ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: AppColors.primary, size: 20),
        style:
            IconButton.styleFrom(backgroundColor: AppColors.primary.withOpacity(0.06)),
      );

  // ─── Title section ────────────────────────────────────────────────────────────
  Widget _buildTitleSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(widget.mode.headerIcon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.mode.title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTeal,
                ),
              ),
              Text(
                widget.mode.subtitle,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Filter row ───────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            label: 'Class',
            icon: Icons.school_outlined,
            value: selectedClass != null ? 'Class ${selectedClass!.className}' : null,
            onTap: _openClassSheet,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _buildDropdown(
            label: 'Section',
            icon: Icons.group_outlined,
            value: selectedSection != null ? 'Section ${selectedSection!.sectionName}' : null,
            onTap: _openSectionSheet,
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          boxShadow: AppShadows.soft,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 10,
                          color: AppColors.outline,
                          fontWeight: FontWeight.w600)),
                  Text(
                    value ?? 'Select $label',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: value == null
                          ? AppColors.outlineVariant
                          : AppColors.darkTeal,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Search bar ───────────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppShadows.soft,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search student by name...',
                hintStyle:
                    GoogleFonts.inter(color: AppColors.outline, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (_) => _handleSearch(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: _handleSearch,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.filter_list_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Filter',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

  // ─── Student list ─────────────────────────────────────────────────────────────
  Widget _buildStudentList() {
    final paged = _pagedStudents;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: paged.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) {
        final offset = (_currentPage - 1) * _pageSize;
        return _buildStudentCard(paged[i], offset + i + 1);
      },
    );
  }

  Widget _buildStudentCard(StudentDossier student, int index) {
    final displayId = index.toString().padLeft(2, '0');
    // Use unique avatar per student
    final avatarUrl =
        'https://i.pravatar.cc/150?u=${student.studentId ?? index}';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadows.tight,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(avatarUrl),
            backgroundColor: AppColors.primaryContainer,
          ),
          const SizedBox(width: 10),
          // Roll number badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
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
          const SizedBox(width: 10),
          // Name & roll
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.studentName ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Roll No. $index',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Action button
          TextButton(
            onPressed: () => _onStudentAction(student),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.mode.actionLabel,
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

  // ─── Pagination ───────────────────────────────────────────────────────────────
  Widget _buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pageChip(
          child: const Icon(Icons.chevron_left_rounded, size: 20),
          active: false,
          onTap: _currentPage > 1
              ? () => setState(() => _currentPage--)
              : null,
        ),
        const SizedBox(width: 6),
        for (int p = 1; p <= _totalPages; p++) ...[
          _pageChip(
            child: Text(p.toString(),
                style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold, fontSize: 14)),
            active: p == _currentPage,
            onTap: () => setState(() => _currentPage = p),
          ),
          const SizedBox(width: 4),
        ],
        const SizedBox(width: 2),
        _pageChip(
          child: const Icon(Icons.chevron_right_rounded, size: 20),
          active: false,
          onTap: _currentPage < _totalPages
              ? () => setState(() => _currentPage++)
              : null,
        ),
      ],
    );
  }

  Widget _pageChip({
    required Widget child,
    required bool active,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppColors.primary : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: active
                ? Colors.transparent
                : AppColors.outlineVariant.withOpacity(0.5),
          ),
          boxShadow: active ? AppShadows.soft : null,
        ),
        child: IconTheme(
          data: IconThemeData(
              color: active ? Colors.white : AppColors.primary, size: 18),
          child: DefaultTextStyle(
            style: GoogleFonts.plusJakartaSans(
                color: active ? Colors.white : AppColors.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14),
            child: child,
          ),
        ),
      ),
    );
  }
}

// ─── Reusable picker bottom sheet ─────────────────────────────────────────────
class _PickerSheet extends StatelessWidget {
  final String title;
  final List<String> items;
  final ValueChanged<int> onSelect;

  const _PickerSheet({
    required this.title,
    required this.items,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(items[i],
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.chevron_right_rounded,
                    color: AppColors.outlineVariant),
                onTap: () {
                  onSelect(i);
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
