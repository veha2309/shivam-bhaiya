import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/student_dossier/Model/student_dossier.dart';

class StudentDossierSearchViewModel {
  StudentDossierSearchViewModel._();

  static final StudentDossierSearchViewModel _instance =
      StudentDossierSearchViewModel._();

  static StudentDossierSearchViewModel get instance => _instance;

  Future<ApiResponse<List<StudentDossier>>> getDossierAcademicDetail(
      String classCode,
      String sectionCode,
      String admissionNo,
      String studentName) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDetailForDossier(
            classCode, sectionCode, admissionNo, studentName), (json) async {
      return (json as List<dynamic>)
          .map((e) => StudentDossier.fromJson(e))
          .toList();
    }, method: HttpMethod.get);
  }
}
