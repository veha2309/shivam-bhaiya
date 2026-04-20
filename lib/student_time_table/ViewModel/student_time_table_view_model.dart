import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/student_time_table/Model/student_time_table.dart';

class StudentTimeTableViewModel {
  StudentTimeTableViewModel._();

  static final StudentTimeTableViewModel _instance =
      StudentTimeTableViewModel._();

  static StudentTimeTableViewModel get instance => _instance;

  Future<ApiResponse<List<Lecture>>> getStudentTimeTable(String day) {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentTimeTable(studentId, day),
      (json) async {
        List<dynamic> data = json as List<dynamic>;
        List<Lecture> schedules = data.map((e) => Lecture.fromJson(e)).toList();
        return schedules;
      },
      method: HttpMethod.get,
    );
  }
}
