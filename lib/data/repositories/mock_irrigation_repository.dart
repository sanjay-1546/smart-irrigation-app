import 'dart:math';
import '../../domain/entities/pump_status.dart';
import '../../domain/entities/zone_status.dart';
import '../../domain/repositories/irrigation_repository.dart';

class MockIrrigationRepository implements IrrigationRepository {
  final _random = Random();

  final List<ZoneStatus> _zones = [
    const ZoneStatus(zoneNumber: 1, moisturePercent: 62, state: DeviceState.running),
    const ZoneStatus(zoneNumber: 2, moisturePercent: 41, state: DeviceState.stopped),
    const ZoneStatus(zoneNumber: 3, moisturePercent: 28, state: DeviceState.stopped),
    const ZoneStatus(zoneNumber: 4, moisturePercent: 75, state: DeviceState.stopped),
  ];

  final List<PumpStatus> _pumps = [
    const PumpStatus(
      type: PumpType.borewell,
      state: DeviceState.running,
      flowRateLpm: 45,
      waterLevelPercent: 72,
    ),
    const PumpStatus(
      type: PumpType.openWell,
      state: DeviceState.stopped,
      flowRateLpm: 0,
      waterLevelPercent: 50,
    ),
  ];

  @override
  Future<List<ZoneStatus>> getZones() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var i = 0; i < _zones.length; i++) {
      final z = _zones[i];
      final delta = (_random.nextDouble() - 0.5) * 4;
      final next = (z.moisturePercent + delta).clamp(5, 95).toDouble();
      _zones[i] = z.copyWith(moisturePercent: next);
    }
    return List.unmodifiable(_zones);
  }

  @override
  Future<List<PumpStatus>> getPumps() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.unmodifiable(_pumps);
  }

  @override
  Future<void> setPumpState(PumpType type, DeviceState state) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _pumps.indexWhere((p) => p.type == type);
    if (idx != -1) {
      _pumps[idx] = _pumps[idx].copyWith(
        state: state,
        flowRateLpm: state == DeviceState.running ? 40 + _random.nextDouble() * 20 : 0,
      );
    }
  }

  @override
  Future<void> setZoneState(int zoneNumber, DeviceState state) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _zones.indexWhere((z) => z.zoneNumber == zoneNumber);
    if (idx != -1) {
      _zones[idx] = _zones[idx].copyWith(state: state);
    }
  }

  @override
  Future<void> emergencyStopAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    for (var i = 0; i < _pumps.length; i++) {
      _pumps[i] = _pumps[i].copyWith(state: DeviceState.stopped, flowRateLpm: 0);
    }
    for (var i = 0; i < _zones.length; i++) {
      _zones[i] = _zones[i].copyWith(state: DeviceState.stopped);
    }
  }
}
