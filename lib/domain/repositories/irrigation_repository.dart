import '../entities/pump_status.dart';
import '../entities/zone_status.dart';

abstract class IrrigationRepository {
  Future<List<ZoneStatus>> getZones();
  Future<List<PumpStatus>> getPumps();
  Future<void> setPumpState(PumpType type, DeviceState state);
  Future<void> setZoneState(int zoneNumber, DeviceState state);
  Future<void> emergencyStopAll();
}
