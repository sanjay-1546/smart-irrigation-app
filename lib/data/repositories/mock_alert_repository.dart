import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';

class MockAlertRepository implements AlertRepository {
  final List<AppAlert> _alerts = [
    AppAlert(
      id: 'a1',
      type: AlertType.lowMoisture,
      severity: AlertSeverity.critical,
      title: 'Low Moisture - Zone 3',
      message: 'Soil moisture in Zone 3 has dropped below 25%.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
    ),
    AppAlert(
      id: 'a2',
      type: AlertType.lowWaterLevel,
      severity: AlertSeverity.warning,
      title: 'Low Water Level',
      message: 'Open well water level is at 32%, consider refilling soon.',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    AppAlert(
      id: 'a3',
      type: AlertType.motorFailure,
      severity: AlertSeverity.critical,
      title: 'Motor Failure Detected',
      message: 'Bore pump motor reported an overcurrent fault.',
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    AppAlert(
      id: 'a4',
      type: AlertType.sensorFailure,
      severity: AlertSeverity.warning,
      title: 'Sensor Failure - Zone 2',
      message: 'Moisture sensor in Zone 2 is not responding.',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    AppAlert(
      id: 'a5',
      type: AlertType.noWaterFlow,
      severity: AlertSeverity.critical,
      title: 'No Water Flow',
      message: 'No flow detected at Zone 4 despite pump running.',
      timestamp: DateTime.now().subtract(const Duration(hours: 8)),
    ),
    AppAlert(
      id: 'a6',
      type: AlertType.weatherWarning,
      severity: AlertSeverity.info,
      title: 'Weather Warning',
      message: 'Heavy rain expected tomorrow afternoon; irrigation may be skipped.',
      timestamp: DateTime.now().subtract(const Duration(hours: 10)),
    ),
  ];

  @override
  Future<List<AppAlert>> getAlerts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sorted = [..._alerts]
      ..sort((a, b) => a.severity.index.compareTo(b.severity.index));
    return List.unmodifiable(sorted);
  }

  @override
  Future<void> markAsRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _alerts.indexWhere((a) => a.id == id);
    if (idx != -1) {
      _alerts[idx] = _alerts[idx].copyWith(read: true);
    }
  }

  @override
  Future<void> dismiss(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _alerts.removeWhere((a) => a.id == id);
  }
}
