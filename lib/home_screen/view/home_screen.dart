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
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // 1. Transport Tracker Hero (Always at the top)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(child: _buildTransportHero()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // 2. Quick Info Tiles
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverToBoxAdapter(child: _buildQuickInfoTiles()),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // 3. Context Controls (Switch)
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
    return [
      // Context Control - Date Selector
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(child: _buildCompactDateSelector()),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Student Overview Card
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(child: _buildStudentOverviewCard()),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Mid-Level Info Cards (Attendance & Info)
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(child: _buildMidLevelCards()),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Fee Details Section
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(child: _buildFeeDetailsCard()),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 16)),

      // Daily Update Feed
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(child: _buildDailyUpdateFeedCard()),
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

  Widget _buildTransportHero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transport Tracker', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
        const SizedBox(height: 12),
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: AppRadius.xlRadius,
            border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(color: AppColors.outlineVariant.withOpacity(0.3)),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: AppShadows.soft,
                      ),
                      child: const Icon(Icons.directions_bus_rounded, color: Colors.blueAccent, size: 32),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Live Location', style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: AppShadows.soft,
                  ),
                  child: Text('Map', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoTiles() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.1),
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.play_circle_fill_rounded, color: Colors.redAccent, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Stream', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                      Text('Announcements', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.history_rounded, color: Colors.blueAccent, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Today History', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                      Text('Route logs', style: GoogleFonts.inter(fontSize: 10, color: AppColors.onSurfaceVariant), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Dashboard',
          style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onSurface),
        ),
        InkWell(
          onTap: () => _selectDate(context),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              boxShadow: AppShadows.soft,
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  DateFormat('dd MMM yyyy').format(_selectedDate),
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_rounded, size: 32, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Krish', style: GoogleFonts.plusJakartaSans(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Class: XII-A', style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Text('Status: Present', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMidLevelCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Attendance Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.xlRadius,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
              boxShadow: AppShadows.soft,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Attendance', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(4)),
                      child: Text('Weekly', style: GoogleFonts.inter(fontSize: 9, color: AppColors.onSurfaceVariant)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      height: 70,
                      child: CircularProgressIndicator(
                        value: 0.92,
                        strokeWidth: 6,
                        backgroundColor: Colors.teal.withOpacity(0.1),
                        color: Colors.teal,
                      ),
                    ),
                    Text('92%', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                  ],
                ),
                const SizedBox(height: 12),
                Text('On track!', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Information Card
        Expanded(
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
              children: [
                Text('Notices', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Annual Science Fair registration open.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.circle, size: 6, color: AppColors.primary),
                    ),
                    const SizedBox(width: 6),
                    Expanded(child: Text('Holiday on 25th April.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.onSurface), maxLines: 2, overflow: TextOverflow.ellipsis)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 28,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: Text('View All', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purpleAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.purpleAccent, size: 20),
              ),
              const SizedBox(width: 12),
              Text('Fee Details', style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Outstanding Amount', style: GoogleFonts.inter(fontSize: 12, color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text('₹ 12,500', style: GoogleFonts.plusJakartaSans(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.onSurface)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: Text('Detail', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {},
                    child: Text('Pay', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyUpdateFeedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: AppRadius.xlRadius,
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.campaign_rounded, color: Colors.amber, size: 20),
              const SizedBox(width: 8),
              Text('Daily Update Feed', style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.amber[800])),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Sports day practice will commence at 3:00 PM today on the main ground. Please ensure you are in complete sports uniform.',
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.onSurface, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDot(true),
              const SizedBox(width: 4),
              _buildDot(false),
              const SizedBox(width: 4),
              _buildDot(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDot(bool isActive) {
    return Container(
      width: isActive ? 16 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.amber : Colors.amber.withOpacity(0.3),
        borderRadius: BorderRadius.circular(3),
      ),
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

// Custom painter to draw the map background grid on the transport module.
class GridPainter extends CustomPainter {
  final Color color;
  GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    const spacing = 20.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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