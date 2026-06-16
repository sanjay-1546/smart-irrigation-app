import 'package:flutter/material.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

class MockScheduleRepository implements ScheduleRepository {
  int _idCounter = 4;

  final List<Schedule> _schedules = [
    Schedule(
      id: 's1',
      zoneNumber: 1,
      source: WaterSource.borewell,
      startTime: const TimeOfDay(hour: 6, minute: 0),
      endTime: const TimeOfDay(hour: 6, minute: 30),
      repeat: ScheduleRepeat.daily,
      date: DateTime.now(),
    ),
    Schedule(
      id: 's2',
      zoneNumber: 2,
      source: WaterSource.openWell,
      startTime: const TimeOfDay(hour: 18, minute: 0),
      endTime: const TimeOfDay(hour: 18, minute: 20),
      repeat: ScheduleRepeat.weekly,
      date: DateTime.now().add(const Duration(days: 1)),
    ),
    Schedule(
      id: 's3',
      zoneNumber: 3,
      source: WaterSource.borewell,
      startTime: const TimeOfDay(hour: 7, minute: 0),
      endTime: const TimeOfDay(hour: 7, minute: 15),
      repeat: ScheduleRepeat.none,
      date: DateTime.now().add(const Duration(days: 2)),
    ),
  ];

  @override
  Future<List<Schedule>> getSchedules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_schedules);
  }

  @override
  Future<Schedule> createSchedule(Schedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final created = Schedule(
      id: 's${_idCounter++}',
      zoneNumber: schedule.zoneNumber,
      source: schedule.source,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      repeat: schedule.repeat,
      date: schedule.date,
      active: schedule.active,
    );
    _schedules.add(created);
    return created;
  }

  @override
  Future<Schedule> updateSchedule(Schedule schedule) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final idx = _schedules.indexWhere((s) => s.id == schedule.id);
    if (idx != -1) {
      _schedules[idx] = schedule;
    }
    return schedule;
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _schedules.removeWhere((s) => s.id == id);
  }
}
