import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/homework_screen/model/examSchedule_model.dart';
import 'package:school_app/homework_screen/model/homework_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class HomeworkViewModel {
  HomeworkViewModel._();

  static final HomeworkViewModel instance = HomeworkViewModel._();

  Future<ApiResponse<List<HomeworkModel>>> getHomeWork(
      DateTime monthYear) async {
    String monthYearString =
        "${monthYear.month.toString().padLeft(2, '0')}-${monthYear.year}";
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentHomeWorkForMonth(studentId, monthYearString),
      (json) async {
        return HomeworkModel.fromJsonList(json);
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<ExamScheduleModel>> getExamSchedule(
      String sectionId) async {
    return NetworkManager.instance.makeRequest(
      Endpoints.getExamSchedule(sectionId),
      (json) async {
        return ExamScheduleModel.fromJson(json);
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
