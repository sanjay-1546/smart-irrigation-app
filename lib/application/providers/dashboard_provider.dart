import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_cache_service.dart';
import '../../domain/entities/pump_status.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repository;
  final ConnectivityService connectivityService;
  final LocalCacheService cacheService;
  Timer? _timer;

  DashboardProvider({
    required this.repository,
    required this.connectivityService,
    required this.cacheService,
  });

  bool isLoading = false;
  WeatherData? weather;
  List<PumpStatus> pumps = [];
  DateTime? lastSync;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    if (connectivityService.isOffline) {
      final cached = await cacheService.readJson(cacheService.dashboardKey);
      if (cached != null) {
        weather = WeatherData(
          temperatureC: (cached['temperatureC'] as num).toDouble(),
          humidityPercent: (cached['humidityPercent'] as num).toDouble(),
          rainProbabilityPercent: (cached['rainProbabilityPercent'] as num).toDouble(),
          condition: cached['condition'] as String,
        );
        lastSync = DateTime.parse(cached['lastSync'] as String);
      }
      isLoading = false;
      notifyListeners();
      return;
    }
    final snapshot = await repository.getDashboardSnapshot();
    weather = snapshot.weather;
    pumps = snapshot.pumps;
    lastSync = snapshot.lastSync;
    await cacheService.cacheJson(cacheService.dashboardKey, {
      'temperatureC': weather!.temperatureC,
      'humidityPercent': weather!.humidityPercent,
      'rainProbabilityPercent': weather!.rainProbabilityPercent,
      'condition': weather!.condition,
      'lastSync': lastSync!.toIso8601String(),
    });
    isLoading = false;
    notifyListeners();
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
