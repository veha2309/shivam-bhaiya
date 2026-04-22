import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/utils/app_theme.dart';

class StudentOverviewCard extends StatelessWidget {
  final String name;
  final String className;
  final String status;
  final String avatarUrl;

  const StudentOverviewCard({
    super.key,
    required this.name,
    required this.className,
    required this.status,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: $className // STATUS: ACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(4),
                    border: Border(left: BorderSide(color: Colors.green[500]!, width: 3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.green[400],
                          shape: BoxShape.rectangle,
                          boxShadow: [
                            BoxShadow(color: Colors.green, blurRadius: 4, spreadRadius: 1)
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 2),
              image: DecorationImage(
                image: NetworkImage(avatarUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
