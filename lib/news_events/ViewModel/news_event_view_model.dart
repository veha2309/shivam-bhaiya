import 'package:intl/intl.dart';
import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/news_events/Model/news_event.dart';

class NewsEventViewModel {
  NewsEventViewModel._();

  static final NewsEventViewModel _instance = NewsEventViewModel._();

  static NewsEventViewModel get instance => _instance;

  Future<ApiResponse<NewsData>> getNewsAndEvent(DateTime date) {
    String studentId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    String formattedDate =
        DateFormat('ddMMyyyy').format(date.copyWith(day: 01));

    return NetworkManager.instance.makeRequest(
      Endpoints.getNewsAndEventsEndpoint(formattedDate, studentId),
      (json) async {
        return NewsData.fromJson(json);
      },
      method: HttpMethod.get,
    );
  }
}
