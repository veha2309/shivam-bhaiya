import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view/change_password_screen.dart';
import 'package:school_app/auth/view/login_screen.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/view/home_screen.dart';
import 'package:school_app/settings/view/settings_screen.dart';
import 'package:school_app/student_profile/View/student_profile_screen.dart';
import 'package:school_app/user/view/user_list_screen.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/components/profile_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:school_app/utils/utils.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  User? user;
  HomeModel? homeModel;
  late List<ListItemModel> listItems;

  void updateInfo() {
    user = AuthViewModel.instance.getLoggedInUser();
    homeModel = AuthViewModel.instance.homeModel;
    listItems = [
      ListItemModel(
        title: "Home",
        icon: Icons.home,
        onTap: () {
          navigateToScreen(context, const HomeScreen());
        },
      ),
      if (LocalStorage.hasMultipleUsers())
        ListItemModel(
          title: "User List",
          icon: Icons.person,
          onTap: () {
            navigateToScreen(context, const UserListScreen());
          },
        ),
      ListItemModel(
        title: "Add User",
        icon: Icons.person_add_alt_1,
        onTap: () {
          navigateToScreen(
              context,
              const LoginScreen(
                shouldAllowPop: true,
              ));
        },
      ),
      ListItemModel(
        title: "Settings",
        icon: Icons.lock,
        onTap: () {
          navigateToScreen(context, const SettingsScreen());
        },
      ),
      if (user?.userType != "Teacher")
        ListItemModel(
          title: "Profile",
          icon: Icons.person_outline_rounded,
          onTap: () {
            User? user = AuthViewModel.instance.getLoggedInUser();
            navigateToScreen(
              context,
              StudentProfileScreen(
                studentId: user?.username ?? "",
              ),
            );
          },
        ),
      ListItemModel(
        title: "School Website",
        icon: Icons.web,
        onTap: () {
          launchURLString("https://vivekanandschool.in");
        },
      ),
      ListItemModel(
        title: "Refresh",
        icon: Icons.refresh,
        onTap: () {
          Phoenix.rebirth(context);
        },
      ),
      ListItemModel(
        title: "Help & Support",
        icon: Icons.support_agent,
        onTap: () {
          showContactBottomSheet(context);
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    updateInfo();
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageConstants.homeScreenBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              spacing: 16,
              children: [
                getUserProfileHeader(),
                getDrawerItems(),
                getConnectWithUsWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getUserProfileHeader() {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          height: 16,
        ),
        Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: getProfilePicture(homeModel?.profilePhoto ?? ""),
          ),
        ),
        Text(
          user?.name ?? "",
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            color: ColorConstant.primaryColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: fontFamily,
          ),
        ),
        Text(
          homeModel?.className ?? "",
          textAlign: TextAlign.center,
          textScaler: const TextScaler.linear(1.0),
          style: const TextStyle(
            color: ColorConstant.inactiveColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
      ],
    );
  }

  Widget getDrawerItems() {
    return ListView.separated(
      separatorBuilder: (context, index) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0),
        child: Divider(
          color: ColorConstant.primaryColor,
          height: 5,
          thickness: 0.5,
        ),
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        ListItemModel item = listItems[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          minTileHeight: 0,
          title: Text(
            item.title,
            textScaler: const TextScaler.linear(1.0),
            style: const TextStyle(
              color: ColorConstant.primaryColor,
              fontSize: 16,
              fontFamily: fontFamily,
            ),
          ),
          leading: Icon(
            item.icon,
            color: ColorConstant.primaryColor,
          ),
          onTap: item.onTap,
          trailing: const Icon(
            Icons.arrow_forward_ios,
            color: ColorConstant.primaryColor,
          ),
        );
      },
    );
  }

  Widget getConnectWithUsWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 50,
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "Connect with us:",
            textScaler: TextScaler.linear(1.0),
            style: TextStyle(
              color: ColorConstant.primaryColor,
              fontFamily: fontFamily,
              fontSize: 14,
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              icon: const FaIcon(
                FontAwesomeIcons.facebook,
                size: 20,
                color: ColorConstant.primaryColor,
              ),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                launchURLString(
                    "https://www.facebook.com/VivekanandSchoolDBlock/");
              },
            ),
            // IconButton(
            //   icon: const FaIcon(FontAwesomeIcons.xTwitter,
            //       size: 20, color: ColorConstant.primaryColor),
            //   style: IconButton.styleFrom(
            //     padding: EdgeInsets.zero,
            //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //   ),
            //   onPressed: () {
            //     launchURLString("https://x.com/VivekanandScul");
            //   },
            // ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.instagram,
                  size: 22, color: ColorConstant.primaryColor),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                launchURLString("https://www.instagram.com/vivekanandschool/");
              },
            ),
            IconButton(
              icon: const FaIcon(FontAwesomeIcons.youtube,
                  size: 23, color: ColorConstant.primaryColor),
              style: IconButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {
                launchURLString(
                    "https://www.youtube.com/channel/UCSHkcyHkZIM_oWT1afjSzXw");
              },
            ),
          ],
        ),
      ],
    );
  }
}

class ListItemModel {
  String title;
  IconData icon;
  Function() onTap;

  ListItemModel({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}
