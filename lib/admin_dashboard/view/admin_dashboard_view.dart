import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:provider/provider.dart';
import 'package:school_app/admin_dashboard/view_model/admin_dashboard_view_model.dart';
import 'package:school_app/admin_dashboard/view/components/revenue_summary_card.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';

import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/concerns/view/concerns_view.dart';
import 'package:school_app/common_student_search/common_student_search_screen.dart';
import 'package:school_app/utils/utils.dart';
import 'package:school_app/utils/constants.dart';

class AdminDashboardView extends StatelessWidget {
  static const String route = '/adminDashboard';
  final bool isInsideParent;
  const AdminDashboardView({super.key, this.isInsideParent = false});

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminDashboardViewModel>(
      builder: (context, vm, child) {
        final content = Column(
          children: [
            if (isInsideParent) _buildTopBar(context),
            Expanded(
              child: SophisticatedHUDBackground(
                  child: RefreshIndicator(
                    onRefresh: () => vm.loadAdminData(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 16, AppSpacing.lg, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildGreetingHeader(vm),
                          const SizedBox(height: AppSpacing.lg),
                          RevenueSummaryCard(
                            todayCollection: vm.todayCollection,
                            onViewLedger: () {},
                            onGenerateReport: () {},
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildTopStatsRow(),
                          const SizedBox(height: AppSpacing.md),
                          _buildSectionHeader('Discrepancies & Alerts', onViewAll: () {}),
                          const SizedBox(height: AppSpacing.sm),
                          _buildDiscrepanciesRow(),
                          const SizedBox(height: AppSpacing.md),
                          _buildInsightsHeader(),
                          const SizedBox(height: AppSpacing.sm),
                          _buildInsightsRow(),
                          const SizedBox(height: AppSpacing.md),
                          _buildSectionHeader('Recent Activity', onViewAll: () {}),
                          const SizedBox(height: AppSpacing.md),
                          _buildRecentActivityList(),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Quick Actions',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkTeal,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          _buildQuickActionsRow(context),
                          const SizedBox(height: AppSpacing.lg),
                          _buildBottomPanels(),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
            ),
          ],
        );

        if (isInsideParent) return content;

        return AppScaffold(
          showAppBar: true,
          showBackButton: false,
          activeDrawerItem: 'Dashboard',
          body: content,
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 12),
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
          const Spacer(),
          _iconBtn(Icons.notifications_none_rounded, () {}),
        ],
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
    );
  }

  // --- 1. Header Section ---
  Widget _buildGreetingHeader(AdminDashboardViewModel vm) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Morning,',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1F2937),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${vm.adminName}! 👋',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        height: 1.1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                "Here's what's happening in your school today.",
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.5),
            borderRadius: DashboardUtils.futuristicRadius,
          ),
          child: const Icon(Icons.school_rounded, size: 50, color: AppColors.primary),
        ),
      ],
    );
  }

  // --- 2. Top Stats Section ---
  Widget _buildTopStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            count: '1,248',
            label: 'Total Students',
            subtext: '↑ 5 from yesterday',
            icon: Icons.people_outline,
            iconColor: AppColors.primary,
            subtextColor: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatCard(
            count: '1,102',
            label: 'Present Today',
            subtext: '88.3%',
            icon: Icons.check_circle_outline,
            iconColor: AppColors.primary,
            subtextColor: const Color(0xFF4CAF50),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatCard(
            count: '146',
            label: 'Absent Today',
            subtext: '11.7%',
            icon: Icons.cancel_outlined,
            iconColor: AppColors.error,
            subtextColor: AppColors.error,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _buildStatCard(
            count: '85',
            label: 'Total Teachers',
            subtext: 'Active',
            icon: Icons.person_outline,
            iconColor: AppColors.darkTeal,
            subtextColor: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required String subtext,
    required IconData icon,
    required Color iconColor,
    required Color subtextColor,
  }) {
    return _BaseCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(height: AppSpacing.sm),
          Text(
            count,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.outline),
          ),
          const SizedBox(height: 4),
          Text(
            subtext,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, color: subtextColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  // --- 3. Discrepancies & Alerts ---
  Widget _buildDiscrepanciesRow() {
    return Row(
      children: [
        Expanded(child: _buildAlertCard('12', 'Teachers\nHomework\nNot Uploaded', Icons.assignment_late_outlined)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildAlertCard('08', 'Teachers\nNot Entered\nMarks', Icons.edit_note)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildAlertCard('67', 'Fee\nDefaulters\n', Icons.currency_rupee)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildAlertCard('23', 'Students\nIrregular in Fee\n', Icons.person_off_outlined)),
      ],
    );
  }

  Widget _buildAlertCard(String count, String label, IconData icon) {
    return _BaseCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          const SizedBox(height: AppSpacing.sm),
          Text(
            count,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10, color: AppColors.onSurfaceVariant, height: 1.2),
          ),
        ],
      ),
    );
  }

  // --- 4. School Insights ---
  Widget _buildInsightsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'School Insights',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.onSurface),
        ),
        Row(
          children: [
            const Text(
              'This Month',
              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.keyboard_arrow_down, color: AppColors.primary, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightsRow() {
    return _BaseCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInsightCircle('Attendance Rate', 88.3, true, '↑ 3.2%'),
          _buildInsightCircle('Homework Compliance', 76.0, false, '↓ 6.1%'),
          _buildInsightCircle('Marks Entry', 82.0, true, '↑ 4.5%'),
          _buildInsightCircle('Fee Collection', 68.0, true, '↑ 8.3%'),
        ],
      ),
    );
  }

  Widget _buildInsightCircle(String label, double percentage, bool isPositive, String subtext) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 65,
            width: 65,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
                Center(
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            subtext,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPositive ? const Color(0xFF4CAF50) : AppColors.error,
            ),
          )
        ],
      ),
    );
  }

  // --- 5. Recent Activity ---
  Widget _buildRecentActivityList() {
    return _BaseCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildActivityItem(Icons.check_circle_outline, const Color(0xFF4CAF50), 'Fee receipt deleted by John Doe', '(Accountant)', 'Receipt #FEE1245', '10:30 AM'),
          const Divider(height: 1, thickness: 1, color: AppColors.surfaceContainer),
          _buildActivityItem(Icons.edit_square, const Color(0xFFE05B2F), 'Student data updated by Priya Sharma', '(Admin)', 'Class 8 - Roll No. 25', '09:45 AM'),
          const Divider(height: 1, thickness: 1, color: AppColors.surfaceContainer),
          _buildActivityItem(Icons.assignment_turned_in_outlined, AppColors.primary, 'Homework uploaded by Rahul Verma', '(Teacher)', 'Class 7 - Mathematics', 'Yesterday'),
          const Divider(height: 1, thickness: 1, color: AppColors.surfaceContainer),
          _buildActivityItem(Icons.delete_outline, AppColors.error, 'Fee receipt deleted by Neha Singh', '(Accounts)', 'Receipt #FEE1244', 'Yesterday'),
        ],
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, Color iconColor, String title, String role, String subtitle, String time) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 12, color: AppColors.onSurface),
                    children: [
                      TextSpan(text: title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      TextSpan(text: ' $role', style: const TextStyle(color: AppColors.outline)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.outlineVariant)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: AppColors.outline)),
        ],
      ),
    );
  }

  // --- 6. Quick Actions ---
  Widget _buildQuickActionsRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildActionIcon(Icons.person_add_alt_1_outlined, 'Assign Task', () {}),
        _buildActionIcon(Icons.campaign_outlined, 'Send Notice', () {}),
        _buildActionIcon(Icons.fact_check_outlined, 'Approve Request', () {}),
        _buildActionIcon(Icons.description_outlined, 'Dossier', () {
          navigateToScreen(
            context,
            const CommonStudentSearchScreen(mode: StudentSearchMode.userProfile),
          );
        }),
        _buildActionIcon(Icons.bar_chart_outlined, 'View Reports', () {
          navigateToScreen(
            context,
            const ConcernsView(
              title: 'Rules & Violations',
              screenType: ConcernsViewScreenType.discipline,
              screenOperation: ConcernsViewScreenOperation.view,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: DashboardUtils.futuristicRadius,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.4),
              borderRadius: DashboardUtils.futuristicRadius,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // --- 7. Bottom Split Panels ---
  Widget _buildBottomPanels() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _BaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Fee Defaulters', onViewAll: () {}, isSmall: true),
                const SizedBox(height: AppSpacing.md),
                _buildDefaulterItem('Rohan Mehta', 'Class 8-B', '₹12,450'),
                _buildDefaulterItem('Aaradhya Singh', 'Class 6-A', '₹8,300'),
                _buildDefaulterItem('Kabir Khan', 'Class 9-C', '₹7,200'),
                const SizedBox(height: AppSpacing.sm),
                const Center(
                  child: Text(
                    'View All Defaulters  >',
                    style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _BaseCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Pending Approvals', onViewAll: () {}, isSmall: true),
                const SizedBox(height: AppSpacing.md),
                _buildApprovalItem(Icons.schedule, 'Leave Application', '08 Pending'),
                _buildApprovalItem(Icons.currency_rupee, 'Expense Approval', '05 Pending', iconColor: const Color(0xFF4CAF50)),
                _buildApprovalItem(Icons.person_outline, 'New Admission', '03 Pending'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaulterItem(String name, String className, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.person_outline, color: AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text(className, style: const TextStyle(fontSize: 9, color: AppColors.outline)),
              ],
            ),
          ),
          Text(amount, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.error)),
        ],
      ),
    );
  }

  Widget _buildApprovalItem(IconData icon, String title, String subtitle, {Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface)),
                Text(subtitle, style: const TextStyle(fontSize: 9, color: AppColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll, bool isSmall = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: isSmall ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onViewAll,
          child: Text(
            isSmall ? 'View All' : 'View All >',
            style: TextStyle(
              fontSize: isSmall ? 11 : 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// A reusable base card widget ensuring consistent borders, shadows, and spacing.
class _BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _BaseCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: DashboardUtils.futuristicDecoration(),
      child: child,
    );
  }
}