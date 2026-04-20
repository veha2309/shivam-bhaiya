import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/school_details/model/class.dart';
import 'package:school_app/school_details/model/section.dart';
import 'package:school_app/school_details/model/session.dart';
import 'package:school_app/utils/constants.dart';
import 'package:school_app/utils/device_utils.dart';

class SchoolDetailsViewModel {
  SchoolDetailsViewModel._();

  static SchoolDetailsViewModel? _instance;

  static SchoolDetailsViewModel get instance =>
      _instance ??= SchoolDetailsViewModel._();

  Future<ApiResponse<List<Session>>> getSessionList() {
    return NetworkManager.instance.makeRequest(
      Endpoints.getSessionEndpoint,
      (json) async {
        List<Session> response =
            json.map<Session>((json) => Session.fromJson(json)).toList();
        try {
          response.sort((a, b) {
            // Extract numbers from sectionCode like "BRN11" => 11
            int aNum =
                int.parse(RegExp(r'\d+').firstMatch(a.sessionCode)!.group(0)!);
            int bNum =
                int.parse(RegExp(r'\d+').firstMatch(b.sessionCode)!.group(0)!);
            return aNum >= bNum ? -1 : 1;
          });
        } catch (_) {}
        return response;
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<ClassModel>>> getClassList() {
    User? teacher = AuthViewModel.instance.getLoggedInUser();

    String endpoint = Endpoints.getClassEndpoint(teacher?.username ?? "");
    return NetworkManager.instance.makeRequest(
      endpoint,
      (json) async {
        List<ClassModel> response =
            json.map<ClassModel>((json) => ClassModel.fromJson(json)).toList();
        try {
          response.sort((a, b) {
            // Extract numbers from sectionCode like "BRN11" => 11
            int aNum =
                int.parse(RegExp(r'\d+').firstMatch(a.classCode)!.group(0)!);
            int bNum =
                int.parse(RegExp(r'\d+').firstMatch(b.classCode)!.group(0)!);
            return aNum <= bNum ? -1 : 1;
          });
        } catch (_) {}
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<Section>>> getSectionList(String classId) {
    User? teacher = AuthViewModel.instance.getLoggedInUser();
    String endpoint =
        Endpoints.getSectionEndpoint(teacher?.username ?? "", classId);
    return NetworkManager.instance.makeRequest(
      endpoint,
      (json) async {
        List<Section> response =
            json.map<Section>((json) => Section.fromJson(json)).toList();
        try {
          response.sort((a, b) {
            // Extract numbers from sectionCode like "BRN11" => 11
            int aNum =
                int.parse(RegExp(r'\d+').firstMatch(a.sectionCode)!.group(0)!);
            int bNum =
                int.parse(RegExp(r'\d+').firstMatch(b.sectionCode)!.group(0)!);
            return aNum <= bNum ? -1 : 1;
          });
        } catch (_) {}

        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> registerDeviceForNotifications() async {
    User? user = AuthViewModel.instance.getLoggedInUser();

    String? deviceId = DeviceInfoService.deviceId;

    if (user == null || deviceId == null) {
      return ApiResponse.failure("User or DeviceId is null");
    }

    String endpoint =
        Endpoints.registerDeviceForNotification(user.username, deviceId);

    return NetworkManager.instance.makeRequest(
      endpoint,
      (json) async {
        return;
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> subscribeTopicId() async {
    User? user = AuthViewModel.instance.getLoggedInUser();

    if (user == null) {
      return ApiResponse.failure("User is null");
    }

    String affiliationCode = user.affiliationCode ?? "";

    String? firebaseToken = DeviceInfoService.firebaseToken;
    String? deviceId = DeviceInfoService.deviceId;

    if (firebaseToken == null) {
      return ApiResponse.failure("Firebase token is null");
    }

    if (deviceId == null) {
      return ApiResponse.failure("Device ID is null");
    }

    String endpoint = Endpoints.subscribeTokenForNotification;

    Map<String, dynamic> body = {
      "affiliationcode": affiliationCode,
      "userid": user.username,
      "deviceid": deviceId,
      "token": firebaseToken,
    };

    return NetworkManager.instance.makeRequest(
      endpoint,
      (json) async {
        return;
      },
      body: body,
      method: HttpMethod.post,
    );
  }
}
