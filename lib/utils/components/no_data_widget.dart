import 'package:flutter/material.dart';
import 'package:school_app/utils/constants.dart';

class NoDataWidget extends StatelessWidget {
  const NoDataWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: Image.asset(
          ImageConstants.noData,
        ),
      ),
    );
  }
}
