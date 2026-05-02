import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/admin_dashboard/view/components/admin_drawer.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';
import 'package:school_app/student_dossier/View/student_dossier_screen.dart';
import 'package:school_app/student_profile/View/student_profile_screen.dart';
import 'package:school_app/utils/utils.dart';

class AdminStudentProfileScreen extends StatefulWidget {
  static const String routeName = '/admin-student-profile';
  final bool isInsideParent;
  const AdminStudentProfileScreen({super.key, this.isInsideParent = false});

  @override
  State<AdminStudentProfileScreen> createState() => _AdminStudentProfileScreenState();
}

class _AdminStudentProfileScreenState extends State<AdminStudentProfileScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? selectedClass = 'VI - C';
  String? selectedSection = 'A';

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
                _buildStudentList(),
                const SizedBox(height: 24),
                _buildPagination(),
                const SizedBox(height: 100), // Extra space for bottom nav
              ],
            ),
          ),
        ),
      ],
    );

    if (widget.isInsideParent) return content;

    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: const AdminDrawer(),
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
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.05),
            ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(ImageConstants.logoImagePath, height: 40),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Vivekanand School',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dancingScript(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!widget.isInsideParent)
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.home_outlined, color: AppColors.primary),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.05),
              ),
            )
          else
            const SizedBox(width: 48), // Placeholder to keep center alignment
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.school_outlined, color: AppColors.primary, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Student Profile',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkTeal,
                ),
              ),
              Text(
                'View and manage student profiles',
                style: GoogleFonts.inter(
                  fontSize: 14,
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

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdownField('Class', selectedClass, ['VI - C', 'VII - A', 'VIII - B']),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildDropdownField('Section', selectedSection, ['A', 'B', 'C']),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items) {
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
            boxShadow: AppShadows.soft,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primary),
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  if (label == 'Class') selectedClass = val;
                  else selectedSection = val;
                });
              },
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search student by name...',
                hintStyle: GoogleFonts.inter(color: AppColors.outline, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: AppColors.outline),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
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
      ],
    );
  }

  Widget _buildStudentList() {
    final List<Map<String, String>> mockStudents = [
      {'name': 'Aabhya Jain', 'roll': '1', 'id': '01'},
      {'name': 'Aachman Singhal', 'roll': '2', 'id': '02'},
      {'name': 'Aadarsh Kumar Dubey', 'roll': '3', 'id': '03'},
      {'name': 'Aadharvan Dhankar', 'roll': '4', 'id': '04'},
      {'name': 'Aadhira Tomar', 'roll': '5', 'id': '05'},
      {'name': 'Aadhya Agnihotri', 'roll': '6', 'id': '06'},
      {'name': 'Aadhya Bajaj', 'roll': '7', 'id': '07'},
      {'name': 'Aadhya Chaurasia', 'roll': '8', 'id': '08'},
      {'name': 'Aadhya Gupta', 'roll': '9', 'id': '09'},
      {'name': 'Aadhyam Jain', 'roll': '10', 'id': '10'},
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mockStudents.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final student = mockStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, String> student) {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              student['id']!,
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
                  student['name']!,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  'Roll No. ${student['roll']}',
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
              final dossier = StudentDossier(
                studentId: student['id'],
                studentName: student['name'],
              );
              navigateToScreen(context, StudentDossierScreen(studentDossier: dossier));
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View Dossier',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
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
}
