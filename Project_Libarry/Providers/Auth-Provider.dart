import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../core/network/api_exceptions.dart';

class AuthState {
  final UserModel? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(AuthState());

  Future<void> initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final token = await StorageService.getToken();
      if (token != null && token.isNotEmpty) {
        // Try getting cached user first for instant UI loading
        final cachedUser = await StorageService.getUser();
        if (cachedUser != null) {
          state = state.copyWith(user: cachedUser, isInitialized: true, isLoading: false);
        }

        // Verify with server with a strict 2.5s timeout
        try {
          final liveUser = await _authService.getMe().timeout(const Duration(milliseconds: 2500));
          state = state.copyWith(user: liveUser, isInitialized: true, isLoading: false);
        } catch (_) {
          // If network failed but user was cached, keep cached session; otherwise clear
          if (cachedUser == null) {
            await StorageService.clearAuth();
            state = state.copyWith(isInitialized: true, isLoading: false, clearUser: true);
          }
        }
      } else {
        state = state.copyWith(isInitialized: true, isLoading: false, clearUser: true);
      }
    } catch (e) {
      // If token expired or network failed, clear cached auth
      await StorageService.clearAuth();
      state = state.copyWith(isInitialized: true, isLoading: false, clearUser: true);
    } finally {
      // Guaranteed to never leave isLoading stuck in true
      state = state.copyWith(isLoading: false, isInitialized: true);
    }
  }

  void resetLoading() {
    state = state.copyWith(isLoading: false);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.login(email, password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Login failed: $e';
      state = state.copyWith(isLoading: false, error: message);
      return false;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _authService.register(name, email, password);
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      final message = e is ApiException ? e.message : 'Registration failed: $e';
      state = state.copyWith(isLoading: false, error: message);
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await _authService.logout();
    state = AuthState(isInitialized: true);
  }

  /// Called when the backend rejects a token (expired/invalid). Clears the
  /// stored session silently; navigation back to login is handled by the caller.
  Future<void> sessionExpired() async {
    await StorageService.clearAuth();
    state = AuthState(isInitialized: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
