import 'package:flutter/material.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/services/api_client.dart';
import '../../core/services/farm_context.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

/// Real backend implementation of [ScheduleRepository].
///
/// GUESSED field names, matched as closely as possible to what
/// [Schedule]/`ScheduleProvider` already use internally: `id`, `zone`
/// (zone number), `water_source` ("borewell"|"open_well"), `start_time`
/// and `end_time` ("HH:mm" strings), `repeat_daily`/`repeat_weekly`
/// booleans, `date` (ISO string), `active`/`is_active`.
class ApiScheduleRepository implements ScheduleRepository {
  final ApiClient apiClient;
  final FarmContext farmContext;

  ApiScheduleRepository({required this.apiClient, required this.farmContext});

  @override
  Future<List<Schedule>> getSchedules() async {
    final farmId = farmContext.farmId;
    if (farmId == null) return const [];
    try {
      final data = await apiClient.get(ApiEndpoints.schedules, query: {'farm_id': farmId});
      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map && data['schedules'] is List) {
        list = data['schedules'] as List;
      } else {
        list = const [];
      }
      return list
          .whereType<Map>()
          .map((raw) => _fromJson(raw.cast<String, dynamic>()))
          .whereType<Schedule>()
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<Schedule> createSchedule(Schedule schedule) async {
    final farmId = farmContext.farmId;
    final data = await apiClient.post(
      ApiEndpoints.schedules,
      body: _toJson(schedule, farmId: farmId),
    );
    final parsed = data is Map ? _fromJson(data.cast<String, dynamic>()) : null;
    return parsed ?? schedule;
  }

  @override
  Future<Schedule> updateSchedule(Schedule schedule) async {
    final farmId = farmContext.farmId;
    final data = await apiClient.put(
      ApiEndpoints.schedules,
      body: {'id': schedule.id, ..._toJson(schedule, farmId: farmId)},
    );
    final parsed = data is Map ? _fromJson(data.cast<String, dynamic>()) : null;
    return parsed ?? schedule;
  }

  @override
  Future<void> deleteSchedule(String id) async {
    await apiClient.delete(ApiEndpoints.schedules, body: {'id': id});
  }

  Map<String, dynamic> _toJson(Schedule s, {String? farmId}) {
    String fmt(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return {
      'farm_id': farmId,
      'zone': s.zoneNumber,
      'water_source': s.source == WaterSource.borewell ? 'borewell' : 'open_well',
      'start_time': fmt(s.startTime),
      'end_time': fmt(s.endTime),
      'repeat_daily': s.repeat == ScheduleRepeat.daily,
      'repeat_weekly': s.repeat == ScheduleRepeat.weekly,
      'date': s.date.toIso8601String(),
      'active': s.active,
    };
  }

  Schedule? _fromJson(Map<String, dynamic> json) {
    try {
      final id = (json['id'] ?? json['schedule_id'])?.toString();
      if (id == null) return null;
      final zone = (json['zone'] ?? json['zone_number']);
      final sourceStr = (json['water_source'] as String?)?.toLowerCase() ?? 'borewell';
      final repeatDaily = json['repeat_daily'] == true;
      final repeatWeekly = json['repeat_weekly'] == true;
      final repeat = repeatDaily
          ? ScheduleRepeat.daily
          : (repeatWeekly ? ScheduleRepeat.weekly : ScheduleRepeat.none);
      return Schedule(
        id: id,
        zoneNumber: zone is num ? zone.toInt() : 1,
        source: sourceStr.contains('open') ? WaterSource.openWell : WaterSource.borewell,
        startTime: _parseTime(json['start_time'] as String?) ?? const TimeOfDay(hour: 6, minute: 0),
        endTime: _parseTime(json['end_time'] as String?) ?? const TimeOfDay(hour: 6, minute: 30),
        repeat: repeat,
        date: DateTime.tryParse((json['date'] as String?) ?? '') ?? DateTime.now(),
        active: (json['active'] ?? json['is_active'] ?? true) == true,
      );
    } catch (_) {
      return null;
    }
  }

  TimeOfDay? _parseTime(String? raw) {
    if (raw == null) return null;
    final parts = raw.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }
}
