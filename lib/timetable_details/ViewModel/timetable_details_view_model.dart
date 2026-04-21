import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/timetable_details/Model/timetable_details.dart';

class TimetableDetailsViewModel {
  TimetableDetailsViewModel._();

  static final TimetableDetailsViewModel instance =
      TimetableDetailsViewModel._();

  Future<ApiResponse<CompleteTeacherTimetable>> getAllTeacherTimeTable() {
    return NetworkManager.instance.makeRequest(
      Endpoints.getAllTeacherTimeTable,
      (json) async {
        return CompleteTeacherTimetable.fromJson(json.first);
      },
      method: HttpMethod.get,
    );
  }
}
