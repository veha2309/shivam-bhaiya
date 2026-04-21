import 'package:school_app/academic_card/model/academic_card.dart';
import 'package:school_app/academic_card/model/card_no_array_response.dart';
import 'package:school_app/academic_card/model/save_update_student_discipline_data.dart';
import 'package:school_app/academic_card/model/suspension_data.dart';
import 'package:school_app/academic_card/model/student_discipline_card.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class AcademicCardViewModel {
  AcademicCardViewModel._();
  static AcademicCardViewModel? _instance;
  static AcademicCardViewModel get instance =>
      _instance ??= AcademicCardViewModel._();

  Future<ApiResponse<List<AcademicCard>>> getDisciplineCategoryList(
      String affiliationCode) async {
    return await NetworkManager.instance.makeRequest<List<AcademicCard>>(
      Endpoints.getDisciplineCategoryList(affiliationCode),
      (json) async {
        if (json is List) {
          return json.map((item) => AcademicCard.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<CardNoArrayResponse>> getCardNoArray(
      String affiliationCode) async {
    return await NetworkManager.instance.makeRequest<CardNoArrayResponse>(
      Endpoints.getCardNoArray(affiliationCode),
      (json) async {
        return CardNoArrayResponse.fromJson(json);
      },
    );
  }

  Future<ApiResponse<List<SuspensionData>>> getSuspensionDataList(
    String affiliationCode, {
    String? sessionCode,
    String? classCode,
    String? sectionCode,
  }) async {
    return await NetworkManager.instance.makeRequest<List<SuspensionData>>(
      Endpoints.getSuspensionDataList(
        affiliationCode,
        sessionCode: sessionCode,
        classCode: classCode,
        sectionCode: sectionCode,
      ),
      (json) async {
        if (json is List) {
          return json.map((item) => SuspensionData.fromJson(item)).toList();
        }
        return [];
      },
    );
  }

  Future<ApiResponse<void>> saveUpdateStudentDisciplineData(
    String affiliationCode,
    List<SaveUpdateStudentDisciplineData> dataList,
  ) async {
    return await NetworkManager.instance.makeRequest<void>(
      Endpoints.saveUpdateStudentDisciplineData(affiliationCode),
      (json) async {
        // Since we don't need to parse any response data, we just return void
        return;
      },
      method: HttpMethod.post,
      body: SaveUpdateStudentDisciplineData.toJsonList(dataList),
    );
  }

  Future<ApiResponse<List<StudentDisciplineCard>>> getStudentDisciplineCardData(
    String affiliationCode, {
    String? sessionCode,
    String? classCode,
    String? sectionCode,
    String? disciplineDate,
  }) async {
    return await NetworkManager.instance
        .makeRequest<List<StudentDisciplineCard>>(
      Endpoints.getStudentDisciplineCardData(
        affiliationCode,
        sessionCode: sessionCode,
        classCode: classCode,
        sectionCode: sectionCode,
        disciplineDate: disciplineDate,
      ),
      (json) async {
        if (json is List) {
          return json
              .map((item) => StudentDisciplineCard.fromJson(item))
              .toList();
        }
        return [];
      },
    );
  }
}
