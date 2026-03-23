import 'package:epoque_suraksha/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

class QrService {
  final ApiClient api;

  QrService(this.api);

  Future<Map<String, dynamic>> verifyQr(String data) async {
    final res = await api.post(
      "/v1/master/generate-qr/",
      data: {"qr_code": data},
    );

    if (res.statusCode == 201) {
      return res.data;
    }

    throw res.data["msg"] ?? "Failed to verify QR code";
  }
}

final qrServiceProvider = Provider<QrService>((ref) {
  final api = ref.watch(apiClientProvider).value!;
  return QrService(api);
});
