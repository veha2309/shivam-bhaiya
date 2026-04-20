import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view/forgot_password_screen.dart';
import 'package:school_app/auth/view/user_password_screen.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:school_app/utils/utils.dart';
import 'package:flutter/cupertino.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  final bool shouldAllowPop;

  const LoginScreen({super.key, this.shouldAllowPop = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  bool hidePassword = true;
  bool showBackButton = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: widget.shouldAllowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          popScreen(context);
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          resizeToAvoidBottomInset: true,
          body: SafeArea(
            child: ValueListenableBuilder(
                valueListenable: isLoadingNotifier,
                builder: (context, value, _) {
                  return Stack(
                    children: [
                      AbsorbPointer(
                        absorbing: isLoadingNotifier.value,
                        child: getLoginScreenBody(),
                      ),
                      if (value) getScreenLoaderWidget(),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }

  Widget getLoginScreenBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Column(
                children: [
                  Image.asset(
                    ImageConstants.logoImagePath,
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
                  Image.asset(
                    ImageConstants
                        .vivekanand, // Replace with the statue image asset
                    height: getWidthOfScreen(context),
                  ),
                ],
              ),

              // Username Text Field
              AppTextfield(
                enabled: true,
                controller: usernameController,
                hintText: "Enter User Name",
                showIcon: false,
                keyboardType: TextInputType.name,
                maxlines: 1,
              ),
              const SizedBox(height: 20),
              AppTextfield(
                enabled: true,
                controller: passwordController,
                hintText: "Enter Password",
                showIcon: true,
                onIconTap: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                obscureText: hidePassword,
                icon: hidePassword ? Icons.visibility : Icons.visibility_off,
              ),
              const SizedBox(
                height: 10,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    if (usernameController.text.isEmpty) {
                      showSnackBarOnScreen(
                          context, "Please enter your username");
                      return;
                    }
                    navigateToScreen(context,
                        ForgotPasswordScreen(userId: usernameController.text));
                  },
                  child: const Text(
                    'Forgot password?',
                    textScaler: TextScaler.linear(1.0),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      fontFamily: fontFamily,
                      color: ColorConstant.primaryColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Next Button
              AppButton(
                text: 'LOGIN',
                onPressed:
                    (ValueNotifier<bool> updateButtonLoadingState) async {
                  if (usernameController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "Please enter your username",
                        textScaler: TextScaler.linear(1.0),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ));
                    return;
                  }
                  if (passwordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                        "Please enter your password",
                        textScaler: TextScaler.linear(1.0),
                        style: TextStyle(
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ));
                    return;
                  }
                  isLoadingNotifier.value = true;

                  String? affiliationCode =
                      await showBranchSelectionBottomSheet(context);
                  if (affiliationCode == null || affiliationCode.isEmpty) {
                    isLoadingNotifier.value = false;
                    return;
                  }

                  ApiResponse response = await AuthViewModel.instance
                      .getUserDetailsFromEmail(
                          usernameController.text, affiliationCode);

                  if (response.success) {
                    User? user = response.data;
                    if (user == null) {
                      isLoadingNotifier.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                          "Something went wrong, please try again later",
                          textScaler: TextScaler.linear(1.0),
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        ),
                      ));
                      return;
                    }
                    ApiResponse passWordResponse = await AuthViewModel.instance
                        .authenticateWithEmailAndPassword(
                      user.username,
                      passwordController.text,
                      user.userType,
                      user.affiliationCode ?? "",
                    );

                    if (passWordResponse.success) {
                      isLoadingNotifier.value = false;
                      await Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              UserAuthScreen(userToBeAuthenticated: user),
                        ),
                        (route) => false,
                      );
                    } else {
                      isLoadingNotifier.value = false;
                      await LocalStorage.deleteUser(user.username);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            passWordResponse.errorMessage!,
                            textScaler: const TextScaler.linear(1.0),
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: fontFamily,
                            ),
                          ),
                          backgroundColor: ColorConstant.errorColor,
                        ),
                      );
                    }
                  } else {
                    await LocalStorage.deleteUser(usernameController.text);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        response.errorMessage!,
                        textScaler: const TextScaler.linear(1.0),
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: fontFamily,
                        ),
                      ),
                    ));
                    isLoadingNotifier.value = false;
                  }
                },
              ),

              const SizedBox(height: 10),
              // Trouble Signing Section
              Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        child: const Text("Having trouble in signing in?",
                            style:
                                TextStyle(color: ColorConstant.primaryColor)),
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
    );
  }
}
