import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/upload_marks/Model/attendance_param.dart';
import 'package:school_app/upload_marks/Model/student_marks.dart';
import 'package:school_app/upload_marks/Model/upload_marks_response_model.dart';
import 'package:school_app/upload_marks/Model/upload_subject_marks.dart';

class UploadMarksViewModel {
  UploadMarksViewModel._();

  static final UploadMarksViewModel instance = UploadMarksViewModel._();

  Future<ApiResponse<List<UploadSubjectMarks>>> getSubjectForMarksWithStatus(
      String status) {
    String teacherId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getSubjectAsPerStatus(teacherId, status),
      (json) async {
        List<UploadSubjectMarks> response = json
            .map<UploadSubjectMarks>(
                (json) => UploadSubjectMarks.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<StudentMarks>>> getStudentListForSubject(
      UploadSubjectMarks subject) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentListForSubject(subject),
      (json) async {
        List<StudentMarks> response = json
            .map<StudentMarks>((json) => StudentMarks.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<AttendanceParam>>> getAttendanceParams() {
    return NetworkManager.instance.makeRequest(
      Endpoints.getAttendanceTypeForMarks(),
      (json) async {
        List<AttendanceParam> response = json
            .map<AttendanceParam>((json) => AttendanceParam.fromJson(json))
            .toList();
        return response;
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> uploadMarks(UploadMarksResponseModel uploadMarks) {
    return NetworkManager.instance.makeRequest(
      Endpoints.saveStudentExamMarks,
      (json) async {
        return;
      },
      body: uploadMarks.toJson(),
      method: HttpMethod.post,
    );
  }
}
