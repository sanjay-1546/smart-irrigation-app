import 'package:flutter/material.dart';
import '../../domain/entities/moisture_reading.dart';
import '../../domain/entities/water_usage.dart';
import '../../domain/repositories/analytics_repository.dart';

class AnalyticsProvider extends ChangeNotifier {
  final AnalyticsRepository repository;

  AnalyticsProvider({required this.repository});

  bool isLoading = false;
  AnalyticsPeriod period = AnalyticsPeriod.weekly;
  List<MoistureReading> moistureTrend = [];
  List<WaterUsagePoint> waterUsage = [];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    moistureTrend = await repository.getMoistureTrend(period);
    waterUsage = await repository.getWaterUsage(period);
    isLoading = false;
    notifyListeners();
  }

  Future<void> setPeriod(AnalyticsPeriod newPeriod) async {
    period = newPeriod;
    await load();
  }
}
