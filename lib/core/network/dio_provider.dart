import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'api_client.dart';

final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final client = await ApiClient.create();

  ref.onDispose(() {
    client.dio.close(force: true);
  });

  return client;
});

final dioProvider = Provider<Dio>((ref) {
  final asyncClient = ref.watch(apiClientProvider);

  return asyncClient.when(
    data: (client) => client.dio,
    loading: () => throw Exception("Dio not ready yet"),
    error: (e, _) => throw Exception("Failed to initialize Dio: $e"),
  );
});
