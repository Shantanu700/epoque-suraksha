import 'package:flutter_riverpod/legacy.dart';

import 'auth_state.dart';
import 'auth_repository.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository repo;

  AuthNotifier(this.repo) : super(AuthState.initial());

  Future<void> checkAuth() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await repo.getCurrentUser();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
      );
    }
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await repo.login(username: username, password: password);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        isAuthenticated: false,
      );
    }
  }

  Future<void> logout() async {
    await repo.logout();

    state = AuthState.initial();
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
