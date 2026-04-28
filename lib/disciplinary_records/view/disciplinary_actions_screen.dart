import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class DisciplinaryActionsScreen extends StatefulWidget {
  static const String routeName = '/disciplinary-actions';
  final bool isInsideParent;
  const DisciplinaryActionsScreen({super.key, this.isInsideParent = false});

  @override
  State<DisciplinaryActionsScreen> createState() => _DisciplinaryActionsScreenState();
}

class _DisciplinaryActionsScreenState extends State<DisciplinaryActionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = Column(
      children: [
        _buildCustomTabBar(),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              const Center(child: Text('By Type Placeholder')),
              const Center(child: Text('By Year Placeholder')),
              const Center(child: Text('Reports Placeholder')),
            ],
          ),
        ),
      ],
    );

    if (widget.isInsideParent) return content;

    return AppScaffold(
      showAppBar: true,
      body: SophisticatedHUDBackground(
        child: content,
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.onSurfaceVariant,
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'By Type'),
          Tab(text: 'By Year'),
          Tab(text: 'Reports'),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProfileHeader(),
          const SizedBox(height: AppSpacing.lg),
          _buildSummaryGrid(),
          const SizedBox(height: AppSpacing.lg),
          _buildDisciplinaryJourneyChart(),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickInfoRow(),
          const SizedBox(height: AppSpacing.lg),
          _buildYearlySummaryTable(),
          const SizedBox(height: AppSpacing.lg),
          _buildRecentActionsList(),
          const SizedBox(height: AppSpacing.lg),
          _buildInsightsCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aarav'),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aarav Sharma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text('Grade 8 - A  •  Roll No. 23', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                    minimumSize: const Size(0, 24),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  child: Text('View Profile', style: GoogleFonts.inter(fontSize: 10, color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('Academic Year', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline), maxLines: 1),
                const SizedBox(height: 4),
                _buildYearDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Expanded(child: Text('All Years (2013-14 to 2023-24)', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
          const Icon(Icons.arrow_drop_down, size: 14),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Total Actions', '18', Colors.red.shade400, Icons.gavel_rounded)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSummaryCard('Minor Actions', '14', Colors.orange, Icons.warning_amber_rounded)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Major Actions', '4', Colors.purple, Icons.priority_high_rounded)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSummaryCard('This Year', '1', Colors.green, Icons.calendar_today_rounded, subtext: '(2023-24)')),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, Color color, IconData icon, {String? subtext}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label, 
            style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value, 
              style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.onSurface),
            ),
          ),
          if (subtext != null) 
            Text(
              subtext, 
              style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }

  Widget _buildDisciplinaryJourneyChart() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Disciplinary Journey (2013-14 to 2023-24)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              _buildSmallDropdown('All Types'),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, interval: 1, getTitlesWidget: (v, m) {
                    const years = ['13-14', '14-15', '15-16', '16-17', '17-18', '18-19', '19-20', '20-21', '21-22', '22-23', '23-24'];
                    if (v.toInt() >= 0 && v.toInt() < years.length) return Text(years[v.toInt()], style: const TextStyle(fontSize: 7, color: AppColors.outline));
                    return const Text('');
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 2, reservedSize: 20, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: const TextStyle(fontSize: 7, color: AppColors.outline)))),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 2), FlSpot(1, 1), FlSpot(2, 2), FlSpot(3, 1), FlSpot(4, 2), FlSpot(5, 3), FlSpot(6, 1), FlSpot(7, 3), FlSpot(8, 1), FlSpot(9, 1), FlSpot(10, 1)],
                    isCurved: true,
                    color: Colors.red.shade400,
                    barWidth: 2,
                    dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 3, color: Colors.red.shade400, strokeWidth: 1, strokeColor: Colors.white)),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [Colors.red.shade400.withOpacity(0.2), Colors.red.shade400.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDropdown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(4)),
      child: Row(children: [Text(label, style: const TextStyle(fontSize: 9)), const Icon(Icons.arrow_drop_down, size: 12)]),
    );
  }

  Widget _buildQuickInfoRow() {
    return Row(
      children: [
        Expanded(child: _buildQuickInfoCard('Best Year', '2014-15, 2016-17, 2019-20', '(Least Actions)', Colors.green, Icons.verified_user_rounded)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: _buildQuickInfoCard('Year with Most Actions', '2018-19, 2020-21', '(3 Actions)', Colors.orange, Icons.trending_up_rounded)),
      ],
    );
  }

  Widget _buildQuickInfoCard(String title, String value, String sub, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant)),
          Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
          Text(sub, style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline)),
        ],
      ),
    );
  }

  Widget _buildYearlySummaryTable() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yearly Summary', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 16),
          _buildTableHeader(),
          _buildTableRow('2023-24', '1', '0', '1', 'Good'),
          _buildTableRow('2022-23', '1', '0', '1', 'Good'),
          _buildTableRow('2021-22', '1', '0', '1', 'Good'),
          _buildTableRow('2020-21', '2', '1', '3', 'Need Improvement'),
          _buildTableRow('2019-20', '1', '0', '1', 'Good'),
          _buildTableRow('2018-19', '1', '2', '3', 'Need Improvement'),
          _buildTableRow('2017-18', '2', '0', '2', 'Satisfactory'),
          const SizedBox(height: 8),
          Center(child: TextButton.icon(onPressed: () {}, icon: const Icon(Icons.keyboard_arrow_down, size: 16), label: const Text('View All Years'), style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant, textStyle: const TextStyle(fontSize: 11)))),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Academic Year', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline))),
          Expanded(child: Text('Minor', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Major', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Total', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Remarks', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTableRow(String year, String minor, String major, String total, String remark) {
    Color remarkColor = remark == 'Good' ? Colors.green : (remark == 'Satisfactory' ? Colors.blue : Colors.orange);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(year, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600))),
          Expanded(child: Text(minor, style: GoogleFonts.inter(fontSize: 10), textAlign: TextAlign.center)),
          Expanded(child: Text(major, style: GoogleFonts.inter(fontSize: 10), textAlign: TextAlign.center)),
          Expanded(child: Text(total, style: GoogleFonts.inter(fontSize: 10), textAlign: TextAlign.center)),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: remarkColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(remark, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: remarkColor)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActionsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: Text('Recent Disciplinary Actions', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14))),
            const SizedBox(width: 8),
            TextButton(onPressed: () {}, child: Text('View All', style: GoogleFonts.inter(fontSize: 11, color: AppColors.primary))),
          ],
        ),
        _buildActionTile('12', 'Feb 2024', 'Incomplete Homework', 'Minor Action', 'Ms. Priya Sharma', 'Verbal Warning', Colors.red),
        _buildActionTile('05', 'Jan 2024', 'Late to Class', 'Minor Action', 'Mr. David Wilson', 'Verbal Warning', Colors.orange),
        _buildActionTile('18', 'Oct 2023', 'Disruptive Behavior in Class', 'Major Action', 'Mr. Rakesh Verma', 'Counseling', Colors.purple),
      ],
    );
  }

  Widget _buildActionTile(String day, String monthYear, String title, String type, String by, String result, Color typeColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Column(
            children: [
              Text(day, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.red.shade400)),
              Text(monthYear, style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                RichText(text: TextSpan(style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant), children: [const TextSpan(text: 'Type: '), TextSpan(text: type, style: TextStyle(color: typeColor, fontWeight: FontWeight.bold))])),
                const SizedBox(height: 4),
                Text('By: $by', style: GoogleFonts.inter(fontSize: 9, color: AppColors.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(result, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.bold, color: typeColor)),
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.outline),
        ],
      ),
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: DashboardUtils.futuristicDecoration(color: AppColors.primaryContainer.withOpacity(0.1)),
      child: Row(
        children: [
          const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Positive growth!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  'We believe in guiding students towards positive behavior. Keep up the good work!',
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
