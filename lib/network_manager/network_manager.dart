import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/upload_marks/Model/upload_subject_marks.dart';

enum HttpMethod { get, post, put, delete, option }

class NetworkManager {
  NetworkManager._();

  static NetworkManager? _instance;

  static NetworkManager get instance => _instance ??= NetworkManager._();

  Map<String, String> headers = {
    "Host": "vivekanandschool.in",
    "Sec-Fetch-Site": "cross-site",
    "Origin": "ionic://localhost",
    "Sec-Fetch-Mode": "cors",
    "Accept": "application/json",
    "User-Agent":
        "Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148",
    "Sec-Fetch-Dest": "empty",
    "Accept-Language": "en-IN,en-GB;q=0.9,en;q=0.8",
    "Content-Type": "application/json",
  };

  String? getAccessToken() {
    try {
      return AuthViewModel.instance.getLoggedInUser()?.accessToken;
    } catch (e) {
      return null;
    }
  }

  void setAccessToken() {
    String? accessToken = getAccessToken();
    if (accessToken == null) {
      return;
    }
    headers["Authorization"] = "Bearer $accessToken";
  }

  /// **Check for internet connection**
  Future<bool> hasInternetConnection() async {
    List<ConnectivityResult> connectivityResults =
        await Connectivity().checkConnectivity();

    // Return true if any connectivity result is WiFi or mobile data
    return connectivityResults.contains(ConnectivityResult.wifi) ||
        connectivityResults.contains(ConnectivityResult.mobile);
  }

  Future<ApiResponse<T>> makeRequest<T>(
    String endpoint,
    Future<T> Function(dynamic json) fromJson, {
    bool removeHeaders = false,
    String? fullEndpoint,
    HttpMethod method = HttpMethod.get,
    dynamic body,
  }) async {
    try {
      // Check for internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse.failure("No internet connection. Please try again.");
      }

      Uri uri;

      var headers = removeHeaders ? null : this.headers;

      if (fullEndpoint != null) {
        headers = {};
        uri = Uri.parse(fullEndpoint);
      } else {
        uri = Uri.parse("${Endpoints.baseUrl}$endpoint");
      }

      late http.Response response;

      if (!removeHeaders) {
        setAccessToken();
      }

      if (method == HttpMethod.get) {
        response = await http.get(uri, headers: removeHeaders ? null : headers);
      } else if (method == HttpMethod.post) {
        response = await http.post(uri,
            headers: removeHeaders ? null : headers, body: jsonEncode(body));
      } else if (method == HttpMethod.put) {
        response = await http.put(uri,
            headers: removeHeaders ? null : headers, body: jsonEncode(body));
      } else if (method == HttpMethod.delete) {
        response =
            await http.delete(uri, headers: removeHeaders ? null : headers);
      } else if (method == HttpMethod.option) {
        var request = http.Request("OPTIONS", uri);
        if (!removeHeaders) {
          request.headers.addAll(headers ?? {}); // Add headers if needed
        }

        var streamedResponse = await http.Client().send(request);
        response = await http.Response.fromStream(streamedResponse);
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!isValidJson(response.body)) {
          if (response.body.isEmpty) {
            return ApiResponse.success();
          }

          return ApiResponse.success(data: await fromJson(response.body));
        }
        final jsonData = jsonDecode(response.body);
        return ApiResponse.success(data: await fromJson(jsonData));
      } else {
        return ApiResponse.failure('Something went wrong');
      }
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }

  bool isValidJson(String input) {
    try {
      jsonDecode(input);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    File file,
    Future<T> Function(dynamic json) fromJson, {
    String? fullEndpoint,
    Map<String, String>? additionalHeaders,
    Map<String, String>? fields,
  }) async {
    try {
      // Check for internet connection
      if (!await hasInternetConnection()) {
        return ApiResponse.failure("No internet connection. Please try again.");
      }

      Uri uri;
      if (fullEndpoint != null) {
        uri = Uri.parse(fullEndpoint);
      } else {
        uri = Uri.parse("${Endpoints.baseUrl}$endpoint");
      }

      final request = http.Request('PUT', uri);
      request.bodyBytes = await file.readAsBytes();
      // Only set content-type if you know it was signed
      // request.headers['Content-Type'] = 'image/jpeg';
      final response = await request.send();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success();
      } else {
        return ApiResponse.failure('Something went wrong');
      }
    } catch (e) {
      return ApiResponse.failure(e.toString());
    }
  }
}

