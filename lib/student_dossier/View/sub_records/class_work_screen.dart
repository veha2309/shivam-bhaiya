import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class ClassWorkScreen extends StatelessWidget {
  static const String routeName = '/class-work';
  const ClassWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      appBarTitle: Text("Class Work And Assignments", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
      body: SophisticatedHUDBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildAssignmentTile('Mathematics', 'Quadratic Equations Exercise 4.2', '15 May 2024', 'Completed', Colors.green),
            _buildAssignmentTile('Science', 'Photosynthesis Lab Report', '18 May 2024', 'Pending', Colors.orange),
            _buildAssignmentTile('English', 'Essay on Climate Change', '12 May 2024', 'Submitted', Colors.blue),
            _buildAssignmentTile('History', 'The French Revolution Map Work', '20 May 2024', 'Not Started', Colors.red),
            _buildAssignmentTile('Computer Sci.', 'Python Loops Assignment', '14 May 2024', 'Completed', Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentTile(String subject, String title, String deadline, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(subject, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Text(status, style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, size: 14, color: AppColors.outline),
              const SizedBox(width: 6),
              Text('Deadline: $deadline', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
              const Spacer(),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  minimumSize: const Size(0, 28),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(status == 'Completed' ? 'Review' : 'Submit', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
