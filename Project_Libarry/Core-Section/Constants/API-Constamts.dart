class ApiConstants {
  // Live Production Backend on Render
  static const String liveProductionUrl = 'https://taskflow-backend-9mvd.onrender.com/api';
  static const String defaultLocalhostUrl = 'http://localhost:5000/api';
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:5000/api';

  static String getDefaultBaseUrl() {
    return liveProductionUrl;
  }

  // Storage key for custom base URL
  static const String baseUrlStorageKey = 'taskflow_custom_base_url';

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String meEndpoint = '/auth/me';
  static const String tasksEndpoint = '/tasks';
  static const String taskStatsEndpoint = '/tasks/stats';
}
