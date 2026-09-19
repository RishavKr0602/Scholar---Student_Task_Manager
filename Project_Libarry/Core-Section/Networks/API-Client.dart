import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../services/storage_service.dart';
import 'api_exceptions.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  /// Called once when the server rejects a request with 401 on a *protected*
  /// endpoint (i.e. an expired or invalid session), so the app can clear the
  /// stale token and route the user back to login. Set from [main].
  static void Function()? onSessionExpired;
  static bool _handlingExpiry = false;

  late Dio _dio;
  String _baseUrl = ApiConstants.getDefaultBaseUrl();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // Auto-handle expired/invalid sessions on protected endpoints.
          final path = e.requestOptions.path;
          final isAuthAttempt = path.contains(ApiConstants.loginEndpoint) ||
              path.contains(ApiConstants.registerEndpoint);
          if (e.response?.statusCode == 401 &&
              !isAuthAttempt &&
              !_handlingExpiry &&
              onSessionExpired != null) {
            _handlingExpiry = true;
            onSessionExpired!();
            // Reset the guard shortly after so a future session can be handled.
            Future.delayed(const Duration(seconds: 2), () => _handlingExpiry = false);
          }

          final apiException = _handleDioError(e);
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: apiException,
              type: e.type,
              response: e.response,
            ),
          );
        },
      ),
    );

    _loadCustomBaseUrl();
  }

  Dio get dio => _dio;
  String get baseUrl => _baseUrl;

  Future<void> _loadCustomBaseUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final customUrl = prefs.getString(ApiConstants.baseUrlStorageKey);
      if (customUrl != null && customUrl.isNotEmpty) {
        setBaseUrl(customUrl);
      }
    } catch (_) {}
  }

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
    _dio.options.baseUrl = _baseUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.baseUrlStorageKey, _baseUrl);
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return ApiException(
        message: 'Connection timed out. Please verify your server is running.',
        statusCode: 408,
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Cannot connect to backend server at $_baseUrl. Please check if the Node.js server is started.',
        statusCode: 503,
      );
    }

    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'] as String? ?? 'An error occurred';
        final errors = data['errors'];
        return ApiException(
          message: message,
          statusCode: error.response?.statusCode,
          errors: errors,
        );
      }
      return ApiException(
        message: 'Server responded with error (${error.response?.statusCode})',
        statusCode: error.response?.statusCode,
      );
    }

    return ApiException(
      message: error.message ?? 'Unexpected network error',
    );
  }
}
