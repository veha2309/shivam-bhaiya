import 'package:flutter/material.dart';
// ...existing imports...

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class ForgotPasswordScreen extends StatefulWidget {
  static const String routeName = '/forgot-password';
  final String userId;
  const ForgotPasswordScreen({super.key, required this.userId});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier(false);
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoading,
      showAppBar: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // School logo and name
                Column(
                  children: [
                    Image.asset(
                      ImageConstants.logoImagePath,
                      height: 80,
                    ), // Replace with your logo

                    const Text(
                      'D - Block, Anand Vihar | F - Block, Preet Vihar',
                      textScaler: TextScaler.linear(1.0),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: fontFamily,
                        color: ColorConstant.primaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 150),
                // Lock icon
                const Icon(
                  Icons.lock,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 20),
                // Forgot Password text
                const Text(
                  'Forgot Password?',
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: fontFamily,
                    color: ColorConstant.primaryColor,
                  ),
                ),
                // Subtitle
                const Text(
                  "Don't worry! It happens sometimes.\nSelect the below option to recover your password.",
                  textScaler: TextScaler.linear(1.0),
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: fontFamily,
                    color: ColorConstant.secondaryTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 150),
                // Buttons
                AppButton(
                  text: 'Password via e-mail',
                  onPressed: (_) async {
                    isLoading.value = true;
                    String userId = widget.userId;
                    String? affiliationCode =
                        await showBranchSelectionBottomSheet(context);
                    if (affiliationCode == null || affiliationCode.isEmpty) {
                      isLoading.value = false;
                      return;
                    }
                    try {
                      ApiResponse response =
                          await NetworkManager.instance.makeRequest(
                        Endpoints.forgotPasswordViaEmail(
                            affiliationCode, userId),
                        (json) async {
                          return;
                        },
                        method: HttpMethod.get,
                      );
                      if (response.success) {
                        isLoading.value = false;
                        Navigator.of(context).pop();
                        showSnackBarOnScreen(
                          context,
                          "Reset password sms or email will receive shortly!",
                        );
                      } else {
                        isLoading.value = false;
                        showSnackBarOnScreen(
                          context,
                          "An error occurred",
                        );
                      }
                    } catch (_) {
                      isLoading.value = false;
                      showSnackBarOnScreen(
                        context,
                        "An error occurred",
                      );
                    }
                  },
                ),
                const SizedBox(height: 15),
                AppButton(
                  text: 'Password via SMS',
                  onPressed: (_) async {
                    isLoading.value = true;
                    String userId = widget.userId;
                    String? affiliationCode =
                        await showBranchSelectionBottomSheet(context);
                    if (affiliationCode == null || affiliationCode.isEmpty)
                      return;
                    try {
                      ApiResponse response =
                          await NetworkManager.instance.makeRequest(
                        Endpoints.forgotPasswordViaSms(affiliationCode, userId),
                        (json) async {
                          return;
                        },
                        method: HttpMethod.get,
                      );
                      if (response.success) {
                        isLoading.value = false;
                        Navigator.of(context).pop();
                        showSnackBarOnScreen(
                          context,
                          "Reset password sms or email will receive shortly!",
                        );
                      } else {
                        isLoading.value = false;
                        showSnackBarOnScreen(
                          context,
                          "An error occurred",
                        );
                      }
                    } catch (_) {
                      isLoading.value = false;
                      showSnackBarOnScreen(
                        context,
                        "An error occurred",
                      );
                    }
                  },
                ),
                const SizedBox(height: 50),
                // Trouble signing in

                Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          child: const Text(
                            "Having trouble in signing in?",
                            textScaler: TextScaler.linear(1.0),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: fontFamily,
                              color: ColorConstant.primaryColor,
                            ),
                          ),
                          onPressed: () => showContactBottomSheet(
                              context), // Replace with actual email
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
