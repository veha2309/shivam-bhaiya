import 'package:flutter/material.dart';
import 'package:school_app/home_screen/view/home_screen.dart';

class TabbarScreen extends StatefulWidget {
  static const String routeName = '/tabbar';
  const TabbarScreen({super.key});

  @override
  State<TabbarScreen> createState() => _TabbarScreenState();
}

class _TabbarScreenState extends State<TabbarScreen> {
  // int index = 0;

  // int _selectedIndex = 0;

  // final List<Widget> _pages = [
  //   const HomeScreen(),
  //   const Scaffold(),
  //   const SettingsScreen(),
  // ];

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
    // Scaffold(
    //   body: _pages[_selectedIndex],
    //   bottomNavigationBar: BottomNavigationBar(
    //     currentIndex: _selectedIndex,
    //     onTap: _onItemTapped,
    //     backgroundColor: ColorConstant.backgroundColor,
    //     selectedItemColor: ColorConstant.primaryColor,
    //     unselectedItemColor: ColorConstant.inactiveColor,
    //     items: const [
    //       BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.question_answer), label: 'Query'),
    //       BottomNavigationBarItem(
    //           icon: Icon(Icons.settings), label: 'Settings'),
    //     ],
    //   ),
    // );
  }
}
