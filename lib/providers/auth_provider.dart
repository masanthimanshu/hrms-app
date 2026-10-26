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
    required this.isAuthenticated,
    this.isLoading = false,
    this.authToken,
    this.refreshToken,
    this.currentUser,
    this.errorMessage,
  });

  factory AuthState.initial() =>
      const AuthState(isAuthenticated: false, isLoading: false);

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
    Future.microtask(() => checkInitialSession());
    return AuthState.initial();
  }

  AuthService get _authService => ref.read(authServiceProvider);

  Future<void> checkInitialSession() async {
    state = state.copyWith(isLoading: true);
    if (!_authService.hasSavedToken) {
      state = state.copyWith(isAuthenticated: false, isLoading: false);
      return;
    }

    final isValid =
        await _authService.verifyToken() ||
        (await _authService.refreshToken()).isSuccess;

    if (isValid) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        authToken: _authService.currentAuthToken,
        refreshToken: _authService.currentRefreshToken,
        currentUser: _authService.getCurrentUser(),
      );
    } else {
      await _authService.logout();
      state = state.copyWith(isAuthenticated: false, isLoading: false);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final res = await _authService.login(email: email, password: password);
    if (res.isSuccess) {
      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
        authToken: _authService.currentAuthToken,
        refreshToken: _authService.currentRefreshToken,
        currentUser: _authService.getCurrentUser(),
      );
      return true;
    }

    state = state.copyWith(
      isAuthenticated: false,
      isLoading: false,
      errorMessage: res.message ?? "Authentication failed",
    );
    return false;
  }

  Future<bool> verifySession() => _authService.verifyToken();

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
