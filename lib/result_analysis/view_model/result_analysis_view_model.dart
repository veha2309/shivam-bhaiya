import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/result_analysis/model/result_analysis_drop_down_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_field_model.dart';
import 'package:school_app/result_analysis/model/result_analysis_template_model.dart';
import 'package:school_app/utils/utils.dart';

class ResultAnalysisViewModel {
  ResultAnalysisViewModel._();

  static final ResultAnalysisViewModel _instance = ResultAnalysisViewModel._();

  static ResultAnalysisViewModel get instance => _instance;

  Future<ApiResponse<List<ResultAnalysisTemplateModel>>>
      getResultAnalysisTemplateList() {
    return NetworkManager.instance
        .makeRequest(Endpoints.getResultAnalysisTemplateList(), (json) async {
      return (json as List<dynamic>)
          .map((e) => ResultAnalysisTemplateModel.fromJson(e))
          .toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<ResultAnalysisFieldModel>>>
      getResultAnalysisFieldModel(String templateName) {
    return NetworkManager.instance.makeRequest(
        Endpoints.getResultAnalysisFieldModel(templateName), (json) async {
      return (json as List<dynamic>)
          .map((e) => ResultAnalysisFieldModel.fromJson(e))
          .toList();
    }, method: HttpMethod.get);
  }

  Future<ApiResponse<List<ResultAnalysisDropDownModel>>>
      getDynamicDropDownValue(Map<String, dynamic> parameters) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getDynamicTriggeredDropdown,
      (json) async {
        return (json as List<dynamic>)
            .map((e) => ResultAnalysisDropDownModel.fromJson(e))
            .toList();
      },
      method: HttpMethod.post,
      body: parameters,
    );
  }

  Future<void> searchResultAnalysisReport({
    required String jasperUrl,
    required String sessionCode,
    required String sectionCode,
    required String classCode,
    required String activityCode,
    required String teacherCode,
    required String subjectCode,
    String fromDate = '',
    String toDate = '',
    int reportOpenMode = 1,
  }) async {
    launchURLString(Endpoints.getResultAnalysisReport(
      jasperUrl: jasperUrl,
      sessionCode: sessionCode,
      sectionCode: sectionCode,
      classCode: classCode,
      activityCode: activityCode,
      teacherCode: teacherCode,
      subjectCode: subjectCode,
      fromDate: fromDate,
      toDate: toDate,
      reportOpenMode: reportOpenMode,
    ));
  }
}
