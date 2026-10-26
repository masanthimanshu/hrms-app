import "package:flutter_riverpod/flutter_riverpod.dart";

import "/models/user_model.dart";
import "/services/auth_service.dart";

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? authToken;
  final String? refreshToken;
  final UserModel? currentUser;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.authToken,
    this.refreshToken,
    this.currentUser,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? authToken,
    String? refreshToken,
    UserModel? currentUser,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      authToken: authToken ?? this.authToken,
      refreshToken: refreshToken ?? this.refreshToken,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(checkInitialSession);
    return const AuthState();
  }

  AuthService get _service => ref.read(authServiceProvider);

  Future<void> checkInitialSession() async {
    state = state.copyWith(isLoading: true);
    if (!_service.hasSavedToken) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
      return;
    }

    final isValid =
        await _service.verifyToken() ||
        (await _service.refreshToken()).isSuccess;

    if (isValid) {
      await _service.fetchUserProfile();
      state = AuthState(
        isAuthenticated: true,
        authToken: _service.currentAuthToken,
        refreshToken: _service.currentRefreshToken,
        currentUser: _service.getCurrentUser(),
      );
    } else {
      await _service.logout();
      state = const AuthState();
    }
  }

  Future<void> refreshProfile() async {
    final updated = await _service.fetchUserProfile();
    if (updated != null) {
      state = state.copyWith(currentUser: updated);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _service.login(email: email, password: password);
    if (res.isSuccess) {
      state = AuthState(
        isAuthenticated: true,
        authToken: _service.currentAuthToken,
        refreshToken: _service.currentRefreshToken,
        currentUser: _service.getCurrentUser(),
      );
      return true;
    }

    state = AuthState(errorMessage: res.message ?? "Authentication failed");
    return false;
  }

  Future<bool> verifySession() => _service.verifyToken();

  Future<void> logout() async {
    await _service.logout();
    state = const AuthState();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
