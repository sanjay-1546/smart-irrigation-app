import '../entities/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getSchedules();
  Future<Schedule> createSchedule(Schedule schedule);
  Future<Schedule> updateSchedule(Schedule schedule);
  Future<void> deleteSchedule(String id);
}
