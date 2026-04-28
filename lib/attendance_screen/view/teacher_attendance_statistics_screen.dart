import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';

class TeacherAttendanceStatisticsScreen extends StatelessWidget {
  static const String routeName = '/teacher-attendance-stats';
  
  const TeacherAttendanceStatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showAppBar: true,
      body: SophisticatedHUDBackground(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppSpacing.lg),
              _buildOverviewStats(),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Monthly Attendance Trend'),
              const SizedBox(height: AppSpacing.md),
              _buildTrendChart(),
              const SizedBox(height: AppSpacing.lg),
              _buildSectionHeader('Class-wise Breakdown'),
              const SizedBox(height: AppSpacing.md),
              _buildClassBreakdownList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attendance Analytics',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Detailed statistical overview of student attendance.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewStats() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Avg. Attendance',
            value: '92.4%',
            icon: Icons.trending_up_rounded,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _StatCard(
            label: 'Total Students',
            value: '420',
            icon: Icons.people_outline_rounded,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildTrendChart() {
    // Placeholder for a chart widget
    return Container(
      height: 200,
      width: double.infinity,
      decoration: DashboardUtils.futuristicDecoration(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.primary.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text(
              'Attendance Graph Placeholder',
              style: GoogleFonts.inter(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassBreakdownList() {
    final classes = [
      {'name': 'Class 10-A', 'percentage': '95%'},
      {'name': 'Class 10-B', 'percentage': '88%'},
      {'name': 'Class 9-C', 'percentage': '91%'},
      {'name': 'Class 8-A', 'percentage': '94%'},
    ];

    return Column(
      children: classes.map((c) => _ClassStatTile(name: c['name']!, percentage: c['percentage']!)).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ClassStatTile extends StatelessWidget {
  final String name;
  final String percentage;

  const _ClassStatTile({required this.name, required this.percentage});

  @override
  Widget build(BuildContext context) {
    final double pct = double.parse(percentage.replaceAll('%', '')) / 100;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: AppColors.primaryContainer.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            percentage,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
