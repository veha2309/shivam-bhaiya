import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/fee_history/Model/fee_history_model.dart';

class FeeHistoryViewModel {
  FeeHistoryViewModel._();

  static final FeeHistoryViewModel instance = FeeHistoryViewModel._();

  Future<ApiResponse<List<FeeHistoryModel>>> getFeeHistory() {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentFeeHistory(studentId),
      (json) async {
        List<dynamic> data = json as List<dynamic>;
        return FeeHistoryModel.fromJsonList(data);
      },
      method: HttpMethod.get,
    );
  }
}
