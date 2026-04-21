import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/search_student_profile/Model/search_student_model.dart';
import 'package:school_app/search_student_profile/Model/search_student_profile.dart';

class SearchStudentProfileViewModel {
  SearchStudentProfileViewModel._();

  static final SearchStudentProfileViewModel instance =
      SearchStudentProfileViewModel._();

  Future<ApiResponse<List<Student>>> searchStudentListUsingClassAndSection(
      String classId, String sectionId) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentSearchListUsingClassAndSection(classId, sectionId),
      (json) async {
        List<Student> response =
            json.map<Student>((json) => Student.fromJson(json)).toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<Student>>> searchStudentListUsingName(String name) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentSearchListUsingName(name),
      (json) async {
        List<Student> response =
            json.map<Student>((json) => Student.fromJson(json)).toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<SearchStudentModel>>>
      searchStudentListForStudentProfile(
          String classId, String sectionId, String name) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentSearchList(classId, sectionId, name),
      (json) async {
        List<SearchStudentModel> response = json
            .map<SearchStudentModel>(
                (json) => SearchStudentModel.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
