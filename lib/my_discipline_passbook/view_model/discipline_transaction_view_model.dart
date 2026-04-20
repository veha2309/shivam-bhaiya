import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/my_discipline_passbook/model/discipline_transaction_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class DisciplineTransactionViewModel {
  DisciplineTransactionViewModel._();

  static final DisciplineTransactionViewModel instance =
      DisciplineTransactionViewModel._();

  Future<ApiResponse<List<DisciplineTransactionModel>>>
      getDisciplineTransactionDetail(String studentId) {
    HomeModel? homeModel = AuthViewModel.instance.homeModel;
    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentDisciplineDetails(
          homeModel?.sessionCode ?? "", studentId),
      (json) async {
        List<DisciplineTransactionModel> response = json
            .map<DisciplineTransactionModel>(
                (json) => DisciplineTransactionModel.fromJson(json))
            .toList();
        return response;
      },
      body: null,
      method: HttpMethod.get,
    );
  }
}
