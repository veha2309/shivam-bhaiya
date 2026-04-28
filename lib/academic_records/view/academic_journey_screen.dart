import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class AcademicJourneyScreen extends StatefulWidget {
  static const String routeName = '/academic-journey';
  final bool isInsideParent;
  const AcademicJourneyScreen({super.key, this.isInsideParent = false});

  @override
  State<AcademicJourneyScreen> createState() => _AcademicJourneyScreenState();
}

class _AcademicJourneyScreenState extends State<AcademicJourneyScreen> with SingleTickerProviderStateMixin {
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
              const Center(child: Text('Subject Wise Placeholder')),
              const Center(child: Text('Term Wise Placeholder')),
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
          Tab(text: 'Subject Wise'),
          Tab(text: 'Term Wise'),
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
          _buildPerformanceSummaryGrid(),
          const SizedBox(height: AppSpacing.lg),
          _buildAcademicJourneyChart(),
          const SizedBox(height: AppSpacing.lg),
          _buildYearlyComparisonTable(),
          const SizedBox(height: AppSpacing.lg),
          _buildSubjectComparisonAndDistribution(),
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
            radius: 30,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=aarav'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Aarav Sharma', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18)),
                Text('Grade 8 - A  •  Roll No. 23', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                Text('Admission No.: 2024/08/023', style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
              ],
            ),
          ),
          _buildYearDropdown(),
        ],
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text('2023-24', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600)),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }

  Widget _buildPerformanceSummaryGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Overall Performance Summary', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Average Percentage', '85.6%', '', Colors.blue, Icons.analytics_outlined)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSummaryCard('Best Percentage', '92.8%', '(2020-21)', Colors.green, Icons.emoji_events_outlined)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildSummaryCard('Most Improved Year', '+12.4%', '(2019-20)', Colors.orange, Icons.trending_up_rounded)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSummaryCard('Overall Rank', 'Top 15%', '(Across All Years)', Colors.purple, Icons.workspace_premium_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, String subtext, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
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
          if (subtext.isNotEmpty) 
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

  Widget _buildAcademicJourneyChart() {
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
                  'Academic Journey',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: AppColors.outlineVariant), borderRadius: BorderRadius.circular(6)),
                child: Text('Percentage (%)', style: GoogleFonts.inter(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (v) => FlLine(color: AppColors.outlineVariant.withOpacity(0.5), strokeWidth: 1, dashArray: [5, 5])),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30, interval: 1, getTitlesWidget: (v, m) {
                    const years = ['13-14', '14-15', '15-16', '16-17', '17-18', '18-19', '19-20', '20-21', '21-22', '22-23', '23-24'];
                    if (v.toInt() >= 0 && v.toInt() < years.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(years[v.toInt()], style: const TextStyle(fontSize: 8, color: AppColors.outline)));
                    return const Text('');
                  })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 20, reservedSize: 30, getTitlesWidget: (v, m) => Text('${v.toInt()}%', style: const TextStyle(fontSize: 8, color: AppColors.outline)))),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [FlSpot(0, 68.4), FlSpot(1, 72.1), FlSpot(2, 74.8), FlSpot(3, 76.3), FlSpot(4, 78.6), FlSpot(5, 81.2), FlSpot(6, 79.4), FlSpot(7, 92.8), FlSpot(8, 88.6), FlSpot(9, 86.3), FlSpot(10, 87.5)],
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true, getDotPainter: (s, p, b, i) => FlDotCirclePainter(radius: 4, color: AppColors.primary, strokeWidth: 2, strokeColor: Colors.white)),
                    belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYearlyComparisonTable() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Yearly Performance Comparison', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 16),
          _buildTableHeader(),
          _buildTableRow('2023-24', '87.5%', '96.0%', '71.0%', 'A', '12 / 120'),
          _buildTableRow('2022-23', '86.3%', '94.0%', '69.0%', 'A', '14 / 118'),
          _buildTableRow('2021-22', '88.6%', '95.0%', '70.0%', 'A', '10 / 115'),
          _buildTableRow('2020-21', '92.8%', '97.0%', '78.0%', 'A+', '6 / 112', highlight: true),
          _buildTableRow('2019-20', '79.4%', '92.0%', '65.0%', 'B+', '18 / 110'),
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
          Expanded(flex: 2, child: Text('Academic Year', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline))),
          Expanded(child: Text('Avg %', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('High %', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Low %', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Grade', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Rank', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTableRow(String year, String avg, String high, String low, String grade, String rank, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(year, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: highlight ? Colors.green : null))),
          Expanded(child: Text(avg, style: GoogleFonts.inter(fontSize: 11, color: highlight ? Colors.green : null), textAlign: TextAlign.center)),
          Expanded(child: Text(high, style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(child: Text(low, style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: (grade.startsWith('A') ? Colors.green : Colors.blue).withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(grade, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: grade.startsWith('A') ? Colors.green : Colors.blue)),
              ),
            ),
          ),
          Expanded(child: Text(rank, style: GoogleFonts.inter(fontSize: 10), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildSubjectComparisonAndDistribution() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: DashboardUtils.futuristicDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subject Wise Average Comparison', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 12)),
                const SizedBox(height: 16),
                SizedBox(height: 150, child: _buildSubjectLineChart()),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: DashboardUtils.futuristicDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Performance Distribution', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11)),
                const SizedBox(height: 16),
                SizedBox(height: 100, child: _buildDistributionDonut()),
                const SizedBox(height: 8),
                _buildLegendItem('Excellent', Colors.green),
                _buildLegendItem('Good', Colors.blue),
                _buildLegendItem('Average', Colors.orange),
                _buildLegendItem('Needs Imp.', Colors.red),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, getTitlesWidget: (v, m) => Text(['19-20', '20-21', '21-22', '22-23', '23-24'][v.toInt().clamp(0, 4)], style: const TextStyle(fontSize: 7)))),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, interval: 20, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: TextStyle(fontSize: 7)))),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          _lineData([70, 80, 85, 90, 95], Colors.blue),
          _lineData([50, 70, 75, 80, 82], Colors.green),
          _lineData([60, 65, 62, 68, 72], Colors.purple),
          _lineData([40, 50, 48, 55, 60], Colors.orange),
        ],
      ),
    );
  }

  LineChartBarData _lineData(List<double> pts, Color color) {
    return LineChartBarData(
      spots: pts.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2,
      dotData: const FlDotData(show: true),
    );
  }

  Widget _buildDistributionDonut() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 20,
        sections: [
          PieChartSectionData(color: Colors.green, value: 32, radius: 15, showTitle: false),
          PieChartSectionData(color: Colors.blue, value: 46, radius: 15, showTitle: false),
          PieChartSectionData(color: Colors.orange, value: 18, radius: 15, showTitle: false),
          PieChartSectionData(color: Colors.red, value: 4, radius: 15, showTitle: false),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 8))),
      ],
    );
  }

  Widget _buildInsightsCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: DashboardUtils.futuristicDecoration(color: AppColors.primaryContainer.withOpacity(0.1)),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Consistent performer!', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  'You have shown excellent consistency in your academic performance over the years. Keep up the great work!',
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
