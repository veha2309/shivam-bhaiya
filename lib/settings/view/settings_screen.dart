import 'package:flutter/material.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:school_app/auth/view/change_password_screen.dart';
import 'package:school_app/auth/view/login_screen.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/user/view/user_list_screen.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class SettingsScreen extends StatefulWidget {
  static const String routeName = '/settings';
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

final class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      body: AppBody(
        title: "Settings",
        body: ListView.builder(
          itemCount: settingsItems(context).length,
          itemBuilder: (context, index) =>
              settingsTile(item: settingsItems(context)[index]),
        ),
      ),
    );
  }

  Widget settingsTile({required SettingsItem item}) {
    return Column(
      children: [
        ListTile(
          leading: Icon(
            item.icon,
            color: ColorConstant.primaryColor,
          ),
          title: Text(
            item.title,
            textScaler: const TextScaler.linear(1.0), // Prevent font scaling
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: item.onTap,
        ),
        const Divider(
            height: 1, thickness: 0.5, indent: 50, color: Colors.grey),
      ],
    );
  }

  List<SettingsItem> settingsItems(BuildContext context) => [
        SettingsItem(
          title: "User List",
          icon: Icons.person,
          onTap: () {
            navigateToScreen(context, const UserListScreen());
          },
        ),
        SettingsItem(
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
        SettingsItem(
          title: "Change Password",
          icon: Icons.lock,
          onTap: () {
            navigateToScreen(context, const ChangePasswordScreen());
          },
        ),
        SettingsItem(
          title: "Refresh",
          icon: Icons.refresh,
          onTap: () {
            Phoenix.rebirth(context);
          },
        ),
        SettingsItem(
          title: "Help & Support",
          icon: Icons.support_agent,
          onTap: () {
            showContactBottomSheet(context);
          },
        ),
        SettingsItem(
          title: "Logout",
          icon: Icons.exit_to_app,
          onTap: () async {
            await AuthViewModel.instance.logout(context);
          },
        ),
      ];
}

class SettingsItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  SettingsItem({required this.title, required this.icon, required this.onTap});
}
