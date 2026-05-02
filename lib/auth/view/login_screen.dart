// File: lib/auth/view/login_screen.dart
// REDESIGNED: Stitch-inspired login with hero gradient, glass card form
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/admin_dashboard/view/admin_navigation_screen.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view/forgot_password_screen.dart';
import 'package:school_app/auth/view/user_password_screen.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/components/bottom_sheet.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/language_provider.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';
import 'package:school_app/utils/utils.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';
  final bool shouldAllowPop;
  const LoginScreen({super.key, this.shouldAllowPop = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _mobileCtrl = TextEditingController();
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  bool _hidePassword = true;
  bool _isOtpMode = false;

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // Ensure rebuild on change
    return PopScope(
      canPop: widget.shouldAllowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) popScreen(context);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, loading, _) {
            return Stack(
              children: [
                // Background Gradient
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.cyan.withOpacity(0.1),
                          Colors.white,
                        ],
                      ),
                    ),
                  ),
                ),
                AbsorbPointer(
                  absorbing: loading,
                  child: SafeArea(child: _buildBody(context)),
                ),
                if (loading) getScreenLoaderWidget(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Admin Dev Login Button (keep this for dev)
          ElevatedButton(
            onPressed: () async {
              bool success = await AuthViewModel.instance.loginAsDummyAdmin();
              if (success && context.mounted) {
                Navigator.pushReplacementNamed(
                    context, AdminNavigationScreen.routeName);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text("DEV: Login as Admin"),
          ),

          const SizedBox(height: 20),
          // Top Logo
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                ImageConstants.logoImagePath,
                height: 50,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Welcome to",
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
          ),
          Text(
            "Smart School",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Learn. Grow. Succeed. Together.",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),

          // Illustration Placeholder
          const SizedBox(height: 30),
          Icon(
            Icons.account_balance,
            size: 100,
            color: AppColors.primary.withOpacity(0.8),
          ),

          const SizedBox(height: 20),

          // Main Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Let's Get Started 👋",
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Login to continue to your account",
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                // Tabs
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOtpMode = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: !_isOtpMode
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: !_isOtpMode ? 2 : 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.person,
                                  color: !_isOtpMode
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                                  size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Username & Password",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: !_isOtpMode
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: !_isOtpMode
                                          ? AppColors.primary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOtpMode = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: _isOtpMode
                                        ? AppColors.primary
                                        : Colors.grey.shade300,
                                    width: _isOtpMode ? 2 : 1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.phone_android,
                                  color: _isOtpMode
                                      ? AppColors.primary
                                      : Colors.grey.shade600,
                                  size: 16),
                              const SizedBox(width: 6),
                              Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Login with OTP",
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: _isOtpMode
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: _isOtpMode
                                          ? AppColors.primary
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (!_isOtpMode) ...[
                  // Username field
                  AppTextfield(
                    enabled: true,
                    controller: _usernameCtrl,
                    hintText: "Enter your username",
                    prefixIcon: Icons.person_outline,
                    showIcon: false,
                    keyboardType: TextInputType.name,
                    maxlines: 1,
                  ),

                  const SizedBox(height: 16),

                  // Password field
                  AppTextfield(
                    enabled: true,
                    controller: _passwordCtrl,
                    hintText: "Enter your password",
                    prefixIcon: Icons.lock_outline,
                    showIcon: true,
                    onIconTap: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    obscureText: _hidePassword,
                    icon: _hidePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ] else ...[
                  // Mobile number field
                  AppTextfield(
                    enabled: true,
                    controller: _mobileCtrl,
                    hintText: "Enter your mobile number",
                    prefixIcon: Icons.phone_android,
                    showIcon: false,
                    keyboardType: TextInputType.phone,
                    maxlines: 1,
                  ),
                ],

                const SizedBox(height: 16),

                if (!_isOtpMode)
                  // Remember me & Forgot password
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: true,
                                onChanged: (val) {},
                                activeColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  "Remember me",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: AppColors.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: TextButton(
                            onPressed: () {
                              if (_usernameCtrl.text.isEmpty) {
                                showSnackBarOnScreen(context,
                                    "Please enter your username first");
                                return;
                              }
                              navigateToScreen(
                                  context,
                                  ForgotPasswordScreen(
                                      userId: _usernameCtrl.text));
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Forgot Password?",
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Login button
                AppButton(
                  text: _isOtpMode ? "Send OTP" : "Login",
                  onPressed: (loadingNotifier) async {
                    if (_isOtpMode) {
                      if (_mobileCtrl.text.isEmpty) {
                        showSnackBarOnScreen(
                            context, "Please enter your mobile number");
                        return;
                      }
                      // Implement OTP send logic here
                      showSnackBarOnScreen(context,
                          "OTP sent successfully to ${_mobileCtrl.text}!");
                    } else {
                      await _handleLogin(context, loadingNotifier);
                    }
                  },
                ),

                if (!_isOtpMode) ...[
                  const SizedBox(height: 24),

                  // or login with OTP
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          "or login with OTP",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade200)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Send OTP to Mobile
                  GestureDetector(
                    onTap: () => setState(() => _isOtpMode = true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.phone_android,
                              color: AppColors.primary.withOpacity(0.6),
                              size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Send OTP to Mobile",
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right,
                              color: AppColors.primary, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Safe and secure
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.security,
                        color: AppColors.primary, size: 16),
                    const SizedBox(width: 8),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.onSurfaceVariant),
                        children: const [
                          TextSpan(text: "Your data is "),
                          TextSpan(
                              text: "safe and secure",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary)),
                          TextSpan(text: " with us."),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _handleLogin(
      BuildContext context, ValueNotifier<bool> loadingNotifier) async {
    if (_usernameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(context.read<LanguageProvider>().translate('enter_username')),
        backgroundColor: AppColors.primaryContainer,
      ));
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(context.read<LanguageProvider>().translate('enter_password')),
        backgroundColor: AppColors.primaryContainer,
      ));
      return;
    }

    _isLoading.value = true;
    String? affiliationCode = await showBranchSelectionBottomSheet(context);
    if (affiliationCode == null || affiliationCode.isEmpty) {
      _isLoading.value = false;
      return;
    }

    ApiResponse response = await AuthViewModel.instance
        .getUserDetailsFromEmail(_usernameCtrl.text, affiliationCode);

    if (response.success) {
      User? user = response.data;
      if (user == null) {
        _isLoading.value = false;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              context.read<LanguageProvider>().translate('something_wrong')),
        ));
        return;
      }

      ApiResponse passResponse =
          await AuthViewModel.instance.authenticateWithEmailAndPassword(
        user.username,
        _passwordCtrl.text,
        user.userType,
        user.affiliationCode ?? '',
      );

      if (passResponse.success) {
        _isLoading.value = false;
        await Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => UserAuthScreen(userToBeAuthenticated: user),
          ),
          (r) => false,
        );
      } else {
        _isLoading.value = false;
        await LocalStorage.deleteUser(user.username);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(passResponse.errorMessage ??
              context.read<LanguageProvider>().translate('auth_failed')),
          backgroundColor: AppColors.error,
        ));
      }
    } else {
      await LocalStorage.deleteUser(_usernameCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.errorMessage ??
            context.read<LanguageProvider>().translate('login_failed')),
        backgroundColor: AppColors.error,
      ));
      _isLoading.value = false;
    }
  }
}
