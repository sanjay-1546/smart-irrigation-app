import '../entities/moisture_reading.dart';
import '../entities/water_usage.dart';

enum AnalyticsPeriod { daily, weekly, monthly }

abstract class AnalyticsRepository {
  Future<List<MoistureReading>> getMoistureTrend(AnalyticsPeriod period);
  Future<List<WaterUsagePoint>> getWaterUsage(AnalyticsPeriod period);
}
