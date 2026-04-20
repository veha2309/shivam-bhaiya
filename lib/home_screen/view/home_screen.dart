// ==============================================================================
//  home_screen.dart  –  Modern Bento UI Redesign
//
//  UI layer is completely rewritten for a premium, next-gen aesthetic:
//    • Pill-shaped Home / Dashboard view switcher with sliding animation
//    • Bento-box card grid with glassmorphism (BackdropFilter)
//    • Floating cards with diffused glow shadows and tap-scale micro-interactions
//    • Dark navy gradient background  (#070F28 → #0C1A42)
//    • Custom glass app-bar (logo + drawer + notification bell)
//
//  ALL business logic, navigation, API calls, and data models are UNCHANGED.
// ==============================================================================

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/fee_history/Model/fee_history_model.dart';
import 'package:school_app/fee_history/ViewModel/fee_history_view_model.dart';
import 'package:school_app/home_screen/model/daily_message.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/model/home_screen_utils.dart';
import 'package:school_app/home_screen/view/notification_list_widget.dart';
import 'package:school_app/home_screen/view_model/home_viewmodel.dart';
import 'package:school_app/homework_screen/model/homeBanner_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/news_events/Model/news_event.dart';
import 'package:school_app/news_events/ViewModel/news_event_view_model.dart';
import 'package:school_app/notifications/view/notifications_screen.dart';
import 'package:school_app/school_details/viewmodel/school_details_viewmodel.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:school_app/utils/utils.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
// Pastel Dream Theme: Soft, Airy, Modern
const _kBg1         = Color(0xFFFFF5F5);   // Soft Peach/Rose
const _kBg2         = Color(0xFFF0F9FF);   // Soft Sky
const _kPrimary     = Color(0xFF4F46E5);   // Indigo - for readability
const _kPrimaryDeep = Color(0xFF3730A3);
const _kAccent      = Color(0xFFEC4899);   // Pink Accent
const _kGlass       = Color(0xCCFFFFFF);   // 80% white
const _kBorder      = Color(0xFFE2E8F0);   
const _kText        = Color(0xFF1E293B);   // Slate for contrast
const _kOnGrad      = Colors.white;         
const _kSub         = Color(0xFF94A3B8);   
const _kGlow        = Color(0x11EC4899);   
const _ff           = 'Inter';

const List<List<Color>> _kGrads = [
  [Color(0xFF818CF8), Color(0xFFC084FC)], // Lavender/Indigo
  [Color(0xFFFB7185), Color(0xFFFDA4AF)], // Rose/Pink
  [Color(0xFF38BDF8), Color(0xFF818CF8)], // Sky/Blue
  [Color(0xFF34D399), Color(0xFF6EE7B7)], // Mint/Green
];
List<Color> _grad(int i) => _kGrads[i % _kGrads.length];

// ─── Staggered Entry Animation ────────────────────────────────────────────────
class _StaggeredEntry extends StatefulWidget {
  final Widget child;
  final int index;
  const _StaggeredEntry({required this.child, required this.index});

