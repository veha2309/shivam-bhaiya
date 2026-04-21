import 'dart:io';

import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/document/model/upload_document_pre_sign_response.dart';
import 'package:school_app/homework_screen/model/add_homework_model.dart';
import 'package:school_app/homework_screen/model/pendingTest_model.dart';
import 'package:school_app/homework_screen/model/subjectBook_model.dart';
import 'package:school_app/homework_screen/model/subject_model.dart';
import 'package:school_app/homework_screen/model/homework_model.dart';

import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class AddHomeworkViewModel {
  AddHomeworkViewModel._();

  static final AddHomeworkViewModel _instance = AddHomeworkViewModel._();

  static AddHomeworkViewModel get instance => _instance;

  Future<ApiResponse<List<SubjectModel>>> getSubjectCombo(
      String classCode, String sectionCode) {
    String teacherId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getSubjectComboByTeacherId(classCode, sectionCode, teacherId),
      (json) async {
        return SubjectModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<HomeworkModel>>> getTeacherHomeworkData(
      String classCode, String sectionCodes, DateTime monthYear) {
    String teacherId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
    String monthYearString =
        "${monthYear.month.toString().padLeft(2, '0')}-${monthYear.year}";

    return NetworkManager.instance.makeRequest(
      Endpoints.getTeacherHomeworkData(
          teacherId, classCode, sectionCodes, monthYearString),
      (json) async {
        return HomeworkModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<SubjectbookModel>>> getSubjectBook(
      String classCode, String sectionCode) {
    String teacherId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getTeacherSubjectAndBooks(classCode, sectionCode, teacherId),
      (json) async {
        return SubjectbookModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<PendingtestModel>>> getPendingTestList() {
    return NetworkManager.instance.makeRequest(
      Endpoints.getTestListForSection,
      (json) async {
        return PendingtestModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<PendingtestModel>>> updateTestCheckStatus(
      String sessionCode,
      String sectionCode,
      String subjectCode,
      String homeworkDate) {
    return NetworkManager.instance.makeRequest(
      Endpoints.updateRevisionTestStatus(
          sessionCode, sectionCode, subjectCode, homeworkDate),
      (json) async {
        return PendingtestModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> saveHomeWork(
      List<AddHomeworkModel> addHomeWork) async {
    return await NetworkManager.instance.makeRequest(
      Endpoints.saveHomeWork,
      (json) async {
        // Since we don't need to parse any response data, we just return void
        return;
      },
      method: HttpMethod.post,
      body: AddHomeworkModel.toJsonList(addHomeWork),
    );
  }

  Future<ApiResponse<UploadDocumentPreSignResponse>>
      getPresignUrlForHomeworkDocument(String subjectName, String fileName) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getPresignUrlForHomeworkDocument(subjectName, fileName),
      (json) async {
        return UploadDocumentPreSignResponse.fromJson(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<void>> uploadHomeworkDocument(
      File file, String presignUrl) {
    return NetworkManager.instance.uploadFile(
      "",
      file,
      (json) async {
        return;
      },
      fullEndpoint: presignUrl,
    );
  }
}
