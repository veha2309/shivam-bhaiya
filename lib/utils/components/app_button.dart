import 'package:flutter/material.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/constants.dart';

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
    return SizedBox(
      child: ValueListenableBuilder<bool>(
          valueListenable: _isLoading,
          builder: (context, value, _) {
            if (value) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  getLoaderWidget(),
                ],
              );
            }
            return SizedBox(
              height: widget.height,
              width: widget.weight ?? double.infinity,
              child: ElevatedButton(
                onPressed: () => widget.onPressed?.call(_isLoading),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        widget.borderRadius ?? BorderRadius.circular(8),
                  ),
                  backgroundColor:
                      widget.backgroundColor ?? ColorConstant.primaryColor,
                  padding:
                      widget.padding ?? const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  widget.text,
                  textAlign: TextAlign.center,
                  textScaler: const TextScaler.linear(1.0),
                  style: widget.textStyle ??
                      const TextStyle(
                        fontSize: 16,
                        fontFamily: fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            );
          }),
    );
  }
}
