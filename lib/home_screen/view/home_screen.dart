import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/home_screen_utils.dart';

// Component Imports
import 'package:school_app/home_screen/view/dashboard_view.dart';
import 'package:school_app/home_screen/view/components/hud_background.dart';
import 'package:school_app/home_screen/view/components/view_switch.dart';
import 'package:school_app/home_screen/view/components/home_overview.dart';
import 'package:school_app/home_screen/view/components/dashboard_utils.dart';

// ViewModel and Model Imports
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/view_model/home_viewmodel.dart';
import 'package:school_app/home_screen/view_model/dashboard_viewmodel.dart';
import 'package:school_app/utils/app_theme.dart';
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HomeViewmodel.instance.fetchHomeDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: HomeViewmodel.instance),
        ChangeNotifierProvider(create: (_) => DashboardViewModel()),
      ],
      child: Consumer2<HomeViewmodel, DashboardViewModel>(
        builder: (context, homeVm, dashVm, child) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) async {
              if (didPop) return;
              if (dashVm.isDashboard) {
                dashVm.toggleView(false);
              } else {
                SystemNavigator.pop();
              }
            },
            child: AppScaffold(
              isLoadingNotifier: ValueNotifier(homeVm.isLoading),
              showBackButton: false,
              showAppBar: true,
              body: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () => homeVm.fetchHomeDetail(),
                child: _buildBody(context, homeVm, dashVm),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, HomeViewmodel homeVm, DashboardViewModel dashVm) {
    context.watch<LanguageProvider>();
    
    if (homeVm.homeModel == null && !homeVm.isLoading) {
      return const NoDataWidget();
    }

    return SophisticatedHUDBackground(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 16, AppSpacing.lg, 16),
            sliver: SliverToBoxAdapter(
              child: _buildNavigationStrip(context, dashVm),
            ),
          ),

          if (dashVm.isDashboard)
            const SliverToBoxAdapter(child: DashboardView())
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: HomeOverview(
                  homeModel: homeVm.homeModel,
                  menuDetails: homeVm.homeModel?.menuDetails ?? const [],
                  onNavigate: (m) => _navigate(context, m),
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildNavigationStrip(BuildContext context, DashboardViewModel dashVm) {
    return Row(
      children: [
        Expanded(
          flex: 6,
          child: ViewSwitch(
            isDashboard: dashVm.isDashboard,
            onChanged: (val) => dashVm.toggleView(val),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: InkWell(
            onTap: () => _selectDate(context, dashVm),
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
                      DateFormat('dd MMM yyyy').format(dashVm.selectedDate),
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

  Future<void> _selectDate(BuildContext context, DashboardViewModel dashVm) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dashVm.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      dashVm.setSelectedDate(picked);
    }
  }

  void _navigate(BuildContext context, MenuDetail m) {
    final dest = navigateToMenuDestination(m, title: m.menuName);
    if (dest != null) {
      navigateToScreen(context, dest);
    }
  }
}