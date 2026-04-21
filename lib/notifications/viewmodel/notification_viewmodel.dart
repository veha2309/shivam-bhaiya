import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/api_response.dart';
import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/notifications/model/school_message.dart';
import 'package:school_app/utils/local_storage/local_storage.dart';

class NotificationViewModel {
  NotificationViewModel._();

  static final NotificationViewModel _instance = NotificationViewModel._();

  static NotificationViewModel get instance => _instance;

  Future<ApiResponse<List<NotificationModel>>> getNotifications(int pageNo) {
    String id = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
        Endpoints.getStudentNotificationList(id, "$pageNo"), (json) async {
      return (json as List<dynamic>)
          .map((e) => NotificationModel.fromJson(e))
          .toList();
    }, method: HttpMethod.get);
  }

  bool shouldShowNotifications() {
    return !LocalStorage.wasNotificationShownToday();
  }

  Future<void> markNotificationsAsShownForToday() async {
    await LocalStorage.setNotificationShownForToday();
  }

  Future<ApiResponse<NotificationModel>> updateReadNotificationStatus({
    required String messageId,
    required String sendDate,
  }) {
    String userId = AuthViewModel.instance.getLoggedInUser()?.username ?? "";

    return NetworkManager.instance.makeRequest(
      Endpoints.updateNotificationReadStatus(userId, messageId, sendDate),
      (json) async => NotificationModel.fromJson(json),
      method: HttpMethod.get,
    );
  }
}
