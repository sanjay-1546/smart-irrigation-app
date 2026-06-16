import 'dart:math';
import '../../domain/entities/pump_status.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

class MockDashboardRepository implements DashboardRepository {
  final _random = Random();

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return DashboardSnapshot(
      weather: WeatherData(
        temperatureC: 26 + _random.nextDouble() * 8,
        humidityPercent: 50 + _random.nextDouble() * 30,
        rainProbabilityPercent: _random.nextDouble() * 100,
        condition: ['Sunny', 'Partly Cloudy', 'Cloudy', 'Light Rain'][_random.nextInt(4)],
      ),
      pumps: [
        PumpStatus(
          type: PumpType.borewell,
          state: DeviceState.running,
          flowRateLpm: 40 + _random.nextDouble() * 20,
          waterLevelPercent: 60 + _random.nextDouble() * 30,
        ),
        PumpStatus(
          type: PumpType.openWell,
          state: DeviceState.stopped,
          flowRateLpm: 0,
          waterLevelPercent: 35 + _random.nextDouble() * 30,
        ),
      ],
      lastSync: DateTime.now(),
    );
  }
}
