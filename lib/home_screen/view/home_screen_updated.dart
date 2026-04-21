import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';

class HomeScreenUpdated extends StatefulWidget {
  const HomeScreenUpdated({super.key});

  @override
  State<HomeScreenUpdated> createState() => _HomeScreenUpdatedState();
}

class _HomeScreenUpdatedState extends State<HomeScreenUpdated> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
              ImageConstants.homeScreenBackground,
            ),
          ),
        ),
      ),
    );
  }
}
