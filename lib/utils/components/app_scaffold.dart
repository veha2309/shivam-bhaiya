import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/utils/components/components.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class AppScaffold extends StatefulWidget {
  final Widget body;
  final ValueNotifier<bool>? isLoadingNotifier;
  final bool showBackButton;
  final String? background;
  final bool showAppBar;
  final String? studentName;

  const AppScaffold({
    super.key,
    required this.body,
    this.isLoadingNotifier,
    this.showBackButton = true,
    this.background,
    this.showAppBar = true,
    this.studentName,
  });

  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  late ValueNotifier<bool> isLoadingNotifier;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

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

  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          popScreen(context);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                widget.background ?? ImageConstants.homeScreenBackgroundOld),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Scaffold(
            drawer: widget.showAppBar ? const AppDrawer() : null,
            resizeToAvoidBottomInset: true,
            key: scaffoldKey,
            appBar: !widget.showAppBar
                ? null
                : getAppBar(context, scaffoldKey,
                    showBackButton: widget.showBackButton,
                    studentName: widget.studentName),
            backgroundColor: Colors.transparent,
            body: ValueListenableBuilder(
              valueListenable: isLoadingNotifier,
              child: getScreenLoaderWidget(),
              builder: (context, value, child) {
                return Stack(
                  children: [
                    AbsorbPointer(absorbing: value, child: widget.body),
                    if (value && child != null) child,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

Widget getScreenLoaderWidget() {
  return Positioned(
    child: Center(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: const [
            BoxShadow(blurRadius: 25.0, color: Colors.black45, spreadRadius: 1)
          ],
          color: Colors.white.withOpacity(1.0),
          borderRadius: BorderRadius.circular(10),
        ),
        height: 100,
        width: 100,
        child: LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
          colors: [
            ColorConstant.primaryColor,
            ColorConstant.primaryColor.withOpacity(0.5),
            ColorConstant.primaryColor.withOpacity(0.1),
          ],
          strokeWidth: 2,
        ),
      ),
    ),
  );
}

Widget getLoaderWidget() {
  return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    Center(
      child: SizedBox(
        height: 100,
        width: 100,
        child: LoadingIndicator(
          indicatorType: Indicator.ballSpinFadeLoader,
          colors: [
            ColorConstant.primaryColor,
            ColorConstant.primaryColor.withOpacity(0.5),
            ColorConstant.primaryColor.withOpacity(0.1),
          ],
          strokeWidth: 2,
        ),
      ),
    ),
  ]);
}
