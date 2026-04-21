import 'package:school_app/auth/view_model/auth.dart';
import 'package:school_app/network_manager/network_manager.dart';
import '../model/notice_board_model.dart';

class NoticeBoardViewModel {
  static final NoticeBoardViewModel instance = NoticeBoardViewModel._internal();

  NoticeBoardViewModel._internal();

  // Flag to toggle between dummy data and real API
  static const bool useDummyData = true;

  Future<List<NoticeBoardModel>> getNotices() async {
    try {
      final response = await NetworkManager.instance
          .makeRequest<List<NoticeBoardModel>>(Endpoints.getNoticesEndpoint,
              (json) async {
        List<NoticeBoardModel> noticeBoardItems = json
            .map<NoticeBoardModel>((item) => NoticeBoardModel.fromJson(item))
            .toList();
        return noticeBoardItems;
      }, method: HttpMethod.get);

      if (response.success) {
        return response.data ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
