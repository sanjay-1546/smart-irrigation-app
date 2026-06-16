import 'dart:math';
import '../../domain/entities/moisture_reading.dart';
import '../../domain/entities/water_usage.dart';
import '../../domain/repositories/analytics_repository.dart';

class MockAnalyticsRepository implements AnalyticsRepository {
  final _random = Random();

  int _pointsForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return 24;
      case AnalyticsPeriod.weekly:
        return 7;
      case AnalyticsPeriod.monthly:
        return 30;
    }
  }

  Duration _stepForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.daily:
        return const Duration(hours: 1);
      case AnalyticsPeriod.weekly:
      case AnalyticsPeriod.monthly:
        return const Duration(days: 1);
    }
  }

  @override
  Future<List<MoistureReading>> getMoistureTrend(AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final count = _pointsForPeriod(period);
    final step = _stepForPeriod(period);
    final readings = <MoistureReading>[];
    final now = DateTime.now();
    for (var zone = 1; zone <= 4; zone++) {
      double base = 40 + _random.nextDouble() * 30;
      for (var i = count - 1; i >= 0; i--) {
        base += (_random.nextDouble() - 0.5) * 6;
        base = base.clamp(15, 95);
        readings.add(MoistureReading(
          timestamp: now.subtract(step * i),
          zoneNumber: zone,
          moisturePercent: base,
        ));
      }
    }
    return readings;
  }

  @override
  Future<List<WaterUsagePoint>> getWaterUsage(AnalyticsPeriod period) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final count = _pointsForPeriod(period);
    final step = _stepForPeriod(period);
    final now = DateTime.now();
    final points = <WaterUsagePoint>[];
    for (var i = count - 1; i >= 0; i--) {
      points.add(WaterUsagePoint(
        date: now.subtract(step * i),
        litersUsed: 200 + _random.nextDouble() * 600,
        pumpRuntimeMinutes: 20 + _random.nextDouble() * 100,
        rainfallMm: _random.nextDouble() * 20,
      ));
    }
    return points;
  }
}
