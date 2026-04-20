import 'package:intl/intl.dart';
import 'package:school_app/attendance_daily_check_in/model/attendance_save_response_model.dart';
import 'package:school_app/attendance_daily_check_in/model/student_attendance.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';

class AttendanceCheckInViewModel {
  static AttendanceCheckInViewModel? _instance;

  static AttendanceCheckInViewModel get instance =>
      _instance ??= AttendanceCheckInViewModel._();

  AttendanceCheckInViewModel._();

  Future<ApiResponse<List<AttendanceParam>>> getAttendanceStatus() {
    return NetworkManager.instance.makeRequest(
      Endpoints.getAttendanceStatusList,
      (json) async {
        List<AttendanceParam> response = json
            .map<AttendanceParam>((json) => AttendanceParam.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<StudentAttendance>>> getStudentAttendanceList(
      String classId, String sectionId, DateTime date) {
    String formattedDate = DateFormat('dd-MM-yyyy').format(date);

    return NetworkManager.instance.makeRequest(
      Endpoints.getAttendanceList(classId, sectionId, formattedDate),
      (json) async {
        List<StudentAttendance> response = json
            .map<StudentAttendance>((json) => StudentAttendance.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> saveAttendance(
      List<AttendanceSaveResponseModel> studentAttendanceList) {
    return NetworkManager.instance.makeRequest(
      Endpoints.saveAttendanceEndpoint,
      (json) async {
        return;
      },
      body: studentAttendanceList.map((e) => e.toJson()).toList(),
      method: HttpMethod.post,
    );
  }
}
