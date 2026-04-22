import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

// Component Imports
import 'package:school_app/home_screen/view/components/category_tabs.dart';
import 'package:school_app/home_screen/view/components/dashboard_hero.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/home_screen/view/components/view_switch.dart';
import 'package:school_app/home_screen/view/components/transport_tracker.dart';
import 'package:school_app/home_screen/view/components/student_overview_card.dart';
import 'package:school_app/home_screen/view/components/mid_level_cards.dart';
import 'package:school_app/home_screen/view/components/fee_details_card.dart';
import 'package:school_app/home_screen/view/components/daily_update_feed.dart';
import 'package:school_app/home_screen/view/components/quick_info_tile.dart';
import 'package:school_app/home_screen/view/components/menu_tile.dart';

// ViewModel and Model Imports
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/model/home_screen_utils.dart';
import 'package:school_app/home_screen/view_model/home_viewmodel.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
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
  bool _hasLocationPermission = false;
  bool _checkingLocationPermission = true;

  @override
  void initState() {
    super.initState();
    try {
      loggedInUser = AuthViewModel.instance.getLoggedInUser();
      _loadHomeData();
    } catch (_) {}
    _initLocationPermissionCheck();
  }

  Future<void> _initLocationPermissionCheck() async {
    final status = await Permission.locationWhenInUse.status;
    if (mounted) {
      setState(() {
        _hasLocationPermission = status.isGranted;
        _checkingLocationPermission = false;
      });
    }
  }

  Future<void> _requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isPermanentlyDenied) {
      openAppSettings();
      return;
    }
    status = await Permission.locationWhenInUse.request();
    if (mounted) {
      setState(() {
        _hasLocationPermission = status.isGranted;
      });
    }
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
              return SophisticatedHUDBackground(child: _buildMainContent());
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
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 16, AppSpacing.lg, 16),
          sliver: SliverToBoxAdapter(child: _buildDashboardNavigationStrip()),
        ),

        if (_isDashboard) ...[
          // 2. Student Overview Card
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: StudentOverviewCard(
                name: 'Krish',
                className: 'XII-A',
                status: 'Present',
                avatarUrl: 'https://i.pravatar.cc/150?u=krish',
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 3. Transport Tracker
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: RepaintBoundary(
                child: TransportTrackerWidget(
                  hasPermission: _hasLocationPermission,
                  checkingPermission: _checkingLocationPermission,
                  onRequestPermission: _requestLocationPermission,
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 4. Attendance & Information
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: MidLevelCards(
                informationPoints: const [
                  'Science Fair registration open.',
                  'Holiday on 25th April.',
                  'Uniform check tomorrow.'
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 5. Fee Details Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(
              child: FeeDetailsCard(
                amountDue: '₹ 2,500',
                onPay: () {},
                onDetail: () {},
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 6. Daily Update Section
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(child: const DailyUpdateFeedWidget()),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // 7. Quick Access Tiles
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverToBoxAdapter(child: _buildQuickInfoTiles()),
          ),
        ] else
          ..._buildHomeSlivers(),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

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
            style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface),
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
              final title =
                  context.read<LanguageProvider>().translate(m.menuName ?? '');

              return MenuTile(
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
              Flexible(
                child: Text(
                  actionText, 
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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

  Widget _buildDashboardNavigationStrip() {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: ViewSwitch(
            isDashboard: _isDashboard,
            onChanged: (val) => setState(() => _isDashboard = val),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: InkWell(
            onTap: () => _selectDate(context),
            borderRadius: DashboardUtils.futuristicRadius,
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: DashboardUtils.futuristicDecoration(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_month_rounded, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      DateFormat('dd MMM yyyy').format(_selectedDate),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickInfoTiles() {
    return Row(
      children: [
        Expanded(
          child: QuickInfoTile(
            title: 'YouTube Video',
            subtitle: 'Latest School Event',
            icon: Icons.play_circle_fill_rounded,
            color: const Color(0xFFFF0000),
            onTap: () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: QuickInfoTile(
            title: 'Today History',
            subtitle: 'Academic logs',
            icon: Icons.history_rounded,
            color: const Color(0xFF2196F3),
            onTap: () {},
          ),
        ),
      ],
    );
  }
}
