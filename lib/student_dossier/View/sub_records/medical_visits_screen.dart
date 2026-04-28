import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class MedicalVisitsScreen extends StatelessWidget {
  static const String routeName = '/medical-visits';
  const MedicalVisitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      appBarTitle: Text("Medical Room Visits", style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
      body: SophisticatedHUDBackground(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildVisitTile('Headache & Mild Fever', '12 May 2024', 'Rest given for 1 hour. Paracetamol 500mg administered.', 'Nurse Anjali'),
            _buildVisitTile('Minor Knee Abrasion', '05 Apr 2024', 'Wound cleaned with antiseptic and bandaged.', 'Dr. Rakesh Verma'),
            _buildVisitTile('Seasonal Allergy', '18 Mar 2024', 'Antihistamine given. Advised to avoid outdoors.', 'Nurse Anjali'),
            _buildVisitTile('Routine Health Checkup', '10 Feb 2024', 'Normal vitals. Height: 152cm, Weight: 45kg.', 'Dr. Rakesh Verma'),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitTile(String reason, String date, String treatment, String by) {
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.pink.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_rounded, color: Colors.pink, size: 14),
                    const SizedBox(width: 6),
                    Text('Medical Visit', style: GoogleFonts.inter(color: Colors.pink, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
            ],
          ),
          const SizedBox(height: 12),
          Text(reason, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.onSurface.withOpacity(0.03), borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Treatment / Notes:', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.outline)),
                const SizedBox(height: 4),
                Text(treatment, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 14, color: AppColors.outline),
              const SizedBox(width: 6),
              Text('Handled by: $by', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
            ],
          ),
        ],
      ),
    );
  }
}
