import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class StatsRow extends StatelessWidget {
  final VoidCallback? onAttendanceTap;
  final VoidCallback? onHomeworkTap;

  const StatsRow({
    super.key,
    this.onAttendanceTap,
    this.onHomeworkTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '95%',
            label: 'Attendance',
            trend: '+2%',
            icon: Icons.calendar_month_rounded,
            onTap: onAttendanceTap,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            value: '20',
            label: 'Homework Due',
            trend: '+5%',
            icon: Icons.assignment_rounded,
            onTap: onHomeworkTap,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final String trend;
  final IconData icon;
  final VoidCallback? onTap;

  const _StatCard({
    required this.value,
    required this.label,
    required this.trend,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xlRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: AppRadius.fullRadius,
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded, size: 10, color: AppColors.darkTeal),
                      const SizedBox(width: 2),
                      Text(
                        trend,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkTeal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 14, color: AppColors.darkTeal),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTeal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
