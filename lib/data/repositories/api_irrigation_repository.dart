import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../core/services/farm_context.dart';
import '../../domain/entities/pump_status.dart';
import '../../domain/entities/zone_status.dart';
import '../../domain/repositories/irrigation_repository.dart';

/// Real backend implementation of [IrrigationRepository].
///
/// GUESSED field names:
/// - zones: `id`, `name`, `moisture` (0-100), `status`/`is_on` for whether
///   the zone is currently irrigating. Zone number is derived from order or
///   a `zone_number`/`number` field, falling back to list index + 1.
/// - pumps: same shape as in [ApiDashboardRepository].
/// - `/pumps/control.php` body: `{ farm_id, type: "borewell"|"open_well"|
///   "zone1".."zone4", action: "on"|"off" }`. Zone control reuses the same
///   endpoint with a `zoneN` type since there is no separate zone-control
///   endpoint documented.
///
/// Per the task spec: pump/zone control never optimistically mutates local
/// state — callers should always refetch (`getZones`/`getPumps`) after a
/// control call, success or failure, so the UI reflects server truth.
class ApiIrrigationRepository implements IrrigationRepository {
  final ApiClient apiClient;
  final FarmContext farmContext;

  ApiIrrigationRepository({required this.apiClient, required this.farmContext});

  @override
  Future<List<ZoneStatus>> getZones() async {
    final farmId = farmContext.farmId;
    if (farmId == null) return const [];
    try {
      final data = await apiClient.get(ApiEndpoints.zones, query: {'farm_id': farmId});
      return _zonesFromJson(data);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<List<PumpStatus>> getPumps() async {
    final farmId = farmContext.farmId;
    if (farmId == null) return const [];
    try {
      final data = await apiClient.get(ApiEndpoints.pumps, query: {'farm_id': farmId});
      return _pumpsFromJson(data);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> setPumpState(PumpType type, DeviceState state) async {
    final farmId = farmContext.farmId;
    final typeStr = type == PumpType.borewell ? 'borewell' : 'open_well';
    await apiClient.post(ApiEndpoints.pumpsControl, body: {
      'farm_id': farmId,
      'type': typeStr,
      'action': state == DeviceState.running ? 'on' : 'off',
    });
  }

  @override
  Future<void> setZoneState(int zoneNumber, DeviceState state) async {
    final farmId = farmContext.farmId;
    await apiClient.post(ApiEndpoints.pumpsControl, body: {
      'farm_id': farmId,
      'type': 'zone$zoneNumber',
      'action': state == DeviceState.running ? 'on' : 'off',
    });
  }

  @override
  Future<void> emergencyStopAll() async {
    final farmId = farmContext.farmId;
    const targets = ['borewell', 'open_well', 'zone1', 'zone2', 'zone3', 'zone4'];
    for (final target in targets) {
      try {
        await apiClient.post(ApiEndpoints.pumpsControl, body: {
          'farm_id': farmId,
          'type': target,
          'action': 'off',
        });
      } catch (_) {
        // Continue stopping the remaining targets even if one call fails.
      }
    }
  }

  List<ZoneStatus> _zonesFromJson(dynamic data) {
    List<dynamic> list;
    if (data is List) {
      list = data;
    } else if (data is Map && data['zones'] is List) {
      list = data['zones'] as List;
    } else {
      list = const [];
    }
    final zones = <ZoneStatus>[];
    for (var i = 0; i < list.length; i++) {
      final raw = list[i];
      if (raw is! Map) continue;
      final json = raw.cast<String, dynamic>();
      final zoneNumber = (json['zone_number'] ?? json['number'] ?? (i + 1)) is num
          ? (json['zone_number'] ?? json['number'] ?? (i + 1)).toInt()
          : i + 1;
      final moisture = json['moisture'];
      final moisturePercent = (moisture is num) ? moisture.toDouble() : 0.0;
      final isOn = _isOn(json);
      zones.add(ZoneStatus(
        zoneNumber: zoneNumber,
        moisturePercent: moisturePercent,
        state: isOn ? DeviceState.running : DeviceState.stopped,
      ));
    }
    return zones;
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
      final isOn = _isOn(json);
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

  bool _isOn(Map<String, dynamic> json) {
    if (json['is_on'] is bool) return json['is_on'] as bool;
    final status = (json['status'] as String?)?.toLowerCase();
    return status == 'on' || status == 'running' || status == 'true';
  }
}
