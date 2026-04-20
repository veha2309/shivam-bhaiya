import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_daywise_model.dart';
import 'package:school_app/attendance_reconciliation/model/attandance_reconcilliation_student_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class AttendanceReconViewmodel {
  AttendanceReconViewmodel._();

  static AttendanceReconViewmodel? _instance;

  static AttendanceReconViewmodel get instance =>
      _instance ??= AttendanceReconViewmodel._();

  Future<ApiResponse<List<AttandanceReconcilliationStudentModel>>>
      fetchAttendanceData(String sessionCode, String classCode,
          String sectionCode, String month) async {
    return NetworkManager.instance.makeRequest(
      Endpoints.getAttendanceReconList(
          sessionCode, classCode, sectionCode, month),
      (json) async {
        List<AttandanceReconcilliationStudentModel> response = json
            .map<AttandanceReconcilliationStudentModel>(
                (json) => AttandanceReconcilliationStudentModel.fromJson(json))
            .toList();
        return response;
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<AttandanceReconcilliationDaywiseModel>>>
      fetchAttendanceDataByStudentId(
          String sessionCode, String month, String studentId) async {
    return NetworkManager.instance.makeRequest(
      Endpoints.getAttendanceReconData(sessionCode, studentId, month),
      (json) async {
        List<AttandanceReconcilliationDaywiseModel> response = json
            .map<AttandanceReconcilliationDaywiseModel>(
                (json) => AttandanceReconcilliationDaywiseModel.fromJson(json))
            .toList();
        return response;
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> saveMonthlyAttendanceRecord(
    List<AttandanceReconcilliationStudentModel> dataList,
  ) async {
    return await NetworkManager.instance.makeRequest<void>(
      Endpoints.saveMonthlyAttendanceRecord,
      (json) async {
        // Since we don't need to parse any response data, we just return void
        return;
      },
      method: HttpMethod.post,
      body: AttandanceReconcilliationStudentModel.toJsonList(dataList),
    );
  }
}
