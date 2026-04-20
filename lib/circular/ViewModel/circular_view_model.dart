import 'package:school_app/circular/Model/circular_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class CircularViewModel {
  CircularViewModel._();

  static final CircularViewModel instance = CircularViewModel._();

  Future<ApiResponse<List<CircularModel>>> getCircularListForStudent(
      int page, String query) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getCircularListForStudent(page, query),
      (json) async {
        List<CircularModel> response = json['data']
            .map<CircularModel>((json) => CircularModel.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCircularReadStatus(
      String noticeId) {
    return NetworkManager.instance.makeRequest(
      Endpoints.updateCircularReadStatus(noticeId),
      (json) async {
        return json as Map<String, dynamic>;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateCircularPinnedStatus(
      List<String> noticeIds, String pinStatus) {
    return NetworkManager.instance.makeRequest(
      Endpoints.updateCircularPinnedStatus(noticeIds, pinStatus),
      (json) async {
        return json as Map<String, dynamic>;
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