class Endpoints {
  static const String baseUrl = "https://vivekanandschool.in/SESMobileApp/";

  static const String login = "initiatelogin";
  static const String otpLogin = "otplogin";
  static const String getUserDetails = "getuserdetails";

  static String getClassEndpoint(String teacherId) =>
      "gStudentDtls/classJson/$teacherId";

  static String getSectionEndpoint(String teacherId, String classId) =>
      "gStudentDtls/sectionJson/$classId/$teacherId";

  static String get getSessionEndpoint => "gStudentDtls/getsessioncombo";

  static String getAttendanceList(
          String classId, String sectionId, String date) =>
      "gTeacherDtls/getStudentAttendance/$sectionId/$date";

  static String getAttendanceStatusList =
      "gTeacherDtls/getAttendanceParamByType/ATTENDANCE";

  static String getStudentSearchListUsingClassAndSection(
          String classId, String sectionId) =>
      "gStudentDtls/teacherAttendanceSelect/$classId/$sectionId";

  static String getStudentSearchListUsingName(String name) =>
      "gStudentDtls/getSearchListStudent/$name";

  static String getAllTeacherTimeTable = "gStudentDtls/getAllTeacherTimetable";

  static String getTeacherTimetableDetails(String teacherId) =>
      "gStudentDtls/getAdminTimetableDetails/$teacherId";

  static String forgotPasswordViaEmail(String schoolCode, String userId) =>
      "gStudentDtls/forgetUserPasswordByEmail/email/$schoolCode@$userId";

  static String forgotPasswordViaSms(String schoolCode, String userId) =>
      "gStudentDtls/forgetUserPasswordByEmail/sms/$schoolCode@$userId";

  static String getTransportTrackerEndpoint(String studentId) =>
      "gStudentDtls/getGPSPoint/$studentId";

  static String getNewsAndEventsEndpoint(String date, String studentId) =>
      "gTeacherDtls/getSchoolNews/$date/$studentId";

  static String getWordOfTheDayEndpoint(String studentId) =>
      "gStudentDtls/getWordOfTheDay/$studentId";

  static String getStudentRuleViolationDetails(String studentId) =>
      "gTeacherDtls/getDisciplineCardByStudentId/$studentId}";

  static String getStudentDisciplineDetails(
          String sessionCode, String studentId) =>
      "gTeacherDtls/getStudentPassbookDetails/$sessionCode/$studentId";

  static String getStudentDisciplineCount(
      String sessionCode, String sectionCode, String studentName) {
    if (studentName.isEmpty || studentName == '-') {
      return "gTeacherDtls/getStudentPassbookCount/$sessionCode/$sectionCode/-";
    } else {
      return "gTeacherDtls/getStudentPassbookCount/-/-/$studentName";
    }
  }

  static String getStudentListForDisciplinePassbook(
      String sessionCode, String sectionCode, String studentName) {
    if (studentName.isEmpty) {
      return "gTeacherDtls/getStudentPassbookList/$sessionCode/$sectionCode/-";
    } else {
      return "gTeacherDtls/getStudentPassbookList/$sessionCode/-/$studentName";
    }
  }

  static String getStudentDetailForDossier(String classCode, String sectionCode,
          String admissionNo, String studentName) =>
      "gTeacherDtls/getStudentDossierSearch/$classCode/$sectionCode/$admissionNo/$studentName";

