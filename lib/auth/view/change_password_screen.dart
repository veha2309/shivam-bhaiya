import 'package:flutter/material.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/utils.dart';

class ChangePasswordScreen extends StatefulWidget {
  static const String routeName = '/change-password';

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPasswordController =
      TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: 'Change Password',
        body: getChangePasswordScreenBody(),
      ),
    );
  }

  Widget getChangePasswordScreenBody() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // Current Password Field
          AppTextfield(
            controller: currentPasswordController,
            hintText: "Enter Current Password",
            obscureText: true,
            enabled: true,
            showIcon: false,
          ),
          const SizedBox(height: 20),
          // New Password Field
          AppTextfield(
            controller: newPasswordController,
            hintText: "Enter New Password",
            obscureText: true,
            enabled: true,
            showIcon: false,
          ),
          const SizedBox(height: 20),
          // Confirm New Password Field
          AppTextfield(
            controller: confirmPasswordController,
            hintText: "Re-enter New Password",
            obscureText: true,
            enabled: true,
            showIcon: false,
          ),
          const Spacer(),
          // Change Password Button
          AppButton(
            text: 'SAVE',
            onPressed: (ValueNotifier<bool> updateButtonLoadingState) async {
              if (currentPasswordController.text.isEmpty ||
                  newPasswordController.text.isEmpty ||
                  confirmPasswordController.text.isEmpty) {
                showSnackBarOnScreen(context, "All fields are required!");
                return;
              }
              if (newPasswordController.text !=
                  confirmPasswordController.text) {
                showSnackBarOnScreen(context, "New passwords do not match!");
                return;
              }

              isLoadingNotifier.value = true;

              AuthViewModel.instance
                  .changePassword(
                      currentPasswordController.text,
                      newPasswordController.text,
                      confirmPasswordController.text)
                  .then((response) {
                if (response.success) {
                  showSnackBarOnScreen(
                      context, "Password changed successfully!");
                } else {
                  showSnackBarOnScreen(
                      context, "Something went wrong, please try again later");
                }
                isLoadingNotifier.value = false;
                return response;
              });

              popScreen(context);
            },
          ),
        ],
      ),
    );
  }
}
