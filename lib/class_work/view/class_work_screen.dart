import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:school_app/class_work/view_model/class_work_view_model.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/utils.dart';

class ClassWorkScreen extends StatelessWidget {
  final String? title;
  const ClassWorkScreen({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ClassWorkViewModel()..loadData(),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(
          child: Consumer<ClassWorkViewModel>(
            builder: (context, vm, child) {
              if (vm.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  _buildHeader(context, title ?? 'Class Work'),
                  _buildSelectors(context),
                  _buildSubjectTabs(vm),
                  _buildStatsRow(vm),
                  _buildTodaySection(vm),
                  _buildMotivationCard(),
                  _buildPreviousSection(vm),
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
                image: const DecorationImage(image: NetworkImage('https://i.pravatar.cc/150?u=student_classwork'), fit: BoxFit.cover),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectors(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        child: Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text('Grade 8 - A', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded, size: 14, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.lgRadius,
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.chevron_left_rounded, size: 20, color: AppColors.onSurfaceVariant),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text('17 May 2024', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
                          ],
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 44,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: AppRadius.lgRadius,
                border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
              ),
              child: const Icon(Icons.tune_rounded, size: 18, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectTabs(ClassWorkViewModel vm) {
    final subjects = ['All Subjects', 'Maths', 'Science', 'English', 'Social'];
    final icons = [Icons.grid_view_rounded, Icons.calculate_rounded, Icons.science_rounded, Icons.edit_note_rounded, Icons.public_rounded];

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          scrollDirection: Axis.horizontal,
          itemCount: subjects.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) {
            final isSelected = vm.selectedSubject == (i == 0 ? 'All Subjects' : subjects[i]);
            return InkWell(
              onTap: () => vm.setSubject(i == 0 ? 'All Subjects' : subjects[i]),
              borderRadius: AppRadius.fullRadius,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkTeal : AppColors.surfaceContainerLowest,
                  borderRadius: AppRadius.fullRadius,
                  border: Border.all(color: isSelected ? AppColors.darkTeal : AppColors.outlineVariant.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Icon(icons[i], size: 16, color: isSelected ? Colors.white : AppColors.darkTeal),
                    const SizedBox(width: 8),
                    Text(
                      subjects[i],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatsRow(ClassWorkViewModel vm) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        child: Row(
          children: [
            _buildStatCard('6', 'Topics', const Color(0xFF0EA5E9), Icons.assignment_rounded),
            const SizedBox(width: 10),
            _buildStatCard('5', 'Completed', const Color(0xFF10B981), Icons.check_circle_rounded),
            const SizedBox(width: 10),
            _buildStatCard('1', 'Pending', const Color(0xFFF59E0B), Icons.schedule_rounded),
            const SizedBox(width: 10),
            _buildStatCard('2', 'Attachments', const Color(0xFF8B5CF6), Icons.attach_file_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xlRadius,
          boxShadow: AppShadows.soft,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 12, color: color),
                  const SizedBox(width: 4),
                  Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                ],
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySection(ClassWorkViewModel vm) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text('Today\'s Class Work', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
          const SizedBox(height: 16),
          ...vm.classWork.map((item) => _buildClassWorkCard(item)),
        ]),
      ),
    );
  }

  Widget _buildClassWorkCard(ClassWorkItem item) {
    final isCompleted = item.status == 'Completed';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: item.color.withOpacity(0.12), borderRadius: AppRadius.lgRadius),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(item.subject, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: item.color)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: (isCompleted ? const Color(0xFF10B981) : const Color(0xFFF59E0B)).withOpacity(0.1), borderRadius: AppRadius.fullRadius),
                      child: Text(item.status, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w800, color: isCompleted ? const Color(0xFF10B981) : const Color(0xFFF59E0B))),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item.topic, style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('By ${item.teacher}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule_rounded, size: 12, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(item.time, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.description_outlined, size: 12, color: AppColors.primary),
                      label: Text('View Notes', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.outlineVariant),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [const Color(0xFF0EA5E9).withOpacity(0.05), const Color(0xFF10B981).withOpacity(0.05)]),
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Image.network('https://cdn-icons-png.flaticon.com/512/2666/2666505.png', width: 60, errorBuilder: (_, __, ___) => const Icon(Icons.track_changes_rounded, size: 60, color: AppColors.primary)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stay on Track!', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                  const SizedBox(height: 4),
                  Text('Complete your class work on time and keep learning every day.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant, height: 1.3)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkTeal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), elevation: 0),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_month_rounded, size: 14),
                      const SizedBox(width: 6),
                      Text('View Calendar', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviousSection(ClassWorkViewModel vm) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 24, AppSpacing.lg, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Previous Class Work', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                Text('View All >', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ],
            ),
          ),
          SizedBox(
            height: 150,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              scrollDirection: Axis.horizontal,
              itemCount: vm.previousClassWork.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final item = vm.previousClassWork[i];
                return Container(
                  width: 160,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.xlRadius, border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)), boxShadow: AppShadows.soft),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.date, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text(item.subject, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: item.color)),
                      const SizedBox(height: 4),
                      Expanded(child: Text(item.topic, style: GoogleFonts.plusJakartaSans(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis)),
                      Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                          const SizedBox(width: 4),
                          Text(item.status, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: const Color(0xFF10B981))),
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
}
