// File: lib/utils/components/app_textfield.dart
// REDESIGNED: Clean modern textfield with teal accents
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:school_app/utils/app_theme.dart';

class AppTextfield extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool enabled;
  final bool? showIcon;
  final IconData? icon;
  final Function()? onIconTap;
  final bool obscureText;
  final Function()? onTap;
  final FocusNode? focusNode;
  final Function(String)? onChanged;
  final EdgeInsetsGeometry? contentPadding;
  final TextInputType? keyboardType;
  final double? height;
  final int? maxlines;
  final Function(String)? onSubmit;
  final TextStyle? textStyle;

  const AppTextfield({
    super.key,
    this.controller,
    this.enabled = false,
    required this.hintText,
    this.obscureText = false,
    this.onIconTap,
    this.onTap,
    this.focusNode,
    this.showIcon,
    this.onChanged,
    this.contentPadding,
    this.keyboardType,
    this.height,
    this.maxlines,
    this.icon,
    this.onSubmit,
    this.textStyle,
  });

  @override
  State<AppTextfield> createState() => _AppTextfieldState();
}

class _AppTextfieldState extends State<AppTextfield> {
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showIcon = widget.showIcon ?? !widget.enabled;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.lgRadius,
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.outlineVariant.withOpacity(0.3),
          width: _isFocused ? 1.5 : 1,
        ),
        boxShadow: _isFocused ? AppShadows.soft : [],
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppRadius.lgRadius,
        child: TextField(
          onSubmitted: widget.onSubmit ?? (_) => FocusScope.of(context).unfocus(),
          onChanged: widget.onChanged,
          focusNode: _focusNode,
          enabled: widget.enabled,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxlines,
          style: widget.textStyle ??
              GoogleFonts.inter(
                fontSize: 15,
                color: AppColors.onSurface,
                fontWeight: FontWeight.w500,
              ),
          decoration: InputDecoration(
            labelText: widget.hintText,
            labelStyle: GoogleFonts.inter(
              color: _isFocused ? AppColors.primary : AppColors.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            suffixIcon: showIcon
                ? InkWell(
                    onTap: widget.onIconTap,
                    borderRadius: AppRadius.fullRadius,
                    child: Icon(
                      widget.icon ?? Icons.keyboard_arrow_down,
                      color: _isFocused ? AppColors.primary : AppColors.onSurfaceVariant.withOpacity(0.5),
                      size: 20,
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}