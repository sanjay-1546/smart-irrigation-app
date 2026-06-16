import '../entities/pump_status.dart';
import '../entities/weather_data.dart';

class DashboardSnapshot {
  final WeatherData weather;
  final List<PumpStatus> pumps;
  final DateTime lastSync;

  const DashboardSnapshot({
    required this.weather,
    required this.pumps,
    required this.lastSync,
  });
}

abstract class DashboardRepository {
  Future<DashboardSnapshot> getDashboardSnapshot();
}
