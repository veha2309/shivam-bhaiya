import 'dart:math';

import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/tabbar/tabbar_screen.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class UserAuthScreen extends StatefulWidget {
  static const String routeName = '/user-auth';
  final User userToBeAuthenticated;

  const UserAuthScreen({super.key, required this.userToBeAuthenticated});

  @override
  State<UserAuthScreen> createState() => _UserAuthScreenState();
}

class _UserAuthScreenState extends State<UserAuthScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          popScreen(context);
        }
      },
      child: Scaffold(
        body: ValueListenableBuilder(
            valueListenable: isLoadingNotifier,
            builder: (context, value, _) {
              return Stack(
                children: [
                  AbsorbPointer(
                    absorbing: isLoadingNotifier.value,
                    child: getUserPasswordScreenBody(),
                  ),
                  if (value) getScreenLoaderWidget(),
                ],
              );
            }),
      ),
    );
  }

  Widget getUserPasswordScreenBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // School Logo
              Image.asset(
                ImageConstants.logoImagePath, // Replace with actual logo
                height: 100,
              ),
              const Text(
                'D-Block, Anand Vihar | F-Block, Preet Vihar',
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 14,
                  color: ColorConstant.primaryTextColor,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 30),

              // User Profile Image
              CircleAvatar(
                radius: min(getWidthOfScreen(context) / 2.5, 200),
                backgroundImage: NetworkImage(
                    widget.userToBeAuthenticated.profileImageUrl ??
                        ""), // Replace with actual user image
              ),

              const SizedBox(height: 30),
              // Welcome Message
              const Text(
                'WELCOME',
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: fontFamily,
                ),
              ),
              Text(
                widget.userToBeAuthenticated.name,
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ColorConstant.primaryColor,
                  fontFamily: fontFamily,
                ),
              ),
              const SizedBox(height: 4),
              // Show class and section for students
              if (widget.userToBeAuthenticated.userType.toLowerCase() ==
                      'student' &&
                  widget.userToBeAuthenticated.className != null &&
                  widget.userToBeAuthenticated.sectionName != null)
                Text(
                  '${widget.userToBeAuthenticated.className} - ${widget.userToBeAuthenticated.sectionName}',
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    fontSize: 16,
                    color: ColorConstant.primaryTextColor,
                    fontFamily: fontFamily,
                  ),
                ),
              const SizedBox(height: 30),

              AppButton(
                text: 'NEXT',
                onPressed:
                    (ValueNotifier<bool> updateButtonLoadingState) async {
                  await Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TabbarScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
