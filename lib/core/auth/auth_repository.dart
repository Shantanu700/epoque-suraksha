import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/dio_provider.dart';
import 'package:dio/dio.dart';

class AuthRepository {
  final ApiClient api;

  AuthRepository(this.api);

  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$username:$password'))}';

    final res = await api.post(
      "/v1/core/auth/",
      options: Options(headers: {"Authorization": basicAuth}),
    );

    if (res.statusCode != 201) {
      throw Exception("Invalid credentials");
    }

    return res.data;
  }

  Future<void> logout() async {
    await api.delete("/v1/core/auth/");
    await api.clearCookies();
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final res = await api.get("/v1/core/auth/");

    if (res.statusCode == 200) {
      return res.data;
    }

    throw Exception("Not authenticated");
  }

  Future<bool> isLoggedIn() async {
    try {
      await getCurrentUser();
      return true;
    } catch (_) {
      return false;
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(apiClientProvider).value;

  if (api == null) {
    throw Exception("ApiClient not ready");
  }

  return AuthRepository(api);
});
