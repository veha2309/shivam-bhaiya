import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/attendance_screen/view/attendance_records_screen.dart';
import 'package:school_app/academic_records/view/academic_journey_screen.dart';
import 'package:school_app/disciplinary_records/view/disciplinary_actions_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';

class RecordsMainScreen extends StatefulWidget {
  static const String routeName = '/records-main';
  const RecordsMainScreen({super.key});

  @override
  State<RecordsMainScreen> createState() => _RecordsMainScreenState();
}

class _RecordsMainScreenState extends State<RecordsMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: false,
      body: SophisticatedHUDBackground(
        child: Column(
          children: [
            _buildCategorySelector(),
            Expanded(
              child: Material(
                color: Colors.transparent,
                child: _buildActiveScreen(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveScreen() {
    switch (_currentIndex) {
      case 0:
        return const AttendanceRecordsScreen(isInsideParent: true);
      case 1:
        return const AcademicJourneyScreen(isInsideParent: true);
      case 2:
        return const DisciplinaryActionsScreen(isInsideParent: true);
      default:
        return const AttendanceRecordsScreen(isInsideParent: true);
    }
  }

  Widget _buildCategorySelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 40, 8, 8),
      child: Row(
        children: [
          _buildCategoryItem('Attendance', 0),
          const SizedBox(width: 4),
          _buildCategoryItem('Academic', 1),
          const SizedBox(width: 4),
          _buildCategoryItem('Discipline', 2),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, int index) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _currentIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.primaryContainer.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.5)),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
