import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/discipline_passbook/model/discipline_student_model.dart';
import 'package:school_app/discipline_passbook/model/discipline_zone_model.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class DisciplinePassbookViewModel {
  DisciplinePassbookViewModel._();

  static final DisciplinePassbookViewModel instance =
      DisciplinePassbookViewModel._();

  Future<ApiResponse<List<DisciplineStudentModel>>>
      getStudentListForDisciplinePassbook(
          String sessionCode, String sectionCode, String studentName) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentListForDisciplinePassbook(
          sessionCode, sectionCode, studentName),
      (json) async {
        return DisciplineStudentModel.fromJsonList(json);
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<DisciplineZoneModel>>>
      getSearchedStudentDisciplineCount(
          String classCode, String sectionCode, String studentName) {
    HomeModel? homeModel = AuthViewModel.instance.homeModel;
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentDisciplineCount(
          homeModel?.sessionCode ?? "", sectionCode, studentName),
      (json) async {
        return DisciplineZoneModel.fromJsonList(json);
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
