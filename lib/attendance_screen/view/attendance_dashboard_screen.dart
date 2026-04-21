// File: lib/attendance_screen/view/attendance_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/examination_schedule/view/components/exam_summary_card.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/calendar_strip.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

class AttendanceDashboardBody extends StatefulWidget {
  final bool showBackButton;
  final VoidCallback? onBack;

  const AttendanceDashboardBody({
    super.key,
    this.showBackButton = false,
    this.onBack,
  });

  @override
  State<AttendanceDashboardBody> createState() => _AttendanceDashboardBodyState();
}

class _AttendanceDashboardBodyState extends State<AttendanceDashboardBody> {
  String _selectedMonth = 'January';

  void _selectMonth() async {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final String? picked = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.read<LanguageProvider>().translate('select_month')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: months.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(months[index]),
                  onTap: () => Navigator.pop(context, months[index]),
                );
              },
            ),
          ),
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedMonth = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Custom Header ──────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang.translate('mark_attendance'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.onSurface,
                  ),
                ),
                GestureDetector(
                  onTap: _selectMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkTeal,
                      borderRadius: AppRadius.mdRadius,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          _selectedMonth,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ── Calendar Strip ──────────────────────────────────────────────────
        const SliverToBoxAdapter(child: CalendarStrip()),

        const SliverToBoxAdapter(child: SizedBox(height: 32)),

        // ── Stats Grid ──────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {}, 
                        borderRadius: AppRadius.xlRadius,
                        child: ExamSummaryCard(
                          title: lang.translate('present'),
                          value: '10',
                          subValue: '',
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        borderRadius: AppRadius.xlRadius,
                        child: ExamSummaryCard(
                          title: lang.translate('absent'),
                          value: '4',
                          subValue: '',
                          icon: Icons.cancel_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        borderRadius: AppRadius.xlRadius,
                        child: ExamSummaryCard(
                          title: lang.translate('leave'),
                          value: '8',
                          subValue: '',
                          icon: Icons.event_busy_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        borderRadius: AppRadius.xlRadius,
                        child: ExamSummaryCard(
                          title: lang.translate('late'), 
                          value: '2',
                          subValue: '',
                          icon: Icons.access_time_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.fullRadius,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          boxShadow: AppShadows.soft,
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF001A1D)),
      ),
    );
  }
}

class AttendanceDashboardScreen extends StatelessWidget {
  static const String routeName = '/attendance-dashboard';
  final String? title;
  const AttendanceDashboardScreen({super.key, this.title});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: AttendanceDashboardBody(showBackButton: true));
  }
}
