import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../core/services/farm_context.dart';
import '../../domain/entities/pump_status.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/repositories/dashboard_repository.dart';

/// Real backend implementation of [DashboardRepository].
///
/// GUESSED field names (response schemas are undocumented):
/// - weather: `temperature`/`temperature_c`, `humidity`/`humidity_percent`,
///   `rain_probability`/`rain_probability_percent`, `condition`.
/// - pumps: `type` ("borewell"|"open_well"), `status` ("on"|"off") or
///   boolean `is_on`, `flow_rate`/`flow_rate_lpm`, `water_level`/
///   `water_level_percent`.
///
/// Parsing here is defensive: unknown/missing fields degrade to 0/empty
/// rather than throwing, since dashboard data is not critical path.
class ApiDashboardRepository implements DashboardRepository {
  final ApiClient apiClient;
  final FarmContext farmContext;

  ApiDashboardRepository({required this.apiClient, required this.farmContext});

  @override
  Future<DashboardSnapshot> getDashboardSnapshot() async {
    final farmId = farmContext.farmId;

    WeatherData weather = const WeatherData(
      temperatureC: 0,
      humidityPercent: 0,
      rainProbabilityPercent: 0,
      condition: 'Unknown',
    );
    List<PumpStatus> pumps = const [];

    if (farmId != null) {
      // Best-effort refresh from the weather provider, then read latest.
      try {
        await apiClient.post(ApiEndpoints.weather, body: {'farm_id': farmId});
      } catch (_) {
        // Ignore: fall through to GET regardless.
      }

      try {
        final weatherData = await apiClient.get(
          ApiEndpoints.weather,
          query: {'farm_id': farmId},
        );
        if (weatherData is Map) {
          weather = _weatherFromJson(weatherData.cast<String, dynamic>());
        }
      } catch (_) {
        // Keep default weather on failure.
      }

      try {
        final pumpsData = await apiClient.get(
          ApiEndpoints.pumps,
          query: {'farm_id': farmId},
        );
        pumps = _pumpsFromJson(pumpsData);
      } catch (_) {
        // Keep empty pumps on failure.
      }
    }

    return DashboardSnapshot(
      weather: weather,
      pumps: pumps,
      lastSync: DateTime.now(),
    );
  }

  WeatherData _weatherFromJson(Map<String, dynamic> json) {
    double numOf(dynamic v) => (v is num) ? v.toDouble() : 0.0;
    return WeatherData(
      temperatureC: numOf(json['temperature'] ?? json['temperature_c']),
      humidityPercent: numOf(json['humidity'] ?? json['humidity_percent']),
      rainProbabilityPercent:
          numOf(json['rain_probability'] ?? json['rain_probability_percent']),
      condition: (json['condition'] as String?) ?? 'Unknown',
    );
  }

  List<PumpStatus> _pumpsFromJson(dynamic data) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['pumps'] is List) {
      list = data['pumps'] as List;
    } else {
      list = const [];
    }
    return list.whereType<Map>().map((raw) {
      final json = raw.cast<String, dynamic>();
      final typeStr = (json['type'] as String?)?.toLowerCase() ?? 'borewell';
      final type = typeStr.contains('open') ? PumpType.openWell : PumpType.borewell;
      final isOn = _isPumpOn(json);
      final flow = json['flow_rate'] ?? json['flow_rate_lpm'];
      final waterLevel = json['water_level'] ?? json['water_level_percent'];
      return PumpStatus(
        type: type,
        state: isOn ? DeviceState.running : DeviceState.stopped,
        flowRateLpm: (flow is num) ? flow.toDouble() : 0.0,
        waterLevelPercent: (waterLevel is num) ? waterLevel.toDouble() : 0.0,
      );
    }).toList();
  }

  bool _isPumpOn(Map<String, dynamic> json) {
    if (json['is_on'] is bool) return json['is_on'] as bool;
    final status = (json['status'] as String?)?.toLowerCase();
    return status == 'on' || status == 'running' || status == 'true';
  }
}
