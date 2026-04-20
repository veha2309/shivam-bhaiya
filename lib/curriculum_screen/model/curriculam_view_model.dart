import 'package:flutter/material.dart';
import 'package:school_app/curriculum_screen/model/curriculam.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/auth/view_model/auth.dart';

final class CurriculamViewModel extends ChangeNotifier {
  final List<Curriculam> _curriculamList = [];

  List<Curriculam> get curriculamList => _curriculamList;

  Future<ApiResponse<List<Curriculam>>> getStudentCurriculam() {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getStudentCurriculam(studentId),
      fullEndpoint: "https://mocki.io/v1/c57bcdd2-89cc-4b8d-97cc-5cca386020a3",
      (json) async {
        List<Curriculam> response =
            json.map<Curriculam>((json) => Curriculam.fromJson(json)).toList();
        return response;
      },
      method: HttpMethod.get,
    );
  }

  CurriculamViewModel._();

  static CurriculamViewModel? _instance;

  static CurriculamViewModel get instance =>
      _instance ??= CurriculamViewModel._();
}
