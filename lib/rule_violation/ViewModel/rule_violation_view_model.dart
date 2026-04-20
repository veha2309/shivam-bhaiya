import 'package:school_app/attendance_daily_check_in/model/student_attendance.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/rule_violation/Model/rule_violation_detail.dart';

class RulesViolationViewModel {
  RulesViolationViewModel._();

  static final RulesViolationViewModel instance = RulesViolationViewModel._();

  Future<ApiResponse<List<StudentAttendance>>>
      searchStudentRulesViolationListUsingClassAndSection(
          String classId, String sectionId) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentSearchListUsingClassAndSection(classId, sectionId),
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

  Future<ApiResponse<List<StudentAttendance>>>
      searchStudentRulesViolationListUsingName(String name) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentSearchListUsingName(name),
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

  Future<ApiResponse<List<RuleViolationDetail>>> getStudentRuleViolationDetails(
      String studentId) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentRuleViolationDetails(studentId),
      (json) async {
        return RuleViolationDetail.fromJsonList(json);
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
