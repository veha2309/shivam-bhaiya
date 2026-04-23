import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/exam_marks/view_model/exam_marks_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'dart:math' as math;

class ExamMarksScreen extends StatelessWidget {
  final String? title;
  const ExamMarksScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ExamMarksViewModel()..loadData(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Consumer<ExamMarksViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(context, title ?? 'Exam Marks'),
                  _buildTabs(),
                  _buildOverviewCard(vm),
                  _buildRecentExamSection(vm),
                  _buildPreviousReportCards(vm),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 8),
        child: Row(
          children: [
            InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: AppRadius.fullRadius,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                  boxShadow: AppShadows.soft,
                ),
                child: const Icon(Icons.chevron_left_rounded, color: AppColors.onSurface),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
                ),
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=student_exam'), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildTab('Overview', true),
                    const SizedBox(width: 8),
                    _buildTab('Subject Wise', false),
                    const SizedBox(width: 8),
                    _buildTab('Term Wise', false),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, shape: BoxShape.circle, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
              child: const Icon(Icons.file_download_outlined, size: 20, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isSelected ? AppColors.darkTeal : Colors.transparent, borderRadius: AppRadius.fullRadius),
      child: Text(
        label,
        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildOverviewCard(ExamMarksViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xxlRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${vm.lastTermDiff} from last term', 
                          style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF10B981)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: AppRadius.fullRadius),
                    child: Text('Grade: ${vm.overallGrade}', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Overall', style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Text('${vm.overallPercentage}%', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: 90,
                  height: 90,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(90, 90),
                        painter: _CircularProgressPainter(percent: vm.overallPercentage / 100, color: AppColors.primary),
                      ),
                      Text('${vm.overallPercentage}%', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOverviewStat(Icons.check_circle_rounded, 'Total', '${vm.totalMarksObtained}', const Color(0xFF0EA5E9)),
                  const SizedBox(height: 12),
                  _buildOverviewStat(Icons.star_rounded, 'Highest', '${vm.highestMarksPercentage}%', const Color(0xFF06B6D4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, size: 14, color: color)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(label, style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentExamSection(ExamMarksViewModel vm) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Exam', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgRadius, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
                child: Row(
                  children: [
                    Text('Term 1 (2023-24)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded, size: 14, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF0F9FF), borderRadius: AppRadius.xlRadius, border: Border.all(color: const Color(0xFF0EA5E9).withOpacity(0.1))),
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.lgRadius), child: const Icon(Icons.assignment_rounded, color: Color(0xFF0EA5E9))),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Term 1 Examination', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('10 Oct - 20 Oct 2023', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: AppRadius.fullRadius),
                        child: Text('Completed', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: const Color(0xFF10B981))),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF06B6D4), 
                      foregroundColor: Colors.white, 
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.fullRadius), 
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), 
                      elevation: 0,
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('View Report Card', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildMarksTable(vm),
        ]),
      ),
    );
  }

  Widget _buildMarksTable(ExamMarksViewModel vm) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Expanded(flex: 3, child: Text('Subject', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600))),
              Expanded(flex: 2, child: Center(child: Text('Marks Obtained', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)))),
              Expanded(flex: 1, child: Center(child: Text('Out of', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)))),
              Expanded(flex: 2, child: Center(child: Text('Percentage', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)))),
            ],
          ),
        ),
        const Divider(height: 1),
        ...vm.subjectMarks.map((m) => _buildMarkRow(m)),
      ],
    );
  }

  Widget _buildMarkRow(SubjectMark m) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.outlineVariant.withOpacity(0.2)))),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: m.color.withOpacity(0.1), borderRadius: AppRadius.lgRadius), child: Icon(m.icon, size: 16, color: m.color)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    m.subject, 
                    style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: Center(child: Text('${m.obtained}', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)))),
          Expanded(flex: 1, child: Center(child: Text('${m.total}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)))),
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: m.color.withOpacity(0.08), borderRadius: AppRadius.fullRadius),
                child: Text('${m.percentage.toInt()}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: m.color)),
              ),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.outlineVariant),
        ],
      ),
    );
  }

  Widget _buildPreviousReportCards(ExamMarksViewModel vm) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 32, AppSpacing.lg, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Previous Report Cards', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                Text('View All >', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: vm.previousReportCards.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, i) {
                final card = vm.previousReportCards[i];
                return Container(
                  width: 180,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.xlRadius, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)), boxShadow: AppShadows.soft),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(card.title, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                      Text(card.session, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Overall', style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                              Text('${card.percentage}%', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                            ],
                          ),
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: card.color.withOpacity(0.1), borderRadius: AppRadius.lgRadius), child: Icon(Icons.description_rounded, color: card.color, size: 20)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(color: AppColors.surfaceContainerLowest, borderRadius: AppRadius.lgRadius, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.file_download_outlined, size: 14, color: AppColors.onSurface),
                              const SizedBox(width: 6),
                              Text('Download', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percent;
  final Color color;
  _CircularProgressPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.surfaceContainerLow..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    canvas.drawCircle(center, radius, paint);
    final progressPaint = Paint()..color = color..strokeWidth = 10..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * percent, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
