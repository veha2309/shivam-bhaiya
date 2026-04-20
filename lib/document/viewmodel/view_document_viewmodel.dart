import 'package:school_app/document/model/view_document.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class ViewDocumentViewModel {
  ViewDocumentViewModel._();

  static ViewDocumentViewModel? _instance;

  static ViewDocumentViewModel get instance =>
      _instance ??= ViewDocumentViewModel._();

  Future<ApiResponse<Map<String, List<Document>>>>
      getStudentViewDocumentData() async {
    return NetworkManager.instance
        .makeRequest(Endpoints.getStudentViewDocumentEndpoint, (json) async {
      Map<String, List<Document>> documents =
          (json as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(
                  key,
                  (value as List<dynamic>)
                      .map((item) => Document.fromJson(item))
                      .toList(),
                ),
              ) ??
              {};
      return documents;
    }, body: {}, method: HttpMethod.get);
  }

  Future<ApiResponse<Map<String, List<Document>>>> getTeacherViewDocumentList(
      String classCode, String sectionCode) async {
    return NetworkManager.instance.makeRequest(
        Endpoints.getTeacherViewDocummentEndpoint(classCode, sectionCode),
        (json) async {
      Map<String, List<Document>> documents =
          (json as Map<String, dynamic>?)?.map(
                (key, value) => MapEntry(
                  key,
                  (value as List<dynamic>)
                      .map((item) => Document.fromJson(item))
                      .toList(),
                ),
              ) ??
              {};
      return documents;
    }, body: {}, method: HttpMethod.get);
  }
}
