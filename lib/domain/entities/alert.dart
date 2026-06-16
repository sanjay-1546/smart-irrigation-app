enum AlertSeverity { critical, warning, info }

enum AlertType {
  lowMoisture,
  lowWaterLevel,
  motorFailure,
  sensorFailure,
  noWaterFlow,
  weatherWarning,
}

class AppAlert {
  final String id;
  final AlertType type;
  final AlertSeverity severity;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool read;

  const AppAlert({
    required this.id,
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
    required this.timestamp,
    this.read = false,
  });

  AppAlert copyWith({bool? read}) {
    return AppAlert(
      id: id,
      type: type,
      severity: severity,
      title: title,
      message: message,
      timestamp: timestamp,
      read: read ?? this.read,
    );
  }
}
