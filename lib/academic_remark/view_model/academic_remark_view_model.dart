import 'package:school_app/academic_remark/model/academic_remark_save_model.dart';
import 'package:school_app/homework_screen/model/subject_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/academic_concerns/model/academic_concern_category_model.dart';

class AcademicRemarkViewModel {
  AcademicRemarkViewModel._();

  static final AcademicRemarkViewModel _instance = AcademicRemarkViewModel._();

  static AcademicRemarkViewModel get instance => _instance;

  Future<ApiResponse<List<SubjectModel>>> getSubjectComboByStudentId(
      String sectionCode, String teacherId) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getSubjectComboByStudentIdTeacherId(sectionCode, teacherId),
      (json) async {
        return SubjectModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<AcademicConcernCategoryModel>>>
      getDisciplineDtlsForEntry(String studentId) {
    return NetworkManager.instance.makeRequest(
      Endpoints.getDisciplineDtlsForEntryNew(studentId),
      (json) async {
        if (json != null && json is List) {
          return json
              .map((item) => AcademicConcernCategoryModel.fromJson(item))
              .toList();
        }
        return [];
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<AcademicRemarkSaveModel>> saveAcademicRemark(
      List<AcademicRemarkSaveModel> concerns) async {
    return await NetworkManager.instance.makeRequest(
      Endpoints.saveStudentAcademicDisciplineData,
      (json) async => AcademicRemarkSaveModel.fromJson(json),
      method: HttpMethod.post,
      body: AcademicRemarkSaveModel.toJsonList(concerns),
    );
  }
}
