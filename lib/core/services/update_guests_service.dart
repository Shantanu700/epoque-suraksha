import 'package:epoque_suraksha/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

class UpdateGuestsService {
  final ApiClient api;

  UpdateGuestsService(this.api);

  Future<Map<String, dynamic>> updateGuests({
    required String qrId,
    required int count,
  }) async {
    final res = await api.put(
      "/v1/master/alumni_data/",
      data: {"qr_id": qrId, "count": count},
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return res.data;
    }

    throw res.data["msg"] ?? "Failed to update guests";
  }
}

final updateGuestsServiceProvider = Provider<UpdateGuestsService>((ref) {
  final api = ref.watch(apiClientProvider).value!;
  return UpdateGuestsService(api);
});
