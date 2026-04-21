import 'package:school_app/network_manager/network_manager.dart';
import 'package:school_app/vquick/model/document_link.dart';

class VQuickViewModel {
  static final VQuickViewModel instance = VQuickViewModel._internal();

  VQuickViewModel._internal();

  Future<List<VQuickModel>> getVQuickData() async {
    try {
      final response =
          await NetworkManager.instance.makeRequest<List<VQuickModel>>(
        Endpoints.getVQuickDataEndpoint,
        (json) async {
          if (json is List) {
            return json.map((item) => VQuickModel.fromJson(item)).toList()
              ..sort((a, b) =>
                  (a.displayOrder ?? 0).compareTo(b.displayOrder ?? 0));
          }
          return [];
        },
      );

      if (response.success) {
        return response.data ?? [];
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
