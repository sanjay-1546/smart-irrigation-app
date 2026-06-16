import 'package:flutter/material.dart';
import '../../domain/entities/alert.dart';
import '../../domain/repositories/alert_repository.dart';

class AlertProvider extends ChangeNotifier {
  final AlertRepository repository;

  AlertProvider({required this.repository});

  bool isLoading = false;
  List<AppAlert> alerts = [];
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    try {
      alerts = await repository.getAlerts();
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String id) async {
    errorMessage = null;
    try {
      await repository.markAsRead(id);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  Future<void> dismiss(String id) async {
    errorMessage = null;
    try {
      await repository.dismiss(id);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  int get criticalCount => alerts.where((a) => a.severity == AlertSeverity.critical).length;
}