  static String getStudentHomeWorkForMonth(
          String studentId, String monthYear) =>
      "gTeacherDtls/getHomeworkStudentMonthwise/$studentId/$monthYear";

  static String getCircularListForStudent(int page, String query) {
    String baseURL =
        "gTeacherDtls/getPaginatedStudentCircularData?page=$page&size=20";
    if (query.isEmpty) {
      return baseURL;
    }
    return "$baseURL&query=$query";
  }

  static String getStudentReportCardList(String studentId) =>
      "gTeacherDtls/getStudentReportCard/$studentId";

  static String getSubjectAsPerStatus(String teacherId, String status) =>
      "gTeacherDtls/getTeacherMarksPlanner/$status/$teacherId";

  static String getStudentListForSubject(UploadSubjectMarks subject) =>
      "gTeacherDtls/getExamDataDetails/${subject.sessionCode}/${subject.sectionCode}/${subject.examCode}/${subject.subjectCode}/${(subject.activityCode == null || subject.activityCode!.isEmpty || subject.activityCode == '-') ? "NA" : subject.activityCode}/${subject.subActivityCode}";

  static String getAttendanceTypeForMarks() =>
      "gTeacherDtls/getAttendanceParamByType/EXAM";

  static String getAttendanceReconList(String sessionCode, String classCode,
          String sectionCode, String monthCode) =>
      "gTeacherDtls/getMonthlyAttendanceClasswise/$sessionCode/$classCode/$sectionCode/$monthCode";

  static String getAttendanceReconData(
          String sessionCode, String studentId, String monthCode) =>
      "gTeacherDtls/getMonthlyDayAttendanceByStudentId/$sessionCode/$studentId/$monthCode";

  static String saveDeviceIdOnServer(String userId, String deviceId) =>
      "gStudentDtls/saveDeviceIdNotifications/$userId/$deviceId";

  static String get saveStudentExamMarks => "gTeacherDtls/saveStudentExamMarks";

  static String getStudentSearchList(
      String classCode, String sectionCode, String studentName) {
    if (studentName == '-') {
      return "gTeacherDtls/getStudentProfileSearch/$classCode/$sectionCode/-";
    } else {
      return "gTeacherDtls/getStudentProfileSearch/-/-/$studentName";
    }
  }

  static String getStudentProfileInfo(String studentId) =>
      "gStudentDtls/getStudentProfileInfo/$studentId";

  static String getResultAnalysisTemplateList() =>
      "gTeacherDtls/getResultAnalysisTemplates";

  static String getResultAnalysisFieldModel(String jasperName) =>
      "gTeacherDtls/getReportWiseConfigParametersList?jasperName=$jasperName";

  static String get getVQuickDataEndpoint => "gTeacherDtls/getQrcodeData";

  static String getStudentTimeTable(String studentId, String day) =>
      "gTeacherDtls/getTimetable/$studentId/$day";

  static String get getStudentViewDocumentEndpoint =>
      "gTeacherDtls/getDocListByStudentClassSection";

  static String getTeacherViewDocummentEndpoint(
          String classCode, String sectionCode) =>
      "gTeacherDtls/getDocListByTeacherClassSection/$classCode/$sectionCode";

  static String getViewAttendanceEndpoint(
          String classCode, String sectionCode, String monthCode) =>
      "gTeacherDtls/getSectionAttendancePercentData/$classCode/$sectionCode/$monthCode";

  static String getStudentNotificationList(String id, String pageNo) =>
      "gTeacherDtls/getInboxDtls/$id/$pageNo";

  static String get saveAttendanceEndpoint =>
      "gTeacherDtls/saveStudentAttendance";

  static String getDossierDashboardEndpoint(String studentId) =>
      "gTeacherDtls/getStudentDossierInfo/$studentId";

  static String getStudentDossierExamMarks(
          String studentId, String sessionId) =>
      "gTeacherDtls/getStudentExamMarks/$studentId/$sessionId";

