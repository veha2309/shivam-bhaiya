import 'package:flutter/material.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/no_data_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_app/utils/utils.dart';
import 'package:school_app/vquick/model/document_link.dart';
import 'package:school_app/vquick/viewmodel/vquick_viewmodel.dart';

class VQuickScreen extends StatefulWidget {
  static const String routeName = '/vquick';
  final String? title;
  const VQuickScreen({super.key, this.title});

  @override
  State<VQuickScreen> createState() => _VQuickScreenState();
}

class _VQuickScreenState extends State<VQuickScreen> {
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<List<VQuickModel>>? getVQuickDataFuture;
  List<VQuickModel> vquickData = [];

  @override
  void initState() {
    super.initState();
    _fetchVQuickData();
  }

  void _fetchVQuickData() {
    setState(() {
      getVQuickDataFuture =
          VQuickViewModel.instance.getVQuickData().then((data) {
        vquickData = data;
        return data;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "VQuick",
        body: _buildVQuickBody(context),
      ),
    );
  }

  Widget _buildVQuickBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: AppFutureBuilder(
              future: getVQuickDataFuture,
              builder: (context, snapshot) {
                if (vquickData.isEmpty) {
                  return const NoDataWidget();
                }
                return _buildQRGrid();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
      ),
      itemCount: vquickData.length,
      itemBuilder: (context, index) {
        final item = vquickData[index];
        return InkWell(
          onTap: () => launchURLString(item.url ?? ""),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.black,
                width: 1.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Text(
                    item.title ?? '',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      fontFamily: fontFamily,
                      color: ColorConstant.primaryColor,
                    ),
                  ),
                ),
                const Divider(
                  color: Colors.black,
                  height: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: QrImageView(
                      data: item.url ?? "",
                      version: QrVersions.auto,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
