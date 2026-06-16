import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/secure_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  final SecureStorageService secureStorage;
  final ConnectivityService connectivityService;

  SettingsProvider({required this.secureStorage, required this.connectivityService});

  static const _moistureThresholdKey = 'moisture_threshold';
  static const _waterLevelThresholdKey = 'water_level_threshold';

  String? weatherApiKey;
  double moistureThreshold = 30;
  double waterLevelThreshold = 20;
  bool offlineMode = false;

  Future<void> load() async {
    weatherApiKey = await secureStorage.readWeatherApiKey();
    final prefs = await SharedPreferences.getInstance();
    moistureThreshold = prefs.getDouble(_moistureThresholdKey) ?? 30;
    waterLevelThreshold = prefs.getDouble(_waterLevelThresholdKey) ?? 20;
    offlineMode = connectivityService.isOffline;
    notifyListeners();
  }

  Future<void> saveWeatherApiKey(String key) async {
    weatherApiKey = key;
    await secureStorage.saveWeatherApiKey(key);
    notifyListeners();
  }

  Future<void> setMoistureThreshold(double value) async {
    moistureThreshold = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_moistureThresholdKey, value);
  }

  Future<void> setWaterLevelThreshold(double value) async {
    waterLevelThreshold = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_waterLevelThresholdKey, value);
  }

  void setOfflineMode(bool offline) {
    offlineMode = offline;
    connectivityService.setOfflineMode(offline);
    notifyListeners();
  }
}
