import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/report_card/Model/report_card_model.dart';

class ReportCardViewModel {
  ReportCardViewModel._();

  static final ReportCardViewModel instance = ReportCardViewModel._();

  Future<ApiResponse<List<ReportCardModel>>> getReportCardForStudent() {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentReportCardList(studentId),
      (json) async {
        List<ReportCardModel> response = json
            .map<ReportCardModel>((json) => ReportCardModel.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
