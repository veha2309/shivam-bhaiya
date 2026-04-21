import 'package:school_app/attendance_screen/model/view_attendance.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class ViewAttendanceViewModel {
  ViewAttendanceViewModel._();

  static final ViewAttendanceViewModel _instance = ViewAttendanceViewModel._();

  static ViewAttendanceViewModel get instance => _instance;

  Future<ApiResponse<List<StudentViewAttendance>>> getViewAttendanceData(
      String classCode, String sectionCode, String monthCode) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getViewAttendanceEndpoint(classCode, sectionCode, monthCode),
      (json) async {
        List<StudentViewAttendance> response = json
            .map<StudentViewAttendance>(
                (json) => StudentViewAttendance.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<TeacherAttendanceStatus>>>
      getTeacherAttendanceStatus() {
    User? user = AuthViewModel.instance.getLoggedInUser();
    HomeModel? homeModel = AuthViewModel.instance.homeModel;

    return NetworkManager.instance.makeRequest(
      Endpoints.getTeacherAttendanceStatusEndpoint(
          homeModel?.sessionCode ?? "", user?.username ?? ""),
      (json) async {
        List<TeacherAttendanceStatus> response = json
            .map<TeacherAttendanceStatus>(
                (json) => TeacherAttendanceStatus.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<StudentDailyAttendance>>> getSectionWiseAttendance(
      String sectionCode) {
    User? user = AuthViewModel.instance.getLoggedInUser();
    HomeModel? homeModel = AuthViewModel.instance.homeModel;

    return NetworkManager.instance.makeRequest(
      Endpoints.getSectionWiseAttendanceEndpoint(
          homeModel?.sessionCode ?? "", sectionCode, user?.username ?? ""),
      (json) async {
        List<StudentDailyAttendance> response = json
            .map<StudentDailyAttendance>(
                (json) => StudentDailyAttendance.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
