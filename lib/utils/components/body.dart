import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class AppBody extends StatelessWidget {
  final String? title;
  final String? subtext;
  final Widget body;
  const AppBody({super.key, this.title, required this.body, this.subtext});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          if (title != null)
            FittedBox(
              alignment: Alignment.center,
              child: Text(
                title!,
                textScaler: const TextScaler.linear(1.0),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w400,
                  color: ColorConstant.primaryColor,
                ),
              ),
            ),
          if (subtext != null)
            Column(
              children: [
                const SizedBox(height: 4),
                Text(
                  subtext!,
                  textScaler: const TextScaler.linear(1.0),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: ColorConstant.primaryColor,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 8),
          Expanded(
            child: SizedBox(
              width: getWidthOfScreen(context),
              child: Card(
                color: Colors.white,
                elevation: 10,
                shadowColor: Colors.black54,
                child: body,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AppSubtitleText extends StatelessWidget {
  final String text;
  const AppSubtitleText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      textScaler: const TextScaler.linear(1.0),
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        fontFamily: fontFamily,
        color: ColorConstant.primaryColor,
      ),
    );
  }
}
