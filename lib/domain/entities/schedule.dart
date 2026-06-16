import 'package:flutter/material.dart';

enum WaterSource { borewell, openWell }

enum RepeatMode { none, daily, weekly }

class Schedule {
  final String id;
  final int zoneNumber;
  final WaterSource source;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final RepeatMode repeat;
  final DateTime date;
  final bool active;

  const Schedule({
    required this.id,
    required this.zoneNumber,
    required this.source,
    required this.startTime,
    required this.endTime,
    required this.repeat,
    required this.date,
    this.active = true,
  });

  Schedule copyWith({
    int? zoneNumber,
    WaterSource? source,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    RepeatMode? repeat,
    DateTime? date,
    bool? active,
  }) {
    return Schedule(
      id: id,
      zoneNumber: zoneNumber ?? this.zoneNumber,
      source: source ?? this.source,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repeat: repeat ?? this.repeat,
      date: date ?? this.date,
      active: active ?? this.active,
    );
  }
}
