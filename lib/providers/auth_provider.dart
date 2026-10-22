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
  final String? successMessage;

  const AuthState({
    required this.isAuthenticated,
    this.isLoading = false,
    this.authToken,
    this.refreshToken,
    this.currentUser,
    this.errorMessage,
    this.successMessage,
  });

  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? authToken,
    String? refreshToken,
    UserModel? currentUser,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      authToken: authToken ?? this.authToken,
      refreshToken: refreshToken ?? this.refreshToken,
      currentUser: currentUser ?? this.currentUser,
      errorMessage: errorMessage,
      successMessage: successMessage,
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
    final hasToken = _authService.hasSavedToken;

    if (!hasToken) {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
      return;
    }

    final isValid = await _authService.verifyToken() ||
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
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
      );
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
        successMessage: "Welcome back!",
      );
      return true;
    } else {
      state = state.copyWith(
        isAuthenticated: false,
        isLoading: false,
        errorMessage: res.message ?? "Authentication failed",
      );
      return false;
    }
  }

  Future<bool> verifySession() async {
    final isValid = await _authService.verifyToken();
    if (!isValid) {
      state = state.copyWith(
        errorMessage: "Session token is invalid or expired",
      );
    } else {
      state = state.copyWith(
        successMessage: "Session signature verified with backend",
      );
    }
    return isValid;
  }

  Future<bool> manualRefreshToken() async {
    state = state.copyWith(isLoading: true);
    final res = await _authService.refreshToken();
    if (res.isSuccess) {
      state = state.copyWith(
        isLoading: false,
        authToken: _authService.currentAuthToken,
        refreshToken: _authService.currentRefreshToken,
        successMessage: "Tokens renewed via /jwt/refresh",
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: res.message ?? "Token refresh failed",
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = AuthState.initial();
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
