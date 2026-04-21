// File: lib/utils/components/app_button.dart
// REDESIGNED: Teal gradient pill button matching modern UI
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:school_app/utils/app_theme.dart';

class AppButton extends StatefulWidget {
  final Function(ValueNotifier<bool>)? onPressed;
  final double? height;
  final double? weight;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final String text;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;

  const AppButton({
    super.key,
    this.onPressed,
    this.height,
    this.weight,
    this.backgroundColor,
    this.padding,
    required this.text,
    this.textStyle,
    this.borderRadius,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  final ValueNotifier<bool> _isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return SizedBox(
            height: widget.height ?? 52,
            child: Center(
              child: SizedBox(
                width: 40, height: 40,
                child: LoadingIndicator(
                  indicatorType: Indicator.ballSpinFadeLoader,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.5),
                  ],
                  strokeWidth: 2,
                ),
              ),
            ),
          );
        }

        return SizedBox(
          height: widget.height ?? 52,
          width: widget.weight ?? double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: widget.backgroundColor != null
                  ? null
                  : AppGradients.tealHero,
              color: widget.backgroundColor,
              borderRadius: widget.borderRadius ?? AppRadius.fullRadius,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () => widget.onPressed?.call(_isLoading),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: widget.borderRadius ?? AppRadius.fullRadius,
                ),
                padding: widget.padding ??
                    const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                widget.text,
                textAlign: TextAlign.center,
                style: widget.textStyle ??
                    GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
              ),
            ),
          ),
        );
      },
    );
  }
}