  static String getStudentDossierReportCard(String studentId) =>
      "gTeacherDtls/getStudentDossierReportCard/$studentId";

  static String getStudentDossierAwardsArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentAwardsArray/$studentId/$sessionCode";

  static String getStudentDossierAttendanceDetail(String studentId) =>
      "gTeacherDtls/getStudentAttendanceDetail/$studentId";

  static String getStudentDossierHealthArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentHealthArray/$studentId/$sessionCode";

  static String getStudentDossierDisciplineAcademicArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentDisciplineAcademicArray/$studentId/$sessionCode";

  static String getStudentDossierLibraryArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentLibraryArray/$studentId/$sessionCode";

  static String getStudentDossierDisciplineArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentDisciplineArray/$studentId/$sessionCode";

  static String getResultAnalysisReport({
    required jasperUrl,
    required String sessionCode,
    required String sectionCode,
    required String classCode,
    required String activityCode,
    required String teacherCode,
    required String subjectCode,
    String fromDate = '',
    String toDate = '',
    int reportOpenMode = 1,
  }) =>
      "https://vivekanandschool.in/vksav/sesReports/callReportServletNew.do?jrxmlPath=$jasperUrl&sessionCode=$sessionCode&sectionCode=$sectionCode&classCode=$classCode&activityCode=$activityCode&fromDate=$fromDate&toDate=$toDate&teacherCode=$teacherCode&reportOpenMode=$reportOpenMode&subjectCode=$subjectCode";

  static String get getDynamicTriggeredDropdown =>
      "gTeacherDtls/getDynamicTriggeredDropdown";

  static String registerDeviceForNotification(String uuid, String deviceId) =>
      "gStudentDtls/saveDeviceIdNotifications/$uuid/$deviceId";

  static String get subscribeTokenForNotification =>
      "gStudentDtls/notification/update/user";

  static String logoutEndpoint(String uuid, String deviceId) =>
      "gStudentDtls/unregisterUser/$uuid/$deviceId";

  static String searchDiscipline(String sectionCode, DateTime disciplineDate) {
    final formattedDate =
        "${disciplineDate.day.toString().padLeft(2, '0')}-${disciplineDate.month.toString().padLeft(2, '0')}-${disciplineDate.year}";
    return "gTeacherDtls/getStudentDisciplineList/$sectionCode/$formattedDate";
  }

  static String markNoDefaulter(String sectionCode, DateTime disciplineDate) {
    final formattedDate =
        "${disciplineDate.year}-${disciplineDate.month.toString().padLeft(2, '0')}-${disciplineDate.day.toString().padLeft(2, '0')}";
    return "gTeacherDtls/markNoDefaulter/$sectionCode/$formattedDate";
  }

  static String getDisciplineEntryForStudentForView(
      String studentId, DateTime disciplineDate) {
    final formattedDate =
        "${disciplineDate.day.toString().padLeft(2, '0')}-${disciplineDate.month.toString().padLeft(2, '0')}-${disciplineDate.year}";
    return "gTeacherDtls/getDisciplineDtlsForEntry/$studentId/$formattedDate";
  }

  // static String getDisciplineEntryForStudentForEntry(String studentId) =>
  //     "gStudentDtls/getDisciplineDtlsForEntry/$studentId";

  static String get saveDisciplineData => "gTeacherDtls/saveDisciplineData";

  static String get getChangePasswordEndpoint =>
      "gStudentDtls/requestforchangepassword";

  static String uploadDocumentPresignUrl(String fileName) =>
      'gTeacherDtls/getPresignUrlForUploadDocument?fileName=$fileName';

  static String get getDocumentTypeCombo => "gStudentDtls/getDocumentTypeCombo";

  static String get getNoticesEndpoint => "gTeacherDtls/getStudentNoticeBoard";

  static String getStudentObservationArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentObservationArray/$studentId/$sessionCode";

  static String getStudentFeeHistory(String studentId) =>
      'gTeacherDtls/getStudentFeeHistory/$studentId';

