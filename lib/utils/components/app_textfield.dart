import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';

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
    this.height = 45,
    this.maxlines,
    this.icon,
    this.onSubmit,
    this.textStyle,
  });

  @override
  State<AppTextfield> createState() => _AppTextfieldState();
}

class _AppTextfieldState extends State<AppTextfield> {
  @override
  Widget build(BuildContext context) {
    bool showIcon = widget.showIcon ?? !widget.enabled;
    return SizedBox(
      height: widget.height,
      child: InkWell(
        onTap: widget.onTap,
        child: TextField(
          onSubmitted: widget.onSubmit ??
              (_) {
                FocusScope.of(context).unfocus();
              },
          textInputAction:
              widget.onSubmit == null ? TextInputAction.done : null,
          onChanged: widget.onChanged,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          maxLines: widget.obscureText ? 1 : widget.maxlines,
          style: widget.textStyle,
          decoration: InputDecoration(
            labelText: widget.hintText,
            labelStyle: const TextStyle(
              color: ColorConstant.secondaryTextColor,
            ),
            suffixIcon: showIcon
                ? InkWell(
                    onTap: widget.onIconTap,
                    child: Icon(
                      widget.icon ?? Icons.keyboard_arrow_down,
                      color: ColorConstant.primaryTextColor.withOpacity(0.3),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            border: OutlineInputBorder(
              gapPadding: 0,
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColorConstant.secondaryTextColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              gapPadding: 0,
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColorConstant.secondaryTextColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              gapPadding: 0,
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: ColorConstant.secondaryTextColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
