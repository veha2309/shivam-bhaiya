import 'package:flutter/material.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/no_data_widget.dart';

class AppFutureBuilder<T> extends StatelessWidget {
  final Future<T>? future;
  final Widget Function(BuildContext, AsyncSnapshot<T>) builder;
  const AppFutureBuilder(
      {super.key, required this.future, required this.builder});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: getLoaderWidget());
        } else if (snapshot.hasError) {
          return const NoDataWidget();
        } else if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data == null) {
            return const NoDataWidget();
          }
          return builder.call(context, snapshot);
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
