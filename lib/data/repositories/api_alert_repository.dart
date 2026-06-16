import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../core/services/farm_context.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';

/// Real backend implementation of [AlertRepository].
///
/// GUESSED field names: `id`, `type` (mapped case-insensitively to
/// [AlertType], default [AlertType.sensorFailure] if unrecognized),
/// `severity` ("critical"|"warning"|"info"), `title`, `message` (fallback
/// to `title` if missing, or vice versa), `timestamp`/`created_at`
/// (ISO string), `read`/`is_read` boolean.
///
/// `dismiss` maps to the same "resolve" PUT endpoint as `markAsRead` since
/// the spec only documents a single PUT for resolving an alert.
class ApiAlertRepository implements AlertRepository {
  final ApiClient apiClient;
  final FarmContext farmContext;

  ApiAlertRepository({required this.apiClient, required this.farmContext});

  @override
  Future<List<AppAlert>> getAlerts() async {
    final farmId = farmContext.farmId;
    if (farmId == null) return const [];
    try {
      final data = await apiClient.get(ApiEndpoints.alerts, query: {'farm_id': farmId});
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['alerts'] is List) {
        list = data['alerts'] as List;
      } else {
        list = const [];
      }
      final alerts = list
          .whereType<Map>()
          .map((raw) => _fromJson(raw.cast<String, dynamic>()))
          .whereType<AppAlert>()
          .toList()
        ..sort((a, b) => a.severity.index.compareTo(b.severity.index));
      return alerts;
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> markAsRead(String id) async {
    await apiClient.put(ApiEndpoints.alerts, body: {'id': id, 'read': true, 'resolved': true});
  }

  @override
  Future<void> dismiss(String id) async {
    await apiClient.put(ApiEndpoints.alerts, body: {'id': id, 'resolved': true});
  }

  AppAlert? _fromJson(Map<String, dynamic> json) {
    try {
      final id = (json['id'] ?? json['alert_id'])?.toString();
      if (id == null) return null;
      final typeStr = (json['type'] as String?)?.toLowerCase().replaceAll('_', '') ?? '';
      final type = switch (typeStr) {
        'lowmoisture' => AlertType.lowMoisture,
        'lowwaterlevel' => AlertType.lowWaterLevel,
        'motorfailure' => AlertType.motorFailure,
        'sensorfailure' => AlertType.sensorFailure,
        'nowaterflow' => AlertType.noWaterFlow,
        'weatherwarning' => AlertType.weatherWarning,
        _ => AlertType.sensorFailure,
      };
      final severityStr = (json['severity'] as String?)?.toLowerCase() ?? 'info';
      final severity = switch (severityStr) {
        'critical' => AlertSeverity.critical,
        'warning' => AlertSeverity.warning,
        _ => AlertSeverity.info,
      };
      final title = (json['title'] as String?) ?? (json['message'] as String?) ?? 'Alert';
      final message = (json['message'] as String?) ?? title;
      final timestamp = DateTime.tryParse(
              (json['timestamp'] as String?) ?? (json['created_at'] as String?) ?? '') ??
          DateTime.now();
      final read = (json['read'] ?? json['is_read'] ?? false) == true;
      return AppAlert(
        id: id,
        type: type,
        severity: severity,
        title: title,
        message: message,
        timestamp: timestamp,
        read: read,
      );
    } catch (_) {
      return null;
    }
  }
}
