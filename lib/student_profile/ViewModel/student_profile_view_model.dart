import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/student_profile/Model/student_profile.dart';

class StudentProfileDetailViewModel {
  StudentProfileDetailViewModel._();

  static final StudentProfileDetailViewModel _instance =
      StudentProfileDetailViewModel._();

  static StudentProfileDetailViewModel get instance => _instance;

  Future<ApiResponse<StudentProfile>> getStudentProfileDetails(
      String studentId) {
    return NetworkManager.instance
        .makeRequest(Endpoints.getStudentProfileInfo(studentId), (json) async {
      return StudentProfile.fromJson((json as List<dynamic>).first);
    }, method: HttpMethod.get);
  }
}
