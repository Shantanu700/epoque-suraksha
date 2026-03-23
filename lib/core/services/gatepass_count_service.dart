import 'package:epoque_suraksha/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

class GatePasscountService {
  final ApiClient api;

  GatePasscountService(this.api);

  Future<Map<String, dynamic>> getGatePasscount(String data) async {
    final res = await api.get("/v1/master/gatepass-count/");

    if (res.statusCode == 200) {
      return res.data;
    }

    throw res.data["msg"] ?? "Failed to verify QR code";
  }
}

final gatePasscountServiceProvider = Provider<GatePasscountService>((ref) {
  final api = ref.watch(apiClientProvider).value!;
  return GatePasscountService(api);
});
