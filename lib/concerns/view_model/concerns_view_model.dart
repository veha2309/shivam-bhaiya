import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/network_manager/api_response.dart';
import '../model/student.dart';

class ConcernsViewModel {
  final NetworkManager _networkManager = NetworkManager.instance;

  // Get student academic discipline searched list
  Future<ApiResponse<List<Student>>> getStudentAcademicDisciplineSearchedList(
      String sectionCode, String studentName) async {
    return _networkManager.makeRequest<List<Student>>(
      Endpoints.getStudentAcademicDisciplineSearchedList(
          sectionCode, studentName),
      (json) async {
        if (json is List) {
          return json.map((item) => Student.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  // Get student discipline searched list
  Future<ApiResponse<List<Student>>> getStudentDisciplineSearchedList(
      String sectionCode, String studentName) async {
    return _networkManager.makeRequest<List<Student>>(
      Endpoints.getStudentDisciplineSearchedList(sectionCode, studentName),
      (json) async {
        if (json is List) {
          return json.map((item) => Student.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  // Get student discipline card searched list
  Future<ApiResponse<List<Student>>> getStudentDisciplineCardSearchedList(
      String sectionCode, String studentName) async {
    return _networkManager.makeRequest<List<Student>>(
      Endpoints.getStudentDisciplineCardSearchedList(sectionCode, studentName),
      (json) async {
        if (json is List) {
          return json.map((item) => Student.fromJson(item)).toList();
        }
        return [];
      },
    );
  }
}
