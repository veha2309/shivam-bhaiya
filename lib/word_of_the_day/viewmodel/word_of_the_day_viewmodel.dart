import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/word_of_the_day/model/word_of_the_day.dart';

class WordOfTheDayViewmodel {
  WordOfTheDayViewmodel._();

  static final WordOfTheDayViewmodel _instance = WordOfTheDayViewmodel._();

  static WordOfTheDayViewmodel get instance => _instance;

  Future<ApiResponse<List<WordOfTheDayModel>>> getWordOfTheDay() {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";
    return NetworkManager.instance.makeRequest(
      Endpoints.getWordOfTheDayEndpoint(studentId),
      (json) async {
        return WordOfTheDayModel.fromJsonList(json);
      },
      method: HttpMethod.get,
    );
  }
}
