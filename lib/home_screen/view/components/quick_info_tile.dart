import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';

class QuickInfoTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickInfoTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: DashboardUtils.futuristicDecoration(glowColor: color),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                Icon(Icons.arrow_outward_rounded, color: AppColors.outlineVariant, size: 16),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              title.toUpperCase(), 
              style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.0),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
