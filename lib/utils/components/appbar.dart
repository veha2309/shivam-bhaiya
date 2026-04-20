import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/notifications/view/notifications_screen.dart';

import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:school_app/utils/utils.dart';

AppBar getAppBar(BuildContext context, GlobalKey<ScaffoldState> scaffoldKey,
    {bool showBackButton = true, String? studentName}) {
  User? loggedInUser = AuthViewModel.instance.getLoggedInUser();
  return AppBar(
    backgroundColor: Colors.transparent,
    leading: InkWell(
      onTap: () {
        if (showBackButton) {
          popScreen(context);
        } else {
          scaffoldKey.currentState!.openDrawer();
        }
      },
      child: Icon(
        showBackButton ? CupertinoIcons.chevron_back : Icons.menu,
        size: showBackButton ? 24 : 30,
        color: Colors.blueGrey,
      ),
    ),
    title: Image.asset(
      ImageConstants.logoImagePath,
      width: getWidthOfScreen(context) * 0.6,
    ),
    actions: [
      if (showBackButton)
        InkWell(
          onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Icon(
            Icons.home,
            size: 30,
            color: Colors.blueGrey,
          ),
        ),
      if (!showBackButton && LocalStorage.wasNotificationShownToday())
        InkWell(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const NotificationsScreen()));
          },
          child: const Icon(
            Icons.notifications,
            size: 30,
            color: Colors.blueGrey,
          ),
        ),
      const SizedBox(width: 16)
    ],
    centerTitle: true,
    bottom: (!showBackButton)
        ? null
        : (loggedInUser?.userType == "Student" || studentName != null)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(40),
                child: Container(
                  padding: const EdgeInsets.only(left: 20.0),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    studentName ?? loggedInUser?.name ?? "",
                    textScaler: const TextScaler.linear(1.0),
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: fontFamily,
                        color: ColorConstant.inactiveColor),
                  ),
                ))
            : null,
  );
}
