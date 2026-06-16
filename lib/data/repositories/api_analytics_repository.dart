import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../core/services/farm_context.dart';
import '../../domain/entities/moisture_reading.dart';
import '../../domain/entities/water_usage.dart';
import '../../domain/repositories/analytics_repository.dart';

/// Real backend implementation of [AnalyticsRepository], backed by
/// `/reports/index.php?farm_id=&type=&report=`.
///
/// Mapping (per task spec): `irrigation_history` -> moisture trend chart,
/// `water_consumption` + `pump_runtime` -> combined into [WaterUsagePoint]
/// (litersUsed from water_consumption, pumpRuntimeMinutes from
/// pump_runtime). There is no rainfall report endpoint, so `rainfallMm`
/// is left at 0 here (the existing weather/mock source is the only place
/// with real rainfall data, intentionally not duplicated in this class).
///
/// GUESSED field names: irrigation_history entries have `timestamp`/`date`,
/// `zone`/`zone_number`, `moisture`. water_consumption/pump_runtime entries
/// have `date`, `value`/`liters`/`minutes`.
class ApiAnalyticsRepository implements AnalyticsRepository {
  final ApiClient apiClient;
  final FarmContext farmContext;

  ApiAnalyticsRepository({required this.apiClient, required this.farmContext});

  String _typeParam(AnalyticsPeriod period) => switch (period) {
        AnalyticsPeriod.daily => 'daily',
        AnalyticsPeriod.weekly => 'weekly',
        AnalyticsPeriod.monthly => 'monthly',
      };

  @override
  Future<List<MoistureReading>> getMoistureTrend(AnalyticsPeriod period) async {
    final farmId = farmContext.farmId;
    if (farmId == null) return const [];
    try {
      final data = await apiClient.get(ApiEndpoints.reports, query: {
        'farm_id': farmId,
        'type': _typeParam(period),
        'report': 'irrigation_history',
      });
      final list = _extractList(data, 'irrigation_history');
      return list.whereType<Map>().map((raw) {
        final json = raw.cast<String, dynamic>();
        final timestamp = DateTime.tryParse(
                (json['timestamp'] as String?) ?? (json['date'] as String?) ?? '') ??
            DateTime.now();
        final zone = json['zone'] ?? json['zone_number'];
        final moisture = json['moisture'];
        return MoistureReading(
          timestamp: timestamp,
          zoneNumber: zone is num ? zone.toInt() : 0,
          moisturePercent: moisture is num ? moisture.toDouble() : 0.0,
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<WaterUsagePoint>> getWaterUsage(AnalyticsPeriod period) async {
    final farmId = farmContext.farmId;
    if (farmId == null) return const [];

    Map<String, double> consumptionByDate = {};
    Map<String, double> runtimeByDate = {};

    try {
      final data = await apiClient.get(ApiEndpoints.reports, query: {
        'farm_id': farmId,
        'type': _typeParam(period),
        'report': 'water_consumption',
      });
      consumptionByDate = _dateValueMap(_extractList(data, 'water_consumption'));
    } catch (_) {
      // Keep empty map on failure.
    }

    try {
      final data = await apiClient.get(ApiEndpoints.reports, query: {
        'farm_id': farmId,
        'type': _typeParam(period),
        'report': 'pump_runtime',
      });
      runtimeByDate = _dateValueMap(_extractList(data, 'pump_runtime'));
    } catch (_) {
      // Keep empty map on failure.
    }

    final allDates = {...consumptionByDate.keys, ...runtimeByDate.keys}.toList()..sort();
    return allDates.map((dateKey) {
      final date = DateTime.tryParse(dateKey) ?? DateTime.now();
      return WaterUsagePoint(
        date: date,
        litersUsed: consumptionByDate[dateKey] ?? 0.0,
        pumpRuntimeMinutes: runtimeByDate[dateKey] ?? 0.0,
        rainfallMm: 0.0,
      );
    }).toList();
  }

  List<dynamic> _extractList(dynamic data, String key) {
    if (data is List) return data;
    if (data is Map && data[key] is List) return data[key] as List;
    if (data is Map && data['data'] is List) return data['data'] as List;
    return const [];
  }

  Map<String, double> _dateValueMap(List<dynamic> list) {
    final map = <String, double>{};
    for (final raw in list) {
      if (raw is! Map) continue;
      final json = raw.cast<String, dynamic>();
      final dateStr = (json['date'] as String?) ?? (json['timestamp'] as String?);
      if (dateStr == null) continue;
      final value = json['value'] ?? json['liters'] ?? json['minutes'] ?? json['total'];
      map[dateStr] = value is num ? value.toDouble() : 0.0;
    }
    return map;
  }
}
