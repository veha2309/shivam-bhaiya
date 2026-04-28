import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_scaffold.dart';

class AttendanceRecordsScreen extends StatefulWidget {
  static const String routeName = '/attendance-records';
  final bool isInsideParent;
  const AttendanceRecordsScreen({super.key, this.isInsideParent = false});

  @override
  State<AttendanceRecordsScreen> createState() => _AttendanceRecordsScreenState();
}

class _AttendanceRecordsScreenState extends State<AttendanceRecordsScreen> with SingleTickerProviderStateMixin {
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
              _buildMonthlyTab(),
              _buildDailyTab(),
              _buildReportsTab(),
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

  Widget _buildReportsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReportTile('Monthly Attendance Report', 'May 2024', 'PDF • 450 KB'),
        _buildReportTile('Consolidated Term Report', 'Term 1 (2023-24)', 'PDF • 1.2 MB'),
        _buildReportTile('Academic Year Summary', '2022-23', 'PDF • 2.8 MB'),
        _buildReportTile('Detailed Subject Wise Report', 'Final Exams 2023', 'PDF • 980 KB'),
      ],
    );
  }

  Widget _buildReportTile(String title, String subtitle, String info) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 4),
                Text(info, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
              ],
            ),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.download_rounded, color: AppColors.primary)),
        ],
      ),
    );
  }

  Widget _buildMonthlyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('May 2024', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 18)),
              Row(
                children: [
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_left_rounded)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.chevron_right_rounded)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCalendarGrid(),
          const SizedBox(height: 24),
          _buildMonthlySummary(),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: days.map((d) => Text(d, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outline))).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemCount: 31,
          itemBuilder: (context, index) {
            final day = index + 1;
            final isPresent = day % 7 != 0 && day % 10 != 0;
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isPresent ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3)),
              ),
              child: Text('$day', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: isPresent ? Colors.green.shade700 : Colors.red.shade700)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('Present', '22', Colors.green),
          _buildSummaryItem('Absent', '2', Colors.red),
          _buildSummaryItem('Late', '1', Colors.orange),
          _buildSummaryItem('Holiday', '6', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 15,
      itemBuilder: (context, index) {
        final date = DateTime.now().subtract(Duration(days: index));
        final isPresent = index % 5 != 0;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: DashboardUtils.futuristicDecoration(),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${date.day} May 2024', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                  Text(_getDayName(date.weekday), style: GoogleFonts.inter(fontSize: 11, color: AppColors.outline)),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                child: Text(isPresent ? 'Present' : 'Absent', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isPresent ? Colors.green : Colors.red)),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.outline),
            ],
          ),
        );
      },
    );
  }

  String _getDayName(int day) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[day - 1];
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
        Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline)),
      ],
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
          Tab(text: 'Monthly View'),
          Tab(text: 'Daily View'),
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
          _buildAttendanceSummaryCard(),
          const SizedBox(height: AppSpacing.lg),
          _buildAcademicYearComparison(),
          const SizedBox(height: AppSpacing.lg),
          _buildAttendanceJourneyChart(),
          const SizedBox(height: AppSpacing.lg),
          _buildQuickStatsGrid(),
          const SizedBox(height: AppSpacing.lg),
          _buildYearlySummaryTable(),
          const SizedBox(height: AppSpacing.lg),
          _buildInsightsCard(),
          const SizedBox(height: 100), // Extra space for bottom bar
        ],
      ),
    );
  }

  Widget _buildAttendanceSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Attendance',
                  style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  '92.6%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade600,
                  ),
                ),
                Text(
                  '( Since Admission )',
                  style: GoogleFonts.inter(color: Colors.green.shade400, fontSize: 11),
                ),
                const SizedBox(height: 16),
                _buildSummaryLine(Icons.check_circle, 'Present Days', '1984', Colors.green),
                const SizedBox(height: 8),
                _buildSummaryLine(Icons.cancel, 'Absent Days', '162', Colors.red),
                const SizedBox(height: 8),
                _buildSummaryLine(Icons.access_time_filled, 'Total Days', '2146', Colors.orange),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 120,
              child: Stack(
                children: [
                  PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green.shade500,
                          value: 92.6,
                          radius: 12,
                          showTitle: false,
                        ),
                        PieChartSectionData(
                          color: Colors.red.shade400.withOpacity(0.2),
                          value: 7.4,
                          radius: 10,
                          showTitle: false,
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '92.6%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Attendance',
                          style: GoogleFonts.inter(fontSize: 8, color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurface)),
        const Spacer(),
        Text(value, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.onSurface)),
      ],
    );
  }

  Widget _buildAcademicYearComparison() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Compare By Academic Year',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: DashboardUtils.futuristicDecoration(),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: 'All Years (2013-14 to 2023-24)',
                    isExpanded: true,
                    style: GoogleFonts.inter(color: AppColors.onSurface, fontSize: 12),
                    items: ['All Years (2013-14 to 2023-24)'].map((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Download Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceJourneyChart() {
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
                  'Attendance Journey (2013-14 to 2023-24)',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.outlineVariant),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('Percentage (%)', style: GoogleFonts.inter(fontSize: 10)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: AppColors.outlineVariant.withOpacity(0.5),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const years = ['13-14', '14-15', '15-16', '16-17', '17-18', '18-19', '19-20', '20-21', '21-22', '22-23', '23-24'];
                        if (value.toInt() >= 0 && value.toInt() < years.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(years[value.toInt()], style: const TextStyle(fontSize: 8, color: AppColors.outline)),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text('${value.toInt()}%', style: const TextStyle(fontSize: 8, color: AppColors.outline)),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 89.1),
                      FlSpot(1, 91.3),
                      FlSpot(2, 93.0),
                      FlSpot(3, 90.4),
                      FlSpot(4, 92.7),
                      FlSpot(5, 94.2),
                      FlSpot(6, 91.8),
                      FlSpot(7, 93.6),
                      FlSpot(8, 92.3),
                      FlSpot(9, 92.8),
                      FlSpot(10, 92.6),
                    ],
                    isCurved: false,
                    color: Colors.green.shade500,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 3,
                        color: Colors.green.shade600,
                        strokeWidth: 1,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [Colors.green.shade500.withOpacity(0.1), Colors.green.shade500.withOpacity(0)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildMiniStat('Best Year', '94.2%', '2018-19', Colors.green, Icons.trending_up)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildMiniStat('Lowest Year', '89.1%', '2013-14', Colors.orange, Icons.trending_down)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(child: _buildMiniStat('Average', '92.2%', '(All Years)', Colors.blue, Icons.analytics)),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildMiniStat('Target', '95.0%', '', Colors.purple, Icons.flag_rounded)),
          ],
        ),
      ],
    );
  }

  Widget _buildMiniStat(String label, String value, String subtext, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: DashboardUtils.futuristicDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
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
              style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: color),
            ),
          ),
          if (subtext.isNotEmpty) 
            Text(
              subtext, 
              style: GoogleFonts.inter(fontSize: 8, color: AppColors.outline),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
          Text(
            'Yearly Summary',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildTableHeader(),
          _buildTableRow('2023-24', '194', '16', '210', '92.6%', isPositive: true),
          _buildTableRow('2022-23', '193', '15', '208', '92.8%', isPositive: true),
          _buildTableRow('2021-22', '190', '16', '206', '92.3%', isPositive: true),
          _buildTableRow('2020-21', '182', '13', '195', '93.6%', isPositive: true),
          _buildTableRow('2019-20', '180', '16', '196', '91.8%', isPositive: false),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.keyboard_arrow_down, size: 16),
              label: const Text('View All Years'),
              style: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant, textStyle: const TextStyle(fontSize: 11)),
            ),
          )
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
          Expanded(child: Text('Present', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Absent', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Total', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.center)),
          Expanded(child: Text('Att. %', style: GoogleFonts.inter(fontSize: 10, color: AppColors.outline), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildTableRow(String year, String present, String absent, String total, String pct, {bool isPositive = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(year, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600))),
          Expanded(child: Text(present, style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(child: Text(absent, style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(child: Text(total, style: GoogleFonts.inter(fontSize: 11), textAlign: TextAlign.center)),
          Expanded(
            child: Text(
              pct,
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: isPositive ? Colors.green : Colors.red),
              textAlign: TextAlign.right,
            ),
          ),
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
          const Icon(Icons.insights_rounded, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Insights', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 14)),
                Text(
                  'Great consistency! Keep maintaining your excellent attendance.',
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
