import 'dart:convert';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/student_dossier_detail/Model/academic_discipline_model.dart';
import 'package:school_app/student_dossier_detail/Model/academic_record_model.dart';
import 'package:school_app/student_dossier_detail/Model/attandance_record_model.dart';
import 'package:school_app/student_dossier_detail/Model/discipline_record_model.dart';
import 'package:school_app/student_dossier_detail/Model/health_record_model.dart';
import 'package:school_app/student_dossier_detail/Model/library_record_model.dart';
import 'package:school_app/student_dossier_detail/Model/reward_recognition_model.dart';
import 'package:school_app/student_dossier_detail/Model/student_dashboard_model.dart';
import 'package:school_app/student_dossier_detail/Model/student_feedback_model.dart';

class StudentDossierDetailViewModel {
  StudentDossierDetailViewModel._();

  static final StudentDossierDetailViewModel _instance =
      StudentDossierDetailViewModel._();

  static StudentDossierDetailViewModel get instance => _instance;

  Future<ApiResponse<StudentDashboardModel>> getStudentDossierDashboardDetails(
      {required String studentId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getDossierDashboardEndpoint(studentId), (json) async {
      return StudentDashboardModel.fromJson((json as List<dynamic>).first);
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<AcademicRecordDossier>>>
      getDossierAcademicRecordDetail(
          {required String studentId, required String sessionId}) {
    return NetworkManager.instance
        .makeRequest(Endpoints.getStudentDossierExamMarks(studentId, sessionId),
            (json) async {
      List<dynamic> list = json as List<dynamic>;
      return list.map((e) => AcademicRecordDossier.fromJson(e)).toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<AcademicDisciplineModel>>> getDossierAcademicDetail(
      {required String sessionId, required String studentId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDossierDisciplineAcademicArray(
            studentId, sessionId), (json) async {
      List<dynamic> list = json as List<dynamic>;
      return list.map((e) => AcademicDisciplineModel.fromJson(e)).toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<AttandanceRecordModel>>>
      getDossierAttandanceRecordViewAttandanceDetail(
          {required String studentId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDossierAttendanceDetail(studentId), (json) async {
      List<dynamic> list = json as List<dynamic>;
      return list.map((e) => AttandanceRecordModel.fromJson(e)).toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<DisciplineRecordModel>>>
      getDossierDisciplineRecordDetail(
          {required String studentId, required String sessionId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDossierDisciplineArray(studentId, sessionId),
        (json) async {
      List<dynamic> list = json as List<dynamic>;

      List<DisciplineRecordModel> disciplineRecordList = [];

      for (Map<String, dynamic> item in list) {
        if (item['jsonData'] != null) {
          List<dynamic> disciplineRecordJson = jsonDecode(item['jsonData']);

          for (Map<String, dynamic> listItem in disciplineRecordJson) {
            disciplineRecordList.add(DisciplineRecordModel.fromJson(listItem));
          }
        }
      }

      return disciplineRecordList;
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<HealthRecordModel>>> getDossierHealthDetail(
      {required String studentId, required String sessionId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDossierHealthArray(studentId, sessionId),
        (json) async {
      List<dynamic> list = json as List<dynamic>;
      return list.map((e) => HealthRecordModel.fromJson(e)).toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<LibraryRecordModel>>> getDossierLibraryDetail(
      {required String studentId, required String sessionId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDossierLibraryArray(studentId, sessionId),
        (json) async {
      List<dynamic> list = json as List<dynamic>;
      return list.map((e) => LibraryRecordModel.fromJson(e)).toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<RewardRecognitionModel>>> getDossierRewardDetail(
      {required String studentId, required String sessionId}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentDossierAwardsArray(studentId, sessionId),
        (json) async {
      List<dynamic> list = json as List<dynamic>;
      return list.map((e) => RewardRecognitionModel.fromJson(e)).toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<StudentFeedbackModel>>> getStudentFeedback(
      {required String studentId, required String sessionCode}) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentObservationArray(studentId, sessionCode),
        (json) async {
      List<dynamic> list = json as List<dynamic>;

      List<StudentFeedbackModel> feedbackList = [];

      for (Map<String, dynamic> item in list) {
        if (item['jsonData'] != null) {
          try {
            // Parse the jsonData string into a List of observations
            List<dynamic> observationData = jsonDecode(item['jsonData']);

            // Create a copy of the item with the parsed observations
            Map<String, dynamic> itemWithParsedData = Map.from(item);
            itemWithParsedData['observations'] = observationData;

            feedbackList.add(StudentFeedbackModel.fromJson(item));
          } catch (e) {
            // Error parsing student feedback
          }
        }
      }

      return feedbackList;
    }, method: HttpMethod.get);
  }
}