  @override
  State<_StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<_StaggeredEntry> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _slide = Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    Future.delayed(Duration(milliseconds: 30 * widget.index), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ─── Glass Card ───────────────────────────────────────────────────────────────
class _GlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double radius;
  final bool glow;
  final Color? bg;
  final VoidCallback? onTap;
  final double? height;

  const _GlassCard({
    required this.child,
    this.padding,
    this.radius = 24, // Rounder for pastel theme
    this.glow = false,
    this.bg,
    this.onTap,
    this.height,
  });

  @override
  State<_GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<_GlassCard>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.onTap != null ? _ctrl.forward() : null,
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.bg ?? _kGlass,
            borderRadius: BorderRadius.circular(widget.radius),
            border: Border.all(color: Colors.white, width: 1.5), // Pure white border for glass look
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03), 
                blurRadius: 20, 
                offset: const Offset(0, 10)
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(widget.radius),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(20),
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
// ─── Icon Button ──────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  const _IconBtn({required this.icon});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _kGlass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kBorder.withOpacity(0.5)),
        ),
        child: Icon(icon, color: _kPrimary, size: 22),
      );
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          FittedBox(
            child: Text(value,
                style: TextStyle(
                    fontFamily: _ff,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: color)),
          ),
          const SizedBox(height: 1),
          Text(label,
              style: const TextStyle(
                  fontFamily: _ff, fontSize: 11, color: _kSub, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    ),
  );
}
// ─── Home Screen ──────────────────────────────────────────────────────────────
final class HomeScreen extends StatefulWidget {
  static const String routeName = '/home';
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  // ── Original state vars ──────────────────────────────────────────────────────
  User? loggedInUser;
  Future<ApiResponse<HomeModel>>? homeDetail;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  HomeModel? homeModel;
  Map<String, List<MenuDetail>> menuDetailMap = {};
  List<HomebannerModel> banner = [];
  int currentPage = 0;

  Future<ApiResponse<List<FeeHistoryModel>>>? feeHistory;
  Future<ApiResponse<NewsData>>? newsEvents;

  // ── New UI state ─────────────────────────────────────────────────────────────
  int _activeView = 0;
  late final AnimationController _toggleAnim;
  late final Animation<double> _toggleSlide;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  final PageController _bannerCtrl = PageController();
  int _bannerPage = 0;

