import 'package:flutter/material.dart';
import 'package:school_app/auth/model/user.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/home_screen/model/home.dart';
import 'package:school_app/home_screen/model/daily_message.dart';
import 'package:school_app/homework_screen/model/homeBanner_model.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';

class HomeViewmodel extends ChangeNotifier {
  HomeViewmodel._();
  static HomeViewmodel? _instance;
  static HomeViewmodel get instance => _instance ??= HomeViewmodel._();

  HomeModel? _homeModel;
  HomeModel? get homeModel => _homeModel;

  Map<String, List<MenuDetail>> _menuDetailMap = {};
  Map<String, List<MenuDetail>> get menuDetailMap => _menuDetailMap;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<ApiResponse<HomeModel>> fetchHomeDetail() async {
    _isLoading = true;
    notifyListeners();

    final response = await NetworkManager.instance.makeRequest(
      Endpoints.getUserDetails,
      (json) async => HomeModel.fromJson(json),
      body: {},
      method: HttpMethod.get,
    );

    if (response.success && response.data != null) {
      _homeModel = response.data;
      AuthViewModel.instance.setHomeModel(_homeModel!);
      
      _menuDetailMap = {};
      _homeModel?.menuDetails?.forEach((m) {
        final key = m.categoryId == '2' ? '2' : '1';
        _menuDetailMap[key] = [...(_menuDetailMap[key] ?? []), m];
      });
    }

    _isLoading = false;
    notifyListeners();
    return response;
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
