import 'package:flutter/material.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_cache_service.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository;
  final ConnectivityService connectivityService;
  final LocalCacheService cacheService;

  ScheduleProvider({
    required this.repository,
    required this.connectivityService,
    required this.cacheService,
  });

  bool isLoading = false;
  List<Schedule> schedules = [];
  String? errorMessage;

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    if (connectivityService.isOffline) {
      final cached = await cacheService.readJsonList(cacheService.schedulesKey);
      if (cached != null) {
        schedules = cached.map(_fromJson).toList();
      }
      isLoading = false;
      notifyListeners();
      return;
    }
    try {
      schedules = await repository.getSchedules();
      await cacheService.cacheJsonList(
        cacheService.schedulesKey,
        schedules.map(_toJson).toList(),
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> _toJson(Schedule s) => {
        'id': s.id,
        'zoneNumber': s.zoneNumber,
        'source': s.source.index,
        'startHour': s.startTime.hour,
        'startMinute': s.startTime.minute,
        'endHour': s.endTime.hour,
        'endMinute': s.endTime.minute,
        'repeat': s.repeat.index,
        'date': s.date.toIso8601String(),
        'active': s.active,
      };

  Schedule _fromJson(Map<String, dynamic> json) => Schedule(
        id: json['id'] as String,
        zoneNumber: json['zoneNumber'] as int,
        source: WaterSource.values[json['source'] as int],
        startTime: TimeOfDay(hour: json['startHour'] as int, minute: json['startMinute'] as int),
        endTime: TimeOfDay(hour: json['endHour'] as int, minute: json['endMinute'] as int),
        repeat: ScheduleRepeat.values[json['repeat'] as int],
        date: DateTime.parse(json['date'] as String),
        active: json['active'] as bool,
      );

  Future<void> createSchedule(Schedule schedule) async {
    errorMessage = null;
    try {
      await repository.createSchedule(schedule);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  Future<void> updateSchedule(Schedule schedule) async {
    errorMessage = null;
    try {
      await repository.updateSchedule(schedule);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }

  Future<void> deleteSchedule(String id) async {
    errorMessage = null;
    try {
      await repository.deleteSchedule(id);
    } catch (e) {
      errorMessage = e.toString().replaceFirst('ApiException: ', '');
    }
    await load();
  }
}
