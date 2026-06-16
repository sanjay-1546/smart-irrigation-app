class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://example-smart-farm.com/api';
  static const String login = '$baseUrl/auth/login';
  static const String logout = '$baseUrl/auth/logout';
  static const String forgotPassword = '$baseUrl/auth/forgot-password';
  static const String dashboard = '$baseUrl/dashboard';
  static const String zones = '$baseUrl/irrigation/zones';
  static const String pumps = '$baseUrl/irrigation/pumps';
  static const String schedules = '$baseUrl/schedules';
  static const String alerts = '$baseUrl/alerts';
  static const String analyticsMoisture = '$baseUrl/analytics/moisture';
  static const String analyticsUsage = '$baseUrl/analytics/usage';
  static const String automationRules = '$baseUrl/automation/rules';
}