  static String getSubjectComboByTeacherId(
          String classCode, String sectionCode, String teacherId) =>
      "gStudentDtls/getSubjectComboByTeacherId/$classCode/$sectionCode/$teacherId";

  static String getUserProfileImage(String userId, String affiliationCode) =>
      "gTeacherDtls/getUserProfileImage/$userId/$affiliationCode";

  static String getSubjectComboByStudentIdTeacherId(
      String sectionCode, String teacherId) {
    return "gTeacherDtls/getuserSubjectDropDown/$sectionCode/$teacherId";
  }

  static String getTeacherHomeworkData(String teacherCode, String classCode,
          String sectionCodes, String monthYear) =>
      "gTeacherDtls/getTeacherHomeworkdata/$teacherCode/$classCode/$sectionCodes/$monthYear";

  static String getDisciplineDtlsForEntryNew(String studentId) =>
      "gStudentDtls/getDisciplineDtlsForEntryNew/$studentId";

  static String getStudentCurriculam(String studentId) =>
      "gTeacherDtls/getStudentCurriculam/$studentId";

  static String getExaminationSchedule(String studentId) =>
      "gTeacherDtls/getExaminationSchedule/$studentId";

  static String get saveAcademicData => "gStudentDtls/saveAcademic";

  static String get saveHomeWork => "gTeacherDtls/saveHomework";

  static String getPresignUrlForHomeworkDocument(
          String subjectName, String fileName) =>
      "gTeacherDtls/getPresignUrlForHomeworkDocument?subjectName=${Uri.encodeComponent(subjectName)}&fileName=${Uri.encodeComponent(fileName)}";

  static String getAcademicData(String studentId) =>
      "gStudentDtls/getDisciplineDtls_TeacherView/$studentId";

  static String getDisciplineCategoryList(String affiliationCode) =>
      "gTeacherDtls/getDisciplineCategoryList/$affiliationCode";

  static String getCardNoArray(String affiliationCode) =>
      "gTeacherDtls/getCardNoArrayAndNormArrayAndNextCardNo/$affiliationCode";

  static String getSuspensionDataList(
    String affiliationCode, {
    String? sessionCode,
    String? classCode,
    String? sectionCode,
  }) {
    final queryParams = <String, String>{};
    if (sessionCode != null) queryParams['sessionCode'] = sessionCode;
    if (classCode != null) queryParams['classCode'] = classCode;
    if (sectionCode != null) queryParams['sectionCode'] = sectionCode;

    final queryString = queryParams.isEmpty
        ? ''
        : '?${Uri(queryParameters: queryParams).query}';

    return "gTeacherDtls/getSuspensionDataList/$affiliationCode$queryString";
  }

  static String saveUpdateStudentDisciplineData(String affiliationCode) =>
      "gTeacherDtls/saveUpdateStudentDisciplineData/$affiliationCode";

  static String saveStudentAcademicDisciplineData =
      "gTeacherDtls/saveStudentAcademicDisciplineData";

  static String getStudentDisciplineCardData(
    String affiliationCode, {
    String? sessionCode,
    String? classCode,
    String? sectionCode,
    String? disciplineDate,
  }) {
    final queryParams = <String, String>{};
    if (sessionCode != null) queryParams['sessionCode'] = sessionCode;
    if (classCode != null) queryParams['classCode'] = classCode;
    if (sectionCode != null) queryParams['sectionCode'] = sectionCode;
    if (disciplineDate != null) queryParams['disciplinedate'] = disciplineDate;

    final queryString = queryParams.isEmpty
        ? ''
        : '?${Uri(queryParameters: queryParams).query}';

    return "gTeacherDtls/getStudentDisciplineCardData/$affiliationCode$queryString";
  }

  static String updateCircularReadStatus(String noticeId) =>
      "gTeacherDtls/updateCircularReadStatus/$noticeId";

