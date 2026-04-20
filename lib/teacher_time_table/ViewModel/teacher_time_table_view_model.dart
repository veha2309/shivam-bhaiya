import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/teacher_time_table/Model/teacher_time_table.dart';

class TeacherTimeTableViewModel {
  TeacherTimeTableViewModel._();

  static final TeacherTimeTableViewModel _instance =
      TeacherTimeTableViewModel._();

  static TeacherTimeTableViewModel get instance => _instance;

  Future<ApiResponse<TeacherTimetableModel>> getTeacherTimeTableDetails(
      String teacherId) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getTeacherTimetableDetails(teacherId), (json) async {
      return TeacherTimetableModel.fromJson(json);
    }, method: HttpMethod.get);
  }
}
