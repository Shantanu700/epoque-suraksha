import 'package:epoque_suraksha/core/network/dio_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/api_client.dart';

class InductionReportService {
  final ApiClient api;

  InductionReportService(this.api);

  Future<List<Map<String, dynamic>>> getInductionReport() async {
    final res = await api.get("/v1/master/induction-report/");

    if (res.statusCode == 200) {
      final list = res.data as List<dynamic>;
      return list.cast<Map<String, dynamic>>();
    }

    throw (res.data is Map ? res.data["msg"] : null) ??
        "Failed to load induction report";
  }
}

final inductionReportServiceProvider = Provider<InductionReportService>((ref) {
  final api = ref.watch(apiClientProvider).value!;
  return InductionReportService(api);
});
