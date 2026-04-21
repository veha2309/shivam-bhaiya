import 'package:flutter/material.dart';
import 'package:school_app/examination_schedule/model/examination_schedule.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/auth/view_model/auth.dart';

class ExaminationScheduleViewModel extends ChangeNotifier {
  ExaminationScheduleViewModel._();

  static ExaminationScheduleViewModel? _instance;

  static ExaminationScheduleViewModel get instance =>
      _instance ??= ExaminationScheduleViewModel._();

  Future<ApiResponse<List<ExaminationSchedule>>> getExaminationSchedule() {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.getExaminationSchedule(studentId),
      (json) async {
        List<ExaminationSchedule> response =
            ExaminationSchedule.fromJsonList(json);
        return response;
      },
      method: HttpMethod.get,
    );
  }
}
