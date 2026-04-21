import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart'; // Added for date formatting
import 'package:provider/provider.dart';

// Your existing imports
import 'package:school_app/attendance_screen/view/attendance_dashboard_screen.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/model/home_screen_utils.dart';
import 'package:school_app/home_screen/view/components/category_tabs.dart';
import 'package:school_app/home_screen/view/components/dashboard_hero.dart';
import 'package:school_app/home_screen/view/components/stats_row.dart';
import 'package:school_app/home_screen/view_model/home_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/calendar_strip.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/components/square_grid_component.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/utils.dart';

final class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? loggedInUser;
  Future<ApiResponse<HomeModel>>? homeDetail;
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  HomeModel? homeModel;
  Map<String, List<MenuDetail>> menuDetailMap = {};
  bool _isDashboard = false;

  // --- Dashboard State ---
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    try {
      loggedInUser = AuthViewModel.instance.getLoggedInUser();
      _loadHomeData();
    } catch (_) {}
  }

  void _loadHomeData() {
    homeModel = null;
    menuDetailMap = {};
    homeDetail = HomeViewmodel.instance.fetchHomeDetail().then((response) {
      if (response.success) {
        homeModel = response.data;
        if (homeModel != null) AuthViewModel.instance.setHomeModel(homeModel!);
        homeModel?.menuDetails?.forEach((m) {
          final key = m.categoryId == '2' ? '2' : '1';
          menuDetailMap[key] = [...(menuDetailMap[key] ?? []), m];
        });
      }
      return response;
    });
  }

  // --- Dummy Data Generator for Dashboard ---
  Map<String, dynamic> _getDummyDataForDate(DateTime date) {
    String formattedDate = DateFormat('MMM dd, yyyy').format(date);
    return {
      'homework': {
        'subject': 'Mathematics',
        'task': 'Complete chapters 4 & 5 exercises. Submit via portal.',
        'status': 'Pending',
        'dueDate': formattedDate,
      },
      'examination': {
        'title': 'Mid-Term Physics Exam',
        'time': '10:00 AM - 12:30 PM',
        'location': 'Room 302',
        'date': formattedDate,
      },
      'tracker': {
        'attendance': 85.0,
        'assignmentsCompleted': 12,
        'totalAssignments': 15,
      },
      'fee': {
        'totalDue': '₹ 12,450',
        'dueDate': 'May 15, 2026',
        'status': 'Unpaid',
      }
    };
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isDashboard) {
          setState(() => _isDashboard = false);
          return false;
        }
        SystemNavigator.pop();
        return true;
      },
      child: AppScaffold(
        isLoadingNotifier: isLoadingNotifier,
        showBackButton: false,
        showAppBar: true,
        body: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => setState(_loadHomeData),
          child: AppFutureBuilder(
            future: homeDetail,
            builder: (context, snapshot) {
              context.watch<LanguageProvider>();
              if (homeModel?.menuDetails?.isEmpty ?? true) {
                return const NoDataWidget();
              }
              return _buildMainContent();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: UserHeaderWidget(user: loggedInUser, homeModel: homeModel),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(
            child: _ViewSwitch(
              isDashboard: _isDashboard,
              onChanged: (val) => setState(() => _isDashboard = val),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        if (_isDashboard) ..._buildDashboardSlivers() else ..._buildHomeSlivers(),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  // --- DASHBOARD SLIVERS ---
  List<Widget> _buildDashboardSlivers() {
    final dummyData = _getDummyDataForDate(_selectedDate);

    return [
      // 1. Interactive Date Selector
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: _buildDateSelector(),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // 2. Homework Tile
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: _buildLargeTile(
            title: 'Homework',
            subtitle: 'Current assignments for selected date',
            icon: Icons.menu_book_rounded,
            headerColor: Colors.blueAccent,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dummyData['homework']['subject'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 6),
                Text(
                  dummyData['homework']['task'],
                  style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, height: 1.3),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Due: ${dummyData['homework']['dueDate']}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                    _buildStatusBadge(dummyData['homework']['status'], Colors.orange),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // 3. Examination/Test Tile
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: _buildLargeTile(
            title: 'Examination / Test',
            subtitle: 'Upcoming assessments & schedules',
            icon: Icons.assignment_rounded,
            headerColor: Colors.redAccent,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dummyData['examination']['title'], style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 18, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(dummyData['examination']['time'], style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded, size: 18, color: AppColors.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(dummyData['examination']['location'], style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // 4. Monthly Tracker Tile
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: _buildLargeTile(
            title: 'Monthly Tracker',
            subtitle: 'Visual overview of your progress',
            icon: Icons.insert_chart_rounded,
            headerColor: Colors.teal,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProgressBar(
                  label: 'Attendance',
                  valueText: '${dummyData['tracker']['attendance']}%',
                  progress: dummyData['tracker']['attendance'] / 100,
                  color: Colors.teal,
                ),
                const SizedBox(height: 16),
                _buildProgressBar(
                  label: 'Assignments Completed',
                  valueText: '${dummyData['tracker']['assignmentsCompleted']} / ${dummyData['tracker']['totalAssignments']}',
                  progress: dummyData['tracker']['assignmentsCompleted'] / dummyData['tracker']['totalAssignments'],
                  color: Colors.blueAccent,
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // 5. Fee Summary Tile
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: _buildLargeTile(
            title: 'Fee Summary',
            subtitle: 'Current financial status & dues',
            icon: Icons.account_balance_wallet_rounded,
            headerColor: Colors.purpleAccent,
            content: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Outstanding Balance', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Text(dummyData['fee']['totalDue'], style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Due: ${dummyData['fee']['dueDate']}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        _buildStatusBadge(dummyData['fee']['status'], Colors.redAccent),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      // Connect to your payment screen or logic here
                    },
                    child: Text('Pay Now', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 32)),

      // 6. Quick Navigation Section
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: Text(
            'Quick Navigation',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // 7. Redesigned Prominent Tiles Grid
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85, // Optimized ratio for taller tiles with subtitles
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final navItems = [
                {'title': 'Academics', 'sub': 'Grades & Subjects', 'icon': Icons.school_rounded, 'color': Colors.indigo},
                {'title': 'Timetable', 'sub': 'Classes & Schedule', 'icon': Icons.calendar_today_rounded, 'color': Colors.green},
                {'title': 'Library', 'sub': 'Books & History', 'icon': Icons.local_library_rounded, 'color': Colors.brown},
                {'title': 'Transport', 'sub': 'Routes & Tracking', 'icon': Icons.directions_bus_rounded, 'color': Colors.deepOrange},
              ];
              final item = navItems[index];
              return _buildMenuTile(
                title: item['title'] as String,
                subtitleWidget: Text(
                  item['sub'] as String,
                  style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                icon: item['icon'] as IconData,
                accentColor: item['color'] as Color,
                onTap: () {
                  // Connect to your existing routing logic
                },
              );
            },
            childCount: 4,
          ),
        ),
      ),
    ];
  }

  // --- HOME SLIVERS ---
  List<Widget> _buildHomeSlivers() {
    final listItems = menuDetailMap['1'] ?? [];
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: DashboardHero(
            title: 'Welcome to your Learning Hub',
            buttonText: 'Academic Profile',
            onTap: () => setState(() => _isDashboard = true),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      const SliverToBoxAdapter(child: CategoryTabs()),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: Text(
            'Explore Menu',
            style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      
      if (listItems.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList.separated(
            itemCount: listItems.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, i) {
              final m = listItems[i];
              final title = context.read<LanguageProvider>().translate(m.menuName ?? '');

              return _buildMenuTile(
                title: title,
                subtitleWidget: _getSubtitleWidgetForMenu(title),
                icon: getMenuIcon(m),
                accentColor: _getColorForMenu(i),
                onTap: () => _navigate(m),
              );
            },
          ),
        ),
    ];
  }

  void _navigate(MenuDetail m) {
    final dest = navigateToMenuDestination(m, title: m.menuName);
    if (dest != null) navigateToScreen(context, dest);
  }

  Widget _getSubtitleWidgetForMenu(String title) {
    final lowerTitle = title.toLowerCase();
    final defaultStyle = GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant);

    Widget buildRichSubtitle(String line1, String line2, String actionText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(line1, style: defaultStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.onSurface)),
          const SizedBox(height: 4),
          Text(line2, style: defaultStyle.copyWith(height: 1.4), maxLines: 3),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(actionText, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
            ],
          ),
        ],
      );
    }

    if (lowerTitle.contains('norms') || lowerTitle.contains('violation')) {
      return buildRichSubtitle('Latest: Bullying in corridor', 'Incident reported on April 18, 2026. Status is currently Under Review.', 'View Incident Report');
    }
    if (lowerTitle.contains('time') && lowerTitle.contains('table')) {
      return buildRichSubtitle("Today's Schedule:", '10:00 AM - Maths (Room 301)\n11:00 AM - Physics (Lab 2)', 'View Full Schedule');
    }
    if (lowerTitle.contains('academic')) {
      return buildRichSubtitle('Current Term: 2025-26', 'Guidelines & Rules active for this session. Please review the updated policy.', 'View Guidelines');
    }
    if (lowerTitle.contains('fee')) {
      return buildRichSubtitle('Outstanding Due: ₹ 12,450', 'Next Payment Date: May 15, 2026. Late fees may apply after due date.', 'Proceed to Payment');
    }
    if (lowerTitle.contains('progress') || lowerTitle.contains('report')) {
      return buildRichSubtitle('Latest: Term 1 Results', 'Overall Grade: A. Class Rank: 4th. Teacher remarks available.', 'View Report Card');
    }
    if (lowerTitle.contains('document')) {
      return buildRichSubtitle('2 New Documents', 'Your signature is required on the recent consent forms for the upcoming trip.', 'View Documents');
    }
    if (lowerTitle.contains('attendance')) {
      return buildRichSubtitle('This Month: 85%', '3 Absences recorded. 1 pending leave request is awaiting approval.', 'View Calendar');
    }
    if (lowerTitle.contains('homework') || lowerTitle.contains('assignment')) {
      return buildRichSubtitle('2 Pending Tasks', 'Due tomorrow: Mathematics Exercise 4 and Science Project Draft.', 'View Assignments');
    }
    if (lowerTitle.contains('notice') || lowerTitle.contains('circular')) {
      return buildRichSubtitle('Unread: 1 New Notice', 'Annual Sports Day schedule announced. Please check uniform requirements.', 'View Notice Board');
    }
    if (lowerTitle.contains('profile')) {
      return buildRichSubtitle('Profile: 90% Complete', 'Please update your emergency contact info and blood group details.', 'Edit Profile');
    }
    if (lowerTitle.contains('transport')) {
      return buildRichSubtitle('Route 4 (Morning)', 'Bus is currently 5 mins away from your stop. Driver: Mr. Sharma.', 'Track Vehicle');
    }
    if (lowerTitle.contains('library')) {
      return buildRichSubtitle('1 Book Overdue', 'Physics Vol 2. Please return to the library immediately to avoid fines.', 'View Issued Books');
    }
    if (lowerTitle.contains('leave')) {
      return buildRichSubtitle('Recent: Approved', 'Sick leave (April 10 - April 12). You have 4 casual leaves remaining.', 'Apply for Leave');
    }
    if (lowerTitle.contains('syllabus')) {
      return buildRichSubtitle('Mathematics', 'Chapter 4 currently in progress. Next week: Chapter 5 Introduction.', 'View Complete Syllabus');
    }
    if (lowerTitle.contains('calendar')) {
      return buildRichSubtitle('Next Event: Science Fair', 'This Friday at 10:00 AM in the Main Hall. Parents are invited.', 'View Yearly Calendar');
    }
    if (lowerTitle.contains('gallery')) {
      return buildRichSubtitle('New Album Added', 'Spring Festival 2026. 45 new photos and 2 videos have been uploaded.', 'View Media');
    }
    if (lowerTitle.contains('feedback')) {
      return buildRichSubtitle('1 Response Received', 'Admin replied to your last inquiry regarding the transport facility.', 'View Responses');
    }

    return buildRichSubtitle('Details & Info', 'Tap to view more information regarding this section.', 'Explore Details');
  }

  Color _getColorForMenu(int index) {
    final colors = [
      Colors.indigo,
      Colors.teal,
      Colors.deepOrange,
      Colors.blueAccent,
      Colors.brown,
      Colors.purpleAccent,
      Colors.green,
      Colors.redAccent,
    ];
    return colors[index % colors.length];
  }

  // --- DASHBOARD HELPER WIDGETS ---

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Selected Date', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                DateFormat('EEEE, MMMM dd, yyyy').format(_selectedDate),
                style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLargeTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color headerColor,
    required Widget content,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Icon(icon, color: headerColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.plusJakartaSans(color: headerColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: GoogleFonts.inter(color: AppColors.onSurfaceVariant, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required String valueText,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            Text(valueText, style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.outlineVariant.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // Improved Menu Tile Component
  Widget _buildMenuTile({
    required String title,
    required Widget subtitleWidget,
    required dynamic icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    Widget iconWidget;
    if (icon is IconData) {
      iconWidget = Icon(icon, color: accentColor, size: 28);
    } else if (icon is String && icon.isNotEmpty) {
      // The icon is an asset path string. Added errorBuilder for missing assets.
      iconWidget = Image.asset(
        icon, 
        width: 28, 
        height: 28,
        errorBuilder: (context, error, stackTrace) {
          IconData fallbackIcon = title.toLowerCase().contains('fee') ? Icons.payment_rounded : Icons.category_rounded;
          return Icon(fallbackIcon, color: accentColor, size: 28);
        },
      );
    } else {
      // Fallback for safety in case of unexpected type or empty string.
      iconWidget = Icon(Icons.category_rounded, color: accentColor, size: 28);
    }

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xlRadius,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.xlRadius,
          border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
          boxShadow: AppShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: iconWidget,
            ),
            const SizedBox(height: 16),
            Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            subtitleWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}

// --- SWITCH COMPONENTS ---

class _ViewSwitch extends StatelessWidget {
  final bool isDashboard;
  final ValueChanged<bool> onChanged;

  const _ViewSwitch({required this.isDashboard, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Row(
        children: [
          Expanded(
            child: _SwitchItem(
              label: 'Home',
              isActive: !isDashboard,
              onTap: () => onChanged(false),
            ),
          ),
          Expanded(
            child: _SwitchItem(
              label: 'Dashboard',
              isActive: isDashboard,
              onTap: () => onChanged(true),
            ),
          ),
        ],
      ),
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _SwitchItem({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: AppRadius.fullRadius,
          boxShadow: isActive ? AppShadows.soft : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}