  static String updateCircularPinnedStatus(
          List<String> noticeIds, String status) =>
      "gTeacherDtls/updateCircularPinnedStatus/${"${noticeIds.first}~$status"}";

  // Discipline related endpoints
  static String getStudentAcademicDisciplineSearchedList(
          String sectionCode, String studentName) =>
      "gTeacherDtls/getStudentAcademicDisciplineSearchedList/${sectionCode.isEmpty ? '-' : sectionCode}/${studentName.isEmpty ? '-' : studentName}";

  static String getStudentDisciplineSearchedList(
          String sectionCode, String studentName) =>
      "gTeacherDtls/getStudentDisciplineSearchedList/${sectionCode.isEmpty ? '-' : sectionCode}/${studentName.isEmpty ? '-' : studentName}";

  static String getStudentDisciplineCardSearchedList(
          String sectionCode, String studentName) =>
      "gTeacherDtls/getStudentDisciplineCardSearchedList/${sectionCode.isEmpty ? '-' : sectionCode}/${studentName.isEmpty ? '-' : studentName}";

  static String getStudentDisciplineAcademicArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentDisciplineAcademicArray/$studentId/$sessionCode";

  static String getStudentDisciplineDefaulterData(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentDisciplineDefaulterData/$studentId/$sessionCode";

  static String getStudentDisciplineCardArray(
          String studentId, String sessionCode) =>
      "gTeacherDtls/getStudentDisciplineCardArray/$studentId/$sessionCode";

  static String getTeacherAttendanceStatusEndpoint(
          String sessionCode, String teacherCode) =>
      "gTeacherDtls/getTodayAttendanceTeacherwiseStatus/$sessionCode/$teacherCode";

  static String getSectionWiseAttendanceEndpoint(
          String sessionCode, String sectionCode, String teacherCode) =>
      "gTeacherDtls/getTodayAttendanceTeacherSectionwise/$sessionCode/$sectionCode/$teacherCode";

  static String getDailyMessage(String studentId) =>
      "gTeacherDtls/getDailyMessageByStudentId/$studentId/THOUGHTOFTHEDAY";

  static String updateNotificationReadStatus(
          String userId, String messageId, String sendDate) =>
      "gTeacherDtls/updateNotificationReadStatus/$userId/$messageId/$sendDate";

  static String getTeacherSubjectAndBooks(
          String classCode, String sectionCode, String teacherCode) =>
      "gTeacherDtls/getuserHomeworkSubjectDropDown/$classCode/$sectionCode/$teacherCode";

  static String getExamSchedule(String sectionCode) =>
      "gTeacherDtls/getExamPlanerData/$sectionCode";

  static String getBannerForHome = "gTeacherDtls/getUserBannerData";

  static String get getTestListForSection =>
      "gTeacherDtls/getHomeworkRevisionData";

  static String updateRevisionTestStatus(String sessionCode, String sectionCode,
          String subjectCode, String homeworkDate) =>
      "gTeacherDtls/updateHomeworkRevisionTestCheckStatus/$sessionCode/$sectionCode/$subjectCode/$homeworkDate";

  static String get uploadDocument => "gTeacherDtls/uploadDocument";

  static String deleteHomeworkDocument(String fileName) =>
      "gTeacherDtls/homeworkDocumentdelete?fileName=${Uri.encodeComponent(fileName)}";

  static String getPresignUrlForViewHomeworkDocument(
          String bucketName, String fileName) =>
      "gTeacherDtls/getPresignUrlForViewHomeworkDocument?bucketName=${Uri.encodeComponent(bucketName)}&fileName=${Uri.encodeComponent(fileName)}";

  static const String saveUploadedDocumentData =
      'gTeacherDtls/saveUploadedDocumentData';

  static const String saveMonthlyAttendanceRecord =
      'gTeacherDtls/saveMonthAttendanceRecord';

  static String refreshToken(String userId, String affiliationcode) {
    return "getNewToken/$userId/$affiliationcode";
  }
}
