import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/transport_tracker_screen/model/location_tracker.dart';
import 'package:school_app/transport_tracker_screen/view_model/transport_tracker_viewmodel.dart';
import 'package:school_app/utils/components/app_button.dart';
import 'package:school_app/utils/components/app_future_builder.dart';
import 'package:school_app/utils/components/app_scaffold.dart';
import 'package:school_app/utils/components/body.dart';
import 'package:school_app/utils/components/map_widget.dart';
import 'package:school_app/utils/components/table_widget.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/utils.dart';

final class TransportTrackerScreen extends StatefulWidget {
  static const String routeName = '/transport-tracker';
  final String? title;
  const TransportTrackerScreen({super.key, this.title});

  @override
  State<TransportTrackerScreen> createState() => _TransportTrackerScreenState();
}

class _TransportTrackerScreenState extends State<TransportTrackerScreen> {
  // GoogleMapController? _controller;
  ValueNotifier<bool> isLoadingNotifier = ValueNotifier(false);
  Future<ApiResponse<VehicleInfo>>? getVehicleInfoFuture;
  DeviceInfo? deviceInfo;
  EventData? eventData;
  LatLng? bounds;

  @override
  void initState() {
    super.initState();
    callGetLocationIntoFuture();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      isLoadingNotifier: isLoadingNotifier,
      body: AppBody(
        title: widget.title ?? "Transport Tracker",
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SingleChildScrollView(
            child: AppFutureBuilder(
              future: getVehicleInfoFuture,
              builder: (context, snapshot) {
                return transportTrackerBody(context, snapshot.data!.data!);
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget transportTrackerBody(BuildContext context, VehicleInfo vehicleInfo) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        spacing: 16.0,
        children: [
          TableWidget(
            rows: getRows(vehicleInfo),
          ),
          AppButton(
            onPressed: (_) {
              setState(() {
                callGetLocationIntoFuture();
              });
            },
            text: "Locate",
          ),
          if (bounds != null)
            SizedBox(
              height: 300,
              child: MapScreen(
                pinLocation: bounds!,
              ),
            ),
        ],
      ),
    );
  }

  void callGetLocationIntoFuture() {
    getVehicleInfoFuture = TransportTrackerViewmodel.instance
        .getTransportStatus()
        .then((response) {
      if (response.success && response.data != null) {
        updateVehicleInfo(response.data!);
      }
      return response;
    });
  }

  List<TableRowConfiguration> getRows(VehicleInfo vehicleInfo) {
    String? route;
    String? speed;
    String? lastUpdated;

    route = eventData?.address;
    speed = "${eventData?.speed} ${eventData?.speedUnits}";
    lastUpdated = "${eventData?.timestampDate} ${eventData?.timestampTime}";

    return [
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Driver Name", padding: const EdgeInsets.only(left: 8.0)),
          TableCellConfiguration(
              text: vehicleInfo.driverName, padding: const EdgeInsets.all(8.0))
        ],
      ),
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Driver Contact", padding: const EdgeInsets.all(8.0)),
          TableCellConfiguration(
              text: vehicleInfo.mobileNo, padding: const EdgeInsets.all(8.0))
        ],
      ),
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Vehicle Number", padding: const EdgeInsets.all(8.0)),
          TableCellConfiguration(
              text: vehicleInfo.vehicleNumber,
              padding: const EdgeInsets.all(8.0))
        ],
      ),
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Vehicle Type", padding: const EdgeInsets.all(8.0)),
          TableCellConfiguration(
              text: vehicleInfo.vehicleType, padding: const EdgeInsets.all(8.0))
        ],
      ),
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Route", padding: const EdgeInsets.all(8.0)),
          TableCellConfiguration(
              text: route ?? '--', padding: const EdgeInsets.all(8.0))
        ],
      ),
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Speed", padding: const EdgeInsets.all(8.0)),
          TableCellConfiguration(
              text: speed, padding: const EdgeInsets.all(8.0))
        ],
      ),
      TableRowConfiguration(
        rowHeight: 45,
        cells: [
          TableCellConfiguration(
              text: "Last Updated", padding: const EdgeInsets.all(8.0)),
          TableCellConfiguration(
              text: lastUpdated, padding: const EdgeInsets.all(8.0))
        ],
      ),
    ];
  }

  void updateVehicleInfo(VehicleInfo vehicleInfo) {
    setState(() {
      if (vehicleInfo.deviceList?.isNotEmpty ?? false) {
        deviceInfo = vehicleInfo.deviceList?.first;
        if (deviceInfo != null &&
            (deviceInfo?.eventData?.isNotEmpty ?? false)) {
          eventData = deviceInfo!.eventData?.first;
          if (eventData != null) {
            bounds = LatLng(
                eventData!.gpsPointLat ?? 0.0, eventData!.gpsPointLon ?? 0.0);
          }
        }
      }
    });
  }
}
