import 'package:school_app/discipline/model/discipline_data.dart';
import 'package:school_app/discipline/model/save_discipline_model.dart';
import 'package:school_app/discipline/model/student_discipline_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class DisciplineViewModel {
  DisciplineViewModel._();

  static final DisciplineViewModel instance = DisciplineViewModel._();

  Future<ApiResponse<DisciplineModel>> searchStudentDisplineList(
      String sectionCode, DateTime disciplineDate) async {
    return NetworkManager.instance.makeRequest(
        Endpoints.searchDiscipline(sectionCode, disciplineDate), (json) async {
      List<dynamic> list = json as List<dynamic>;
      if (list.isNotEmpty) {
        DisciplineModel disciplineModel = DisciplineModel.fromJson(list.first);
        return disciplineModel;
      }
      throw Exception('No data found');
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<DisciplineData>> getStudentDisciplineDataForView(
      String studentId, DateTime disciplineDate) async {
    return NetworkManager.instance.makeRequest(
        Endpoints.getDisciplineEntryForStudentForView(
            studentId, disciplineDate), (json) async {
      List<dynamic> jsonList = json as List<dynamic>? ?? [];
      if (jsonList.isEmpty) {
        throw Exception('No data found');
      }
      DisciplineData disciplineData = DisciplineData.fromJson(jsonList.first);
      return disciplineData;
    }, method: HttpMethod.get);
  }

  // Future<ApiResponse<List<DisciplineTypeModel>>>
  //     getStudentDisciplineDataForEntry(String studentId) async {
  //   return NetworkManager.instance
  //       .makeRequest(Endpoints.getDisciplineEntryForStudentForEntry(studentId),
  //           (json) async {
  //     List<dynamic> list = json as List<dynamic>;
  //     List<DisciplineTypeModel> disciplineData =
  //         list.map((item) => DisciplineTypeModel.fromJson(item)).toList();
  //     return disciplineData;
  //   }, method: HttpMethod.get);
  // }

  Future<ApiResponse<void>> markNoDefaults(
      String sectionCode, DateTime disciplineDate) async {
    return NetworkManager.instance.makeRequest(
        Endpoints.markNoDefaulter(sectionCode, disciplineDate), (json) async {
      return;
    }, method: HttpMethod.post);
  }

  Future<ApiResponse<void>> saveDisciplineDate(
      List<SaveDisciplineModel> model) async {
    return NetworkManager.instance.makeRequest(
      Endpoints.saveDisciplineData,
      (json) async {
        return;
      },
      method: HttpMethod.post,
      body: model.map((element) => element.toJson()).toList(),
    );
  }
}