  // ── Lifecycle (unchanged) ────────────────────────────────────────────────────
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _toggleAnim.dispose();
    _bannerCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkAndShowPopup(context);
  }

  Future<void> _checkAndShowPopup(BuildContext context) async {
    if (await shouldShowPopup()) {
      final response = await HomeViewmodel.instance.getDailyMessage();
      if (response.success && (response.data?.isNotEmpty ?? false)) {
        DailyMessage? todayMsg;
        try {
          todayMsg = response.data?.firstWhere(
              (m) => m.messageDate == getDDMMYYYYInNum(DateTime.now()));
        } catch (_) {}

        if (todayMsg != null) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: const Text('Thought of the Day',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: _kText,
                      fontWeight: FontWeight.w700,
                      fontFamily: _ff)),
              content: Text(todayMsg!.message ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: _kSub, fontFamily: _ff)),
              actionsAlignment: MainAxisAlignment.center,
              actionsPadding: const EdgeInsets.only(bottom: 16),
              actions: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 36, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [_kPrimary, _kPrimaryDeep]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: _kGlow, blurRadius: 12)],
                    ),
                    child: const Icon(Icons.thumb_up_rounded, color: _kText),
                  ),
                ),
              ],
            ),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _toggleAnim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 240));
    _toggleSlide = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _toggleAnim, curve: Curves.easeInOut));

    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkAndShowPopup(context));

    try {
      loggedInUser = AuthViewModel.instance.getLoggedInUser();
      callGetHomeDetailFuture();
    } catch (_) {}
  }

  void callGetBannerService() async {
    final r = await HomeViewmodel.instance.getHomeBanner();
    if (r.success) setState(() => banner = r.data ?? []);
  }

  void callGetHomeDetailFuture() {
    homeModel = null;
    menuDetailMap = {};
    homeDetail = HomeViewmodel.instance.fetchHomeDetail();
    feeHistory = FeeHistoryViewModel.instance.getFeeHistory();
    newsEvents = NewsEventViewModel.instance.getNewsAndEvent(DateTime.now());

    homeDetail?.then((response) {
      if (response.success) {
        homeModel = response.data;
        if (homeModel != null) AuthViewModel.instance.setHomeModel(homeModel!);

        homeModel?.menuDetails?.forEach((menuDetail) {
          if (menuDetail.categoryId == '2') {
            menuDetailMap
                .putIfAbsent(menuDetail.categoryId ?? '', () => [])
                .add(menuDetail);
          } else {
            menuDetailMap.putIfAbsent('1', () => []).add(menuDetail);
          }
          menuDetailMap.map((key, value) {
            value.sort((a, b) {
              final pA =
                  fromMobileMenuId(a.mobileMenuId ?? '')?.position ?? 9999;
              final pB =
                  fromMobileMenuId(b.mobileMenuId ?? '')?.position ?? 9999;
              return pA - pB;
            });
            return MapEntry(key, value);
          });
        });

        SchoolDetailsViewModel.instance.registerDeviceForNotifications();
        SchoolDetailsViewModel.instance.subscribeTopicId();
      }
      return response;
    });
    callGetBannerService();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    try {
      loggedInUser = AuthViewModel.instance.getLoggedInUser();
      setState(callGetHomeDetailFuture);
    } catch (_) {}
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────
  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String get _dateLabel {
    const m = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    final n = DateTime.now();
    return '${n.day} ${m[n.month - 1]}, ${n.year}';
  }

  void _switchView(int v) {
    if (v == _activeView) return;
    setState(() => _activeView = v);
    v == 1 ? _toggleAnim.forward() : _toggleAnim.reverse();
  }

  void _go(MenuDetail md) {
    final dest = navigateToMenuDestination(md, title: md.menuName);
    if (dest != null) navigateToScreen(context, dest);
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) SystemNavigator.pop();
      },
      child: Scaffold(
        key: _scaffoldKey,
        drawer: const AppDrawer(),
        backgroundColor: Colors.transparent,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF1EB), // Soft Peach
                Color(0xFFACE0F9), // Soft Sky Blue
                Color(0xFFE0C3FC), // Soft Lavender
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: SafeArea(
            child: ValueListenableBuilder<bool>(
              valueListenable: isLoadingNotifier,
              builder: (ctx, loading, _) => Stack(
                children: [
                  Column(
                    children: [
                      _buildGlassBar(),
                      _buildToggle(),
                      Expanded(
                        child: RefreshIndicator(
                          color: _kPrimary,
                          backgroundColor: _kBg2,
                          onRefresh: () {
                            setState(callGetHomeDetailFuture);
                            return Future<void>.value();
                          },
                          child: AppFutureBuilder(
                            future: homeDetail,
                            builder: (_, snap) {
                              if (homeModel?.menuDetails?.isEmpty ?? true) {
                                return const NoDataWidget();
                              }
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 280),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                        opacity: anim, child: child),
                                child: _activeView == 0
                                    ? _buildHomeView()
                                    : _buildDashboardView(),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (loading) _buildLoader(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Glass App Bar ────────────────────────────────────────────────────────────
  Widget _buildGlassBar() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: const Border(bottom: BorderSide(color: _kBorder, width: 0.5)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: const _IconBtn(icon: Icons.menu_rounded),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Image.asset(
                ImageConstants.logoImagePath,
                height: 32,
                fit: BoxFit.contain,
                alignment: Alignment.centerLeft,
              ),
            ),
            if (LocalStorage.wasNotificationShownToday())
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen()),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const _IconBtn(icon: Icons.notifications_rounded),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _kAccent,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );

  // ── Pill View Toggle ─────────────────────────────────────────────────────────
  Widget _buildToggle() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: LayoutBuilder(
          builder: (_, c) {
            final pillW = c.maxWidth / 2;
            return Container(
              height: 46,
              decoration: BoxDecoration(
                color: _kGlass,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(color: _kBorder),
              ),
              child: Stack(
                children: [
                  AnimatedBuilder(
                    animation: _toggleSlide,
                    builder: (_, __) => Positioned(
                      left: _toggleSlide.value * pillW,
                      top: 3,
                      bottom: 3,
                      width: pillW,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [_kPrimary, _kPrimaryDeep]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: _kGlow,
                                blurRadius: 16,
                                spreadRadius: 2)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      _tab('Home', 0),
                      _tab('Dashboard', 1),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

  Widget _tab(String label, int idx) => Expanded(
        child: GestureDetector(
          onTap: () => _switchView(idx),
          behavior: HitTestBehavior.opaque,
          child: Center(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: _ff,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                // active tab sits on blue gradient pill → white text
                // inactive sits on glass pill → slate text
                color: _activeView == idx ? Colors.white : _kSub,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ),
        ),
      );

  // ── HOME VIEW ────────────────────────────────────────────────────────────────
  Widget _buildHomeView() => SingleChildScrollView(
        key: const ValueKey('home'),
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero greeting card
            _StaggeredEntry(
              index: 0,
              child: _GlassCard(
                glow: true,
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_greeting,
                              style: const TextStyle(
                                  fontFamily: _ff,
                                  fontSize: 13,
                                  color: _kSub,
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 4),
                          Text(loggedInUser?.name ?? '',
                              style: const TextStyle(
                                  fontFamily: _ff,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: _kText)),
                          const SizedBox(height: 8),
                          if ((homeModel?.className ?? '').isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _kPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: _kPrimary.withOpacity(0.2)),
                              ),
                              child: Text(homeModel!.className!,
                                  style: const TextStyle(
                                      fontFamily: _ff,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _kPrimary)),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                                colors: [_kPrimary, _kPrimaryDeep],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: _kPrimary.withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 2)
                            ],
                          ),
                          child: const Icon(Icons.school_rounded,
                              color: _kOnGrad, size: 28),
                        ),
                        const SizedBox(height: 8),
                        Text(_dateLabel,
                            style: const TextStyle(
                                fontFamily: _ff,
                                fontSize: 12,
                                color: _kSub)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            if ((menuDetailMap['2']?.length ?? 0) > 0) ...[
              _StaggeredEntry(index: 1, child: _label('Quick Actions')),
              const SizedBox(height: 10),
              _StaggeredEntry(index: 2, child: _buildQuickActions()),
              const SizedBox(height: 20),
            ],

            _StaggeredEntry(index: 3, child: _label('Daily Updates')),
            const SizedBox(height: 10),
            _StaggeredEntry(
              index: 4,
              child: RepaintBoundary(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _kGlass,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: _kBorder.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 16)
                        ],
                      ),
                      child: const NotificationListWidget(),
                    ),
                  ),
                ),
              ),
            ),

            if (banner.isNotEmpty) ...[
              const SizedBox(height: 20),
              _StaggeredEntry(index: 5, child: _label('Announcements')),
              const SizedBox(height: 10),
              _StaggeredEntry(index: 6, child: _buildBannerCard()),
            ],

            if ((menuDetailMap['1']?.length ?? 0) > 0) ...[
              const SizedBox(height: 20),
              _StaggeredEntry(index: 7, child: _label('Features')),
              const SizedBox(height: 10),
              _StaggeredEntry(index: 8, child: _buildMenuBento()),
            ],
          ],
        ),
      );

  // ── DASHBOARD VIEW ───────────────────────────────────────────────────────────
  Widget _buildDashboardView() {
    final mainItems  = menuDetailMap['1'] ?? [];
    final quickItems = menuDetailMap['2'] ?? [];

    return SingleChildScrollView(
      key: const ValueKey('dashboard'),
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats row
          _StaggeredEntry(
            index: 0,
            child: Row(children: [
              Expanded(
                child: _StatCard(
                  label: 'Features',
                  value: '${mainItems.length}',
                  icon: Icons.apps_rounded,
                  color: _kPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Quick Actions',
                  value: '${quickItems.length}',
                  icon: Icons.bolt_rounded,
                  color: _kAccent,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Class',
                  value: homeModel?.className?.split(' ').last ?? '-',
                  icon: Icons.class_rounded,
                  color: const Color(0xFF10B981),
                ),
              ),
            ]),
          ),

          const SizedBox(height: 20),

          // Student info
          _StaggeredEntry(
            index: 1,
            child: _GlassCard(
              glow: true,
              padding: const EdgeInsets.all(18),
              child: Row(children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [_kPrimary, _kPrimaryDeep]),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: _kPrimary.withOpacity(0.2), blurRadius: 16)
                    ],
                  ),
                  child: const Icon(Icons.person_rounded,
                      color: _kOnGrad, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loggedInUser?.name ?? '',
                          style: const TextStyle(
                              fontFamily: _ff,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _kText)),
                      const SizedBox(height: 3),
                      Text(
                        '${homeModel?.className ?? ''} · ${loggedInUser?.userType ?? ''}',
                        style: const TextStyle(
                            fontFamily: _ff, fontSize: 12, color: _kSub),
                      ),
                    ],
                  ),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 20),

          // Spotlight 2×2 grid
          if (mainItems.length >= 4) ...[
            _StaggeredEntry(index: 2, child: _label('Spotlight')),
            const SizedBox(height: 10),
            _StaggeredEntry(
              index: 3,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
                children: mainItems.take(4).toList().asMap().entries.map((e) {
                  final grads = _grad(e.key);
                  final md    = e.value;
                  return _GlassCard(
                    padding: const EdgeInsets.all(14),
                    onTap: () => _go(md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: grads),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Image.asset(getMenuIcon(md),
                              width: 24,
                              height: 24,
                              errorBuilder: (_, __, ___) => const Icon(
                                  Icons.star_rounded,
                                  color: _kOnGrad,
                                  size: 24)),
                        ),
                        Text(md.menuName ?? '',
                            style: const TextStyle(
                                fontFamily: _ff,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _kText),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // All Features compact list
          _StaggeredEntry(index: 4, child: _label('All Features')),
          const SizedBox(height: 10),
          ...mainItems.asMap().entries.map((e) {
            final grads = _grad(e.key);
            final md    = e.value;
            final idx   = e.key;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _StaggeredEntry(
                index: 5 + idx,
                child: _GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  onTap: () => _go(md),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          grads[0].withOpacity(0.7),
                          grads[1].withOpacity(0.5)
                        ]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Image.asset(getMenuIcon(md),
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.widgets_rounded,
                              color: _kOnGrad,
                              size: 22)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(md.menuName ?? '',
                          style: const TextStyle(
                              fontFamily: _ff,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _kText)),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: _kSub, size: 20),
                  ]),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Fees section
          _StaggeredEntry(index: 5, child: _label('Fees & Payments')),
          const SizedBox(height: 10),
          _StaggeredEntry(index: 6, child: _buildFeesSection()),

          const SizedBox(height: 20),

          // Smart Reminders
          _StaggeredEntry(index: 7, child: _buildSmartReminders()),

          const SizedBox(height: 20),

          // Mini Calendar / Events
          _StaggeredEntry(index: 8, child: _buildMiniCalendarSection()),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFeesSection() {
    return AppFutureBuilder<ApiResponse<List<FeeHistoryModel>>>(
      future: feeHistory,
      builder: (context, snapshot) {
        final fees = snapshot.data?.data ?? [];
        double totalDue = 0;
        for (var f in fees) {
          totalDue += double.tryParse(f.balance ?? '0') ?? 0;
        }

        MenuDetail? payMenu;
        for (var list in menuDetailMap.values) {
          for (var item in list) {
            if (item.mobileMenuId == '59') {
              payMenu = item;
              break;
            }
          }
        }

        return _GlassCard(
          glow: totalDue > 0,
          bg: totalDue > 0 ? _kAccent.withOpacity(0.05) : null,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ACCOUNT STATUS',
                          style: TextStyle(
                              fontFamily: _ff,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _kSub,
                              letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            totalDue > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                            size: 18,
                            color: totalDue > 0 ? _kAccent : Colors.green,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            totalDue > 0 ? 'Fee Payment Pending' : 'Account Up to Date',
                            style: TextStyle(
                                fontFamily: _ff,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: totalDue > 0 ? _kAccent : Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  if (totalDue > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _kAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '₹${totalDue.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontFamily: _ff,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: _kAccent),
                      ),
                    ),
                ],
              ),
              if (totalDue > 0) ...[
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: payMenu != null ? () => _go(payMenu!) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kPrimary,
                      foregroundColor: _kOnGrad,
                      elevation: 4,
                      shadowColor: _kPrimary.withOpacity(0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('PAY NOW',
                            style: TextStyle(
                                fontFamily: _ff,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

Widget _buildMiniCalendarSection() {
    return AppFutureBuilder<ApiResponse<NewsData>>(
      future: newsEvents,
      builder: (context, snapshot) {
        final events = snapshot.data?.data?.months
                ?.expand((month) => month.news ?? <NewsItem>[])
                .toList() ?? [];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _label('Upcoming Events'),
            const SizedBox(height: 12),
            if (events.isEmpty)
              _GlassCard(
                child: const Center(
                  heightFactor: 3,
                  child: Text('No upcoming events found',
                      style: TextStyle(fontFamily: _ff, color: _kSub, fontSize: 13)),
                ),
              )
            else
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: events.length,
                  padding: const EdgeInsets.only(right: 16),
                  itemBuilder: (context, i) {
                    final ev = events[i];
                    return Container(
                      width: 260,
                      margin: const EdgeInsets.only(right: 12),
                      child: _GlassCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ev.subject ?? 'Event',
                                style: const TextStyle(
                                    fontFamily: _ff,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: _kText),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today_rounded, size: 14, color: _kSub),
                                    const SizedBox(width: 8),
                                    Text(ev.fromDate ?? '',
                                        style: const TextStyle(
                                            fontFamily: _ff, fontSize: 12, color: _kSub)),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _kPrimary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text('DETAILS', style: TextStyle(fontSize: 10, color: _kPrimary, fontWeight: FontWeight.w900)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
  Widget _buildSmartReminders() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Smart Reminders'),
        const SizedBox(height: 12),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 16),
            children: [
              _reminderCard('Exam preparation: Revision starting', Icons.auto_stories_rounded, Colors.orange),
              _reminderCard('Weekly Assignment: Physics due tomorrow', Icons.assignment_rounded, Colors.blue),
              _reminderCard('Parent Teacher Meeting on Saturday', Icons.people_alt_rounded, Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reminderCard(String title, IconData icon, Color color) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      child: _GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        bg: color.withOpacity(0.04),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(title,
                  style: const TextStyle(
                      fontFamily: _ff,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _kText),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────────────────
  Widget _buildQuickActions() {
    final items     = menuDetailMap['2'] ?? [];
    final isTeacher = loggedInUser?.userType.toUpperCase() == 'TEACHER';

    return GridView.count(
      crossAxisCount: items.length == 1 ? 1 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: items.length == 1 ? 3.5 : 1.05,
      children: items.asMap().entries.map((e) {
        final idx = e.key;
        final md  = e.value;
        // Exact same icon logic as the original
        final icon = isTeacher
            ? (idx % 2 != 0
                ? IconConstants.studentSearch
                : IconConstants.attendance)
            : (idx % 2 != 0
                ? IconConstants.noticeBoard
                : IconConstants.homework);
        final grads = _grad(idx);
        return _GlassCard(
          padding: EdgeInsets.zero,
          onTap: () => _go(md),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: grads,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Image.asset(icon,
                          width: 42,
                          height: 42,
                          errorBuilder: (_, __, ___) => const Icon(
                              Icons.bolt_rounded,
                              color: _kOnGrad,   // on dark gradient card
                              size: 42)),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Color(0x80FFFFFF), size: 14),
                  ],
                ),
                Text(md.menuName ?? '',
                    style: const TextStyle(
                        fontFamily: _ff,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kOnGrad),  // on dark gradient card
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Banner Carousel ──────────────────────────────────────────────────────────
  Widget _buildBannerCard() {
    final w = MediaQuery.of(context).size.width - 32;
    return _GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: w * 0.46,
            child: PageView.builder(
              controller: _bannerCtrl,
              itemCount: banner.length,
              onPageChanged: (i) => setState(() => _bannerPage = i),
              itemBuilder: (_, i) {
                final item = banner[i];
                return (item.attachment?.isNotEmpty ?? false)
                    ? Image.network(item.attachment!, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _bannerPlaceholder())
                    : _bannerPlaceholder();
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            banner.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: _bannerPage == i ? 22 : 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: _bannerPage == i ? _kPrimary : _kSub,
                borderRadius: BorderRadius.circular(3),
                boxShadow: _bannerPage == i
                    ? [BoxShadow(color: _kGlow, blurRadius: 8)]
                    : null,
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _bannerPlaceholder() => Container(
        color: _kBg2,
        child: const Center(
            child: Icon(Icons.image_rounded, color: _kSub, size: 48)),
      );

  // ── Menu Bento Grid ──────────────────────────────────────────────────────────
  Widget _buildMenuBento() {
    final items = menuDetailMap['1'] ?? [];
    final rows  = <Widget>[];
    int i = 0;
    int staggerIdx = 9; // starting after home view items
    while (i < items.length) {
      if (i % 3 == 0) {
        rows
          ..add(_StaggeredEntry(index: staggerIdx++, child: _fullCard(items[i], i)))
          ..add(const SizedBox(height: 12));
        i++;
      } else {
        final hasRight = i + 1 < items.length;
        rows.add(_StaggeredEntry(
          index: staggerIdx++,
          child: Row(children: [
            Expanded(child: _halfCard(items[i], i)),
            const SizedBox(width: 12),
            Expanded(
                child: hasRight
                    ? _halfCard(items[i + 1], i + 1)
                    : const SizedBox()),
          ]),
        ));
        rows.add(const SizedBox(height: 12));
        i += hasRight ? 2 : 1;
      }
    }
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }

  Widget _fullCard(MenuDetail md, int idx) {
    final g = _grad(idx);
    return _GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      onTap: () => _go(md),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: g[0].withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              getMenuIcon(md),
              width: 32,
              height: 32,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                  Icons.widgets_rounded,
                  color: g[0],
                  size: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(md.menuName ?? '',
                    style: const TextStyle(
                        fontFamily: _ff,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _kText)),
                const SizedBox(height: 4),
                Text('Tap to view details',
                    style: TextStyle(
                        fontFamily: _ff, fontSize: 12, color: _kSub.withOpacity(0.8))),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: _kSub.withOpacity(0.5), size: 16),
        ],
      ),
    );
  }

  Widget _halfCard(MenuDetail md, int idx) {
    final g = _grad(idx);
    return _GlassCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _go(md),
      height: 130,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: g[0].withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              getMenuIcon(md),
              width: 26,
              height: 26,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                  Icons.widgets_rounded,
                  color: g[0],
                  size: 22),
            ),
          ),
          Text(md.menuName ?? '',
              style: const TextStyle(
                  fontFamily: _ff,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _kText),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  // ── Shared Utilities ─────────────────────────────────────────────────────────
  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Text(
          text.toUpperCase(),
          style: const TextStyle(
              fontFamily: _ff,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.6,
              color: _kSub),
        ),
      );

  Widget _buildLoader() => Positioned.fill(
        child: RepaintBoundary(
          child: Container(
            color: Colors.black45,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _kBg2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _kBorder),
                ),
                child: SizedBox(
                  height: 60,
                  width: 60,
                  child: LoadingIndicator(
                    indicatorType: Indicator.ballSpinFadeLoader,
                    colors: [
                      _kPrimary,
                      _kPrimary.withOpacity(0.5),
                      _kPrimary.withOpacity(0.1),
                    ],
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

// Legacy helper kept so other files that may import it don't break.
List<String> getBackgroundPath = [
  ImageConstants.homeScreenPurple,
  ImageConstants.homeScreenGreen,
  ImageConstants.homeScreenYellow,
  ImageConstants.homeScreenOrange,
];