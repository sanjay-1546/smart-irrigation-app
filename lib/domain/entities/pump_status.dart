enum PumpType { borewell, openWell }

enum DeviceState { running, stopped, fault }

class PumpStatus {
  final PumpType type;
  final DeviceState state;
  final double flowRateLpm;
  final double waterLevelPercent;

  const PumpStatus({
    required this.type,
    required this.state,
    required this.flowRateLpm,
    required this.waterLevelPercent,
  });

  String get label => type == PumpType.borewell ? 'Bore Pump' : 'Well Pump';

  PumpStatus copyWith({DeviceState? state, double? flowRateLpm, double? waterLevelPercent}) {
    return PumpStatus(
      type: type,
      state: state ?? this.state,
      flowRateLpm: flowRateLpm ?? this.flowRateLpm,
      waterLevelPercent: waterLevelPercent ?? this.waterLevelPercent,
    );
  }
}
