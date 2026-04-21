import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/model/daily_message.dart';
import 'package:school_app/homework_screen/model/homeBanner_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class HomeViewmodel {
  HomeViewmodel._();

  static HomeViewmodel? _instance;

  static HomeViewmodel get instance => _instance ??= HomeViewmodel._();

  Future<ApiResponse<HomeModel>> fetchHomeDetail() async {
    // Call the API to fetch the home details
    // If the API call is successful, return the home details
    // If the API call is not successful, return an error message

    return NetworkManager.instance.makeRequest(Endpoints.getUserDetails,
        (json) async {
      return HomeModel.fromJson(json);
    }, body: {}, method: HttpMethod.get);
  }

  Future<ApiResponse<List<DailyMessage>>> getDailyMessage() async {
    User? user = AuthViewModel.instance.getLoggedInUser();

    return NetworkManager.instance.makeRequest(
      Endpoints.getDailyMessage(user?.username ?? ""),
      (json) async {
        if (json is List) {
          return json.map((item) => DailyMessage.fromJson(item)).toList();
        }
        return [];
      },
      method: HttpMethod.get,
    );
  }

  Future<ApiResponse<List<HomebannerModel>>> getHomeBanner() async {
    return NetworkManager.instance.makeRequest(
      Endpoints.getBannerForHome,
      (json) async {
        if (json is List) {
          return json.map((item) => HomebannerModel.fromJson(item)).toList();
        }
        return [];
      },
      method: HttpMethod.get,
    );
  }
}
