import 'pump_status.dart';

enum MoistureLevel { healthy, warning, critical }

class ZoneStatus {
  final int zoneNumber;
  final double moisturePercent;
  final DeviceState state;

  const ZoneStatus({
    required this.zoneNumber,
    required this.moisturePercent,
    required this.state,
  });

  String get name => 'Zone $zoneNumber';

  MoistureLevel get level {
    if (moisturePercent < 25) return MoistureLevel.critical;
    if (moisturePercent < 45) return MoistureLevel.warning;
    return MoistureLevel.healthy;
  }

  ZoneStatus copyWith({double? moisturePercent, DeviceState? state}) {
    return ZoneStatus(
      zoneNumber: zoneNumber,
      moisturePercent: moisturePercent ?? this.moisturePercent,
      state: state ?? this.state,
    );
  }
}
