import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:provider/provider.dart';

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

  List<Widget> _buildDashboardSlivers() {
    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.xlRadius,
              boxShadow: AppShadows.soft,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Attendance Tracker", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.onSurface)),
                    const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 20),
                const CalendarStrip(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: const [
                    _DashStat(label: 'Present', value: '22', color: AppColors.primary),
                    _DashStat(label: 'Absent', value: '02', color: Colors.orange),
                    _DashStat(label: 'Late', value: '01', color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        sliver: SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.xlRadius,
              boxShadow: AppShadows.medium,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text("Fee Summary", style: GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Outstanding Balance", style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                        const SizedBox(height: 4),
                        Text("₹ 12,450", style: GoogleFonts.plusJakartaSans(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        shape: StadiumBorder(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: Text("Pay Now", style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24),
                const SizedBox(height: 12),
                Text("Next Due: May 15, 2026", style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    ];
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
      
      // Diversified Tiles Section
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
      
      // GRID for top 4 items
      if (listItems.length >= 4)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final m = listItems[i];
                return SquareGridComponent(
                  title: context.read<LanguageProvider>().translate(m.menuName ?? ''),
                  icon: getMenuIcon(m),
                  onTap: () => _navigate(m),
                );
              },
              childCount: 4,
            ),
          ),
        ),
      
      const SliverToBoxAdapter(child: SizedBox(height: 16)),
      
      // LIST for the rest
      if (listItems.length > 4)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList.separated(
            itemCount: listItems.length - 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final m = listItems[i + 4];
              return RectangleTileComponent(
                title: context.read<LanguageProvider>().translate(m.menuName ?? ''),
                icon: getMenuIcon(m),
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
}

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

class _DashStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _DashStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
      ],
    );
  }
}