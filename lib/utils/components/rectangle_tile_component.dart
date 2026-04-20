import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';

final class RectangleTileComponent extends StatelessWidget {
  final String? backgroundImagePath;
  final String title;
  final String? icon;
  final VoidCallback? onTap;
  final bool isTitleCentered;
  final Color textColor;

  const RectangleTileComponent({
    super.key,
    this.backgroundImagePath,
    required this.title,
    this.icon,
    this.onTap,
    this.isTitleCentered = false,
    this.textColor = ColorConstant.primaryTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: ColorConstant.primaryColor,
        image: backgroundImagePath != null
            ? DecorationImage(
                image: AssetImage(backgroundImagePath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        leading: icon != null
            ? Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.hardEdge,
                child: Image.asset(
                  icon!,
                  height: 45,
                  width: 45,
                  fit: BoxFit.cover,
                ),
              )
            : null,
        title: Text(
          title,
          textScaler: const TextScaler.linear(1.0),
          textAlign: isTitleCentered ? TextAlign.center : null,
          style: TextStyle(
            fontSize: 18,
            color: textColor,
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),

        // trailing: const Icon(
        //   Icons.chevron_right,
        //   size: 24,
        // ),
      ),
    );
  }
}
