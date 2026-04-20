import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/transport_tracker_screen/model/location_tracker.dart';

class TransportTrackerViewmodel {
  TransportTrackerViewmodel._();

  static TransportTrackerViewmodel? _instance;

  static TransportTrackerViewmodel get instance =>
      _instance ??= TransportTrackerViewmodel._();

  Future<ApiResponse<VehicleInfo>> getTransportStatus() {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getTransportTrackerEndpoint(studentId),
      (json) async {
        return VehicleInfo.fromJson(json);
      },
      method: HttpMethod.get,
    );
  }
}
