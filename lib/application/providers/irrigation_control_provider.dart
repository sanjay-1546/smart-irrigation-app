import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/pump_status.dart';
import '../../domain/entities/zone_status.dart';
import '../../domain/repositories/irrigation_repository.dart';

class IrrigationControlProvider extends ChangeNotifier {
  final IrrigationRepository repository;
  Timer? _timer;

  IrrigationControlProvider({required this.repository});

  bool isLoading = false;
  List<ZoneStatus> zones = [];
  List<PumpStatus> pumps = [];
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      zones = await repository.getZones();
      pumps = await repository.getPumps();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => load());
  }

  Future<void> setPumpState(PumpType type, DeviceState state) async {
    errorMessage = null;
    try {
      await repository.setPumpState(type, state);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  Future<void> setZoneState(int zoneNumber, DeviceState state) async {
    errorMessage = null;
    try {
      await repository.setZoneState(zoneNumber, state);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  Future<void> emergencyStopAll() async {
    errorMessage = null;
    try {
      await repository.emergencyStopAll();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
