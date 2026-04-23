import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/discipline/view_model/discipline_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'dart:math' as math;

class DisciplineScreen extends StatelessWidget {
  final String? title;
  const DisciplineScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DisciplineViewModel()..loadData(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Consumer<DisciplineViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(context, title ?? 'Discipline'),
                  _buildPointsDashboard(vm),
                  _buildFilterTabs(vm),
                  _buildRecentActivity(vm),
                  _buildNegativeCategories(vm),
                  _buildGuidelineCard(),
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
                image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=student_discipline'), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsDashboard(DisciplineViewModel vm) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(AppSpacing.lg),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xxlRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(120, 120),
                    painter: _PointsPainter(percent: 0.85, color: const Color(0xFF10B981)),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('+${vm.totalPoints}', style: GoogleFonts.plusJakartaSans(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                      Text('Points', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good Standing', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF10B981))),
                  const SizedBox(height: 4),
                  Text('Keep up the positive behavior!', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMiniPointCard(Icons.thumb_up_rounded, '+${vm.positivePoints}', 'Positive', const Color(0xFF10B981)),
                      const SizedBox(width: 12),
                      _buildMiniPointCard(Icons.thumb_down_rounded, '-${vm.negativePoints}', 'Negative', const Color(0xFFEF4444)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniPointCard(IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: AppRadius.xlRadius, border: Border.all(color: color.withOpacity(0.12))),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: color)),
            Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: color.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(DisciplineViewModel vm) {
    final filters = ['All Records', 'Positive', 'Negative'];
    final icons = [null, Icons.thumb_up_rounded, Icons.thumb_down_rounded];

    return SliverToBoxAdapter(
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: AppColors.surfaceContainerLow, borderRadius: AppRadius.fullRadius),
        child: Row(
          children: List.generate(filters.length, (i) {
            final isSelected = vm.selectedFilter == filters[i];
            return Expanded(
              child: InkWell(
                onTap: () => vm.setFilter(filters[i]),
                borderRadius: AppRadius.fullRadius,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.darkTeal : Colors.transparent,
                    borderRadius: AppRadius.fullRadius,
                    boxShadow: isSelected ? AppShadows.soft : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icons[i] != null) Icon(icons[i], size: 12, color: isSelected ? Colors.white : (i == 1 ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                      if (icons[i] != null) const SizedBox(width: 6),
                      Text(
                        filters[i],
                        style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(DisciplineViewModel vm) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent Activity', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
              Text('View All >', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ...vm.filteredActivities.map((a) => _buildActivityCard(a)),
        ]),
      ),
    );
  }

  Widget _buildActivityCard(DisciplineActivity activity) {
    final color = activity.isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.xlRadius, boxShadow: AppShadows.soft, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(activity.isPositive ? Icons.thumb_up_rounded : Icons.thumb_down_rounded, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.title, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                const SizedBox(height: 2),
                Text(activity.description, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.person_outline_rounded, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(activity.teacher, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${activity.isPositive ? '+' : '-'}${activity.points}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: color)),
              const SizedBox(height: 4),
              Text(activity.date, style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
              Text(activity.time, style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNegativeCategories(DisciplineViewModel vm) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 12, AppSpacing.lg, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Negative Categories', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                Text('This Term v', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          SizedBox(
            height: 110,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: vm.negativeCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final cat = vm.negativeCategories[i];
                return Container(
                  width: 100,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.xlRadius, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(cat.icon, size: 20, color: const Color(0xFFEF4444).withOpacity(0.7)),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(cat.label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.onSurfaceVariant), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${cat.count}', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                          const SizedBox(width: 4),
                          Text('Times', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
                        ],
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

  Widget _buildGuidelineCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF0D9488)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: AppRadius.xlRadius,
        ),
        child: Row(
          children: [
            Image.network('https://cdn-icons-png.flaticon.com/512/3112/3112946.png', width: 60, errorBuilder: (_, __, ___) => const Icon(Icons.emoji_events_rounded, size: 60, color: Color(0xFFFDE047))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Good choices today,\nbetter tomorrow!', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white)),
                  const SizedBox(height: 4),
                  Text('Your efforts are noticed and appreciated.', style: GoogleFonts.inter(fontSize: 10, color: Colors.white.withOpacity(0.8))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.description_outlined, size: 14),
              label: Text('View Guidelines', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), elevation: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _PointsPainter extends CustomPainter {
  final double percent;
  final Color color;
  _PointsPainter({required this.percent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surfaceContainerLow
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * percent, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
