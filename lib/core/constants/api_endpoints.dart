class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://sanjay-smart-irrigation.senthilnasa.me/api';

  // Auth
  static const String login = '$baseUrl/auth/login.php';
  static const String logout = '$baseUrl/auth/logout.php';
  static const String register = '$baseUrl/auth/register.php';
  static const String me = '$baseUrl/auth/me.php';

  // Farms
  static const String farms = '$baseUrl/farms/index.php';

  // Devices (not used by this app)
  static const String devices = '$baseUrl/devices/index.php';

  // Zones
  static const String zones = '$baseUrl/zones/index.php';

  // Pumps
  static const String pumps = '$baseUrl/pumps/index.php';
  static const String pumpsControl = '$baseUrl/pumps/control.php';

  // Schedules
  static const String schedules = '$baseUrl/schedules/index.php';

  // Weather
  static const String weather = '$baseUrl/weather/index.php';

  // Alerts
  static const String alerts = '$baseUrl/alerts/index.php';

  // Reports (Analytics)
  static const String reports = '$baseUrl/reports/index.php';
}
