import '../entities/alert.dart';

abstract class AlertRepository {
  Future<List<AppAlert>> getAlerts();
  Future<void> markAsRead(String id);
  Future<void> dismiss(String id);
}
