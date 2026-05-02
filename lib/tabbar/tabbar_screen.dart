import 'package:flutter/material.dart';
import 'package:school_app/home_screen/view/home_screen.dart';
import 'package:school_app/admin_dashboard/view/admin_navigation_screen.dart';
import 'package:school_app/auth/view_model/auth.dart';

class TabbarScreen extends StatefulWidget {
  static const String routeName = '/tabbar';
  const TabbarScreen({super.key});

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  @override
  Widget build(BuildContext context) {
    final user = AuthViewModel.instance.getLoggedInUser();
    if (user?.userType == 'Admin' || user?.userType == 'Teacher') {
      return const AdminNavigationScreen();
    }
    return const HomeScreen();
  }
}
