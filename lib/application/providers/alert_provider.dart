import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertProvider extends ChangeNotifier {
  final AlertRepository repository;

  AlertProvider({required this.repository});

  bool isLoading = false;
  List<AppAlert> alerts = [];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    alerts = await repository.getAlerts();
    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    await repository.markAsRead(id);
    await load();
  }

  Future<void> dismiss(String id) async {
    await repository.dismiss(id);
    await load();
  }

  int get criticalCount => alerts.where((a) => a.severity == AlertSeverity.critical).length;
}
