import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const String _tokenKey = 'taskflow_auth_token';
  static const String _userKey = 'taskflow_cached_user';
  static const String _onboardingKey = 'taskflow_onboarding_completed';

  // Token operations
  static Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
    } catch (_) {}
  }

  static Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
    } catch (_) {}
  }

  // User cache operations
  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    try {
      await _storage.write(key: _userKey, value: userJson);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, userJson);
    } catch (_) {}
  }

  static Future<UserModel?> getUser() async {
    String? userJson;
    try {
      userJson = await _storage.read(key: _userKey);
    } catch (_) {}
    if (userJson == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        userJson = prefs.getString(_userKey);
      } catch (_) {}
    }
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {}
    }
    return null;
  }

  static Future<void> clearUser() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
    } catch (_) {}
  }

  // Clear all auth data
  static Future<void> clearAuth() async {
    await clearToken();
    await clearUser();
  }

  // Onboarding operations
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> setOnboardingCompleted(bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, completed);
    } catch (_) {}
  }
}
