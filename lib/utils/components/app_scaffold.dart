// File: lib/utils/components/app_scaffold.dart
// REDESIGNED: Modern scaffold supporting custom bottom navigation and frosted glass effects
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/admin_dashboard/view/components/admin_drawer.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/components/custom_bottom_nav.dart';
import 'package:school_app/utils/utils.dart';

final class AppScaffold extends StatefulWidget {
  final Widget body;
  final ValueNotifier<bool>? isLoadingNotifier;
  final bool showBackButton;
  final bool showAppBar;
  final bool showDrawer;
  final String? studentName;
  final int? currentNavIndex;
  final Function(int)? onNavTap;
  final Widget? appBarTitle;
  final String? activeDrawerItem;

  const AppScaffold({
    super.key,
    required this.body,
    this.isLoadingNotifier,
    this.showBackButton = true,
    this.showAppBar = true,
    this.showDrawer = true,
    this.studentName,
    this.currentNavIndex,
    this.onNavTap,
    this.appBarTitle,
    this.activeDrawerItem,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late ValueNotifier<bool> isLoadingNotifier;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    isLoadingNotifier = widget.isLoadingNotifier ?? ValueNotifier(false);
  }

  @override
  void didUpdateWidget(AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    isLoadingNotifier = widget.isLoadingNotifier ?? ValueNotifier(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.surface,
        extendBody: true,
        resizeToAvoidBottomInset: true,
        drawer: widget.showDrawer
            ? (AuthViewModel.instance.getLoggedInUser()?.userType == 'Admin' ||
                    AuthViewModel.instance.getLoggedInUser()?.userType == 'Teacher'
                ? AdminDrawer(activeItem: widget.activeDrawerItem)
                : const AppDrawer())
            : null,
        appBar: !widget.showAppBar
            ? null
            : getAppBar(
                context,
                scaffoldKey,
                showBackButton: widget.showBackButton,
                studentName: widget.studentName,
                title: widget.appBarTitle,
              ),
        body: ValueListenableBuilder<bool>(
          valueListenable: isLoadingNotifier,
          child: getScreenLoaderWidget(),
          builder: (context, isLoading, loaderChild) {
            return Stack(
              children: [
                AbsorbPointer(absorbing: isLoading, child: widget.body),
                if (isLoading && loaderChild != null) loaderChild,
              ],
            );
          },
        ),
      );
  }
}

// REDESIGNED: Frosted glass loader card
Widget getScreenLoaderWidget() {
  return Positioned.fill(
    child: Center(
      child: ClipRRect(
        borderRadius: AppRadius.xlRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: AppRadius.xlRadius,
              boxShadow: AppShadows.medium,
              border: Border.all(color: AppColors.outlineVariant.withOpacity(0.2)),
            ),
            child: Center(
              child: LoadingIndicator(
                indicatorType: Indicator.ballSpinFadeLoader,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withOpacity(0.6),
                  AppColors.darkTeal.withOpacity(0.4),
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

Widget getLoaderWidget() {
  return Center(
    child: SizedBox(
      height: 60, width: 60,
      child: LoadingIndicator(
        indicatorType: Indicator.ballSpinFadeLoader,
        colors: [
          AppColors.primary,
          AppColors.primary.withOpacity(0.5),
        ],
        strokeWidth: 2,
      ),
    ),
  );
}