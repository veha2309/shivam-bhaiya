// File: lib/auth/view/login_screen.dart
// REDESIGNED: Stitch-inspired login with hero gradient, glass card form
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);
  bool _hidePassword = true;

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageProvider>(); // Ensure rebuild on change
    return PopScope(
      canPop: widget.shouldAllowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) popScreen(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        resizeToAvoidBottomInset: true,
        body: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, loading, _) {
            return Stack(
              children: [
                // Background decorative circles
                _BackgroundDecor(),
                AbsorbPointer(
                  absorbing: loading,
                  child: SafeArea(child: _buildBody(context)),
                ),
                // Language Toggle on Login Screen
                Positioned(
                  top: 16,
                  right: 16,
                  child: SafeArea(
                    child: IconButton.filledTonal(
                      onPressed: () => showLanguageBottomSheet(context),
                      icon: const Icon(Icons.translate_rounded, size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.15),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
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
          // ── Top section: logo + Vivekanand idol ─────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.42,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Idol image (bottom)
                Positioned(
                  bottom: 0,
                  child: Image.asset(
                    ImageConstants.vivekanand,
                    height: MediaQuery.of(context).size.height * 0.35,
                    fit: BoxFit.contain,
                  ),
                ),
                // Logo (top-centre)
                Positioned(
                  top: 32,
                  child: Column(
                    children: [
                      Image.asset(
                        ImageConstants.logoImagePath,
                        height: 70,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.read<LanguageProvider>().translate('school_address'),
                        textScaler: const TextScaler.linear(1.0),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.55),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Glass form card ────────────────────────────────────────────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppRadius.xl),
              topRight: Radius.circular(AppRadius.xl),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.xl,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.xl),
                    topRight: Radius.circular(AppRadius.xl),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Heading
                    Text(
                      context.read<LanguageProvider>().translate('welcome_back'),
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.read<LanguageProvider>().translate('login_subtitle'),
                      textScaler: const TextScaler.linear(1.0),
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Username field
                    AppTextfield(
                      enabled: true,
                      controller: _usernameCtrl,
                      hintText: context.read<LanguageProvider>().translate('username_hint'),
                      showIcon: false,
                      keyboardType: TextInputType.name,
                      maxlines: 1,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Password field
                    AppTextfield(
                      enabled: true,
                      controller: _passwordCtrl,
                      hintText: context.read<LanguageProvider>().translate('password_hint'),
                      showIcon: true,
                      onIconTap: () =>
                          setState(() => _hidePassword = !_hidePassword),
                      obscureText: _hidePassword,
                      icon: _hidePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          if (_usernameCtrl.text.isEmpty) {
                            showSnackBarOnScreen(
                                context, context.read<LanguageProvider>().translate('enter_username'));
                            return;
                          }
                          navigateToScreen(context,
                              ForgotPasswordScreen(userId: _usernameCtrl.text));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primaryContainer,
                        ),
                        child: Text(
                          context.read<LanguageProvider>().translate('forgot_password'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryContainer,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // Login button
                    AppButton(
                      text: context.read<LanguageProvider>().translate('login_button'),
                      onPressed: (loadingNotifier) async {
                        await _handleLogin(context, loadingNotifier);
                      },
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Help row
                    Center(
                      child: TextButton(
                        onPressed: () => showContactBottomSheet(context),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.onSurfaceVariant,
                        ),
                        child: Text(
                          context.read<LanguageProvider>().translate('login_issue'),
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.onSurfaceVariant,
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
    );
  }

  Future<void> _handleLogin(
      BuildContext context, ValueNotifier<bool> loadingNotifier) async {
    if (_usernameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<LanguageProvider>().translate('enter_username')),
        backgroundColor: AppColors.primaryContainer,
      ));
      return;
    }
    if (_passwordCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.read<LanguageProvider>().translate('enter_password')),
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
          content: Text(context.read<LanguageProvider>().translate('something_wrong')),
        ));
        return;
      }

      ApiResponse passResponse = await AuthViewModel.instance
          .authenticateWithEmailAndPassword(
        user.username, _passwordCtrl.text, user.userType,
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
          content: Text(passResponse.errorMessage ?? context.read<LanguageProvider>().translate('auth_failed')),
          backgroundColor: AppColors.error,
        ));
      }
    } else {
      await LocalStorage.deleteUser(_usernameCtrl.text);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(response.errorMessage ?? context.read<LanguageProvider>().translate('login_failed')),
        backgroundColor: AppColors.error,
      ));
      _isLoading.value = false;
    }
  }
}

// Background decorative blobs on the navy screen
class _BackgroundDecor extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -60, right: -60,
          child: Container(
            width: 220, height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.04),
            ),
          ),
        ),
        Positioned(
          top: 80, left: -40,
          child: Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.08),
            ),
          ),
        ),
      ],
    );
  }
}