// File: lib/examination_schedule/view/examination_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/examination_schedule/model/examination_schedule.dart';
import 'package:school_app/examination_schedule/view/components/exam_summary_card.dart';
import 'package:school_app/examination_schedule/view_model/examination_schedule_view_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/calendar_strip.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

class ExaminationScheduleBody extends StatefulWidget {
  const ExaminationScheduleBody({super.key});
  @override
  State<ExaminationScheduleBody> createState() => _ExaminationScheduleBodyState();
}

class _ExaminationScheduleBodyState extends State<ExaminationScheduleBody> {
  List<ExaminationSchedule> scheduleList = [];
  Future<ApiResponse<List<ExaminationSchedule>>>? getScheduleFuture;

  @override
  void initState() {
    super.initState();
    fetchExaminationScheduleData();
  }

  void fetchExaminationScheduleData() {
    getScheduleFuture = ExaminationScheduleViewModel.instance.getExaminationSchedule().then((response) {
      if (response.success) setState(() => scheduleList = response.data ?? []);
      return response;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lang.translate('exam_schedules'), style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.darkTeal, borderRadius: AppRadius.mdRadius),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text('January', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(child: CalendarStrip()),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(child: ExamSummaryCard(title: 'Exam Scheduled', value: '8', subValue: 'counts', icon: Icons.check_circle_rounded)),
                const SizedBox(width: 16),
                const Expanded(child: ExamSummaryCard(title: 'Counts', value: '8', subValue: 'counts', icon: Icons.analytics_rounded)),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Expanded(child: ExamSummaryCard(title: 'Upcoming Exams', value: '5', subValue: 'counts', icon: Icons.upcoming_rounded)),
                const SizedBox(width: 16),
                const Expanded(child: ExamSummaryCard(title: 'Pending', value: '5', subValue: 'counts', icon: Icons.pending_actions_rounded)),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

// Keep the screen class for routing, but use the body
class ExaminationScheduleScreen extends StatelessWidget {
  static const String routeName = '/examination-schedule';
  final String? title;
  const ExaminationScheduleScreen({super.key, this.title});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: ExaminationScheduleBody());
  }
}
