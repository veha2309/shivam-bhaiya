import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/auth/view/school_code_screen.dart';
import 'package:school_app/main_navigation_screen.dart';
import 'package:school_app/admin_dashboard/view/admin_navigation_screen.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class LandingScreen extends StatefulWidget {
  static const String routeName = '/landing';
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  User? user;

  @override
  void initState() {
    super.initState();

    try {
      user = AuthViewModel.instance.getLoggedInUser();
    } catch (_) {}

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (user != null) {
        if (user?.userType == 'Admin' || user?.userType == 'Teacher') {
          navigateToScreen(context, const AdminNavigationScreen(), replace: true);
        } else {
          navigateToScreen(context, const MainNavigationScreen(), replace: true);
        }
      } else {
        navigateToScreen(context, const SchoolCodeScreen(),
            replace: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          popScreen(context);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstants.homeScreenBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Image.asset(
                ImageConstants.logoImagePath,
                height: 100,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
