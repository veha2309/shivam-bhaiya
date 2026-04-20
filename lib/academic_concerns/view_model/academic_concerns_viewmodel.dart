import 'package:school_app/academic_concerns/model/academic_concern_response.dart';
import 'package:school_app/academic_concerns/model/save_academic_concern.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class AcademicConcernsViewmodel {
  AcademicConcernsViewmodel._();
  static AcademicConcernsViewmodel? _instance;
  static AcademicConcernsViewmodel get instance =>
      _instance ??= AcademicConcernsViewmodel._();

  Future<ApiResponse<AcademicConcernResponse>> saveAcademicConcerns(
      List<SaveAcademicConcern> concerns) async {
    return await NetworkManager.instance.makeRequest(
      Endpoints.saveAcademicData,
      (json) async => AcademicConcernResponse.fromJson(json),
      method: HttpMethod.post,
      body: SaveAcademicConcern.toJsonList(concerns),
    );
  }

  Future<ApiResponse> getDisciplineDetailsForTeachers(String studentId) async {
    return await NetworkManager.instance.makeRequest(
      Endpoints.getAcademicData(studentId),
      (json) async {
        return json;
      },
      method: HttpMethod.get,
    );
  }
}
