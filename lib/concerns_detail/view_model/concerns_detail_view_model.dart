import 'package:school_app/concerns_detail/model/concerns_detail_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class ConcernsDetailViewModel {
  ConcernsDetailViewModel._();

  static final ConcernsDetailViewModel _instance = ConcernsDetailViewModel._();

  static ConcernsDetailViewModel get instance => _instance;

  Future<ApiResponse<List<ConcernsDetailModel>>>
      getStudentDisciplineAcademicArray(String studentId, String sessionCode) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentDisciplineAcademicArray(studentId, sessionCode),
      (json) async {
        if (json is List) {
          return ConcernsDetailModel.fromJsonList(json);
        }
        return [];
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<ConcernsDetailModel>>>
      getStudentDisciplineDefaulterData(String studentId, String sessionCode) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentDisciplineDefaulterData(studentId, sessionCode),
      (json) async {
        if (json is List) {
          return ConcernsDetailModel.fromJsonList(json);
        }
        return [];
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<ConcernsDetailModel>>> getStudentDisciplineCardArray(
      String studentId, String sessionCode) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentDisciplineCardArray(studentId, sessionCode),
      (json) async {
        if (json is List) {
          return ConcernsDetailModel.fromJsonList(json);
        }
        return [];
      },
      method: HttpMethod.get,
    );
  }
}
