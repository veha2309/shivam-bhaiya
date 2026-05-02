import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/auth/view/login_screen.dart';
import 'package:school_app/utils/app_theme.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_textfield.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

class SchoolCodeScreen extends StatefulWidget {
  const SchoolCodeScreen({super.key});

  @override
  State<SchoolCodeScreen> createState() => _SchoolCodeScreenState();
}

class _SchoolCodeScreenState extends State<SchoolCodeScreen> {
  final TextEditingController _codeCtrl = TextEditingController();

  void _onContinue() {
    if (_codeCtrl.text.isEmpty) {
      showSnackBarOnScreen(context, "Please enter your school code");
      return;
    }
    
    if (_codeCtrl.text.trim() == "2444") {
      navigateToScreen(context, const LoginScreen(shouldAllowPop: true));
    } else {
      showSnackBarOnScreen(context, "Invalid school code. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient / Decor
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
          
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),
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
                    "One step closer to a smarter school experience.",
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.cyan.withOpacity(0.1),
                          ),
                          child: const Icon(
                            Icons.account_balance,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Enter Your School Code",
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "To continue, please enter the school code\nprovided by your school.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        // Text Field
                        AppTextfield(
                          enabled: true,
                          controller: _codeCtrl,
                          hintText: "Enter School Code",
                          prefixIcon: Icons.security,
                          icon: Icons.qr_code_scanner,
                          showIcon: true,
                          onIconTap: () {},
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Continue Button
                        AppButton(
                          text: "Continue",
                          onPressed: (_) async {
                            _onContinue();
                          },
                          // Since AppButton doesn't natively support trailing icon yet, we'll keep it as is, or we can use a custom button
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Or divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.grey.shade200)),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "or",
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
                        
                        // Don't know code
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.help_outline, color: AppColors.primary, size: 16),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "Don't know your school code?",
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.primary, size: 20),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Info card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.cyan.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Where can I find my school code?",
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "You can get your school code from your school administrator, teacher or school notice.",
                                      style: GoogleFonts.inter(
                                        fontSize: 11,
                                        color: AppColors.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 16),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
