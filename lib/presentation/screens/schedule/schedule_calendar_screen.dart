import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../domain/entities/schedule.dart';

class ScheduleCalendarScreen extends StatefulWidget {
  final List<Schedule> schedules;

  const ScheduleCalendarScreen({super.key, required this.schedules});

  @override
  State<ScheduleCalendarScreen> createState() => _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState extends State<ScheduleCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<Schedule> _schedulesForDay(DateTime day) {
    return widget.schedules.where((s) {
      if (s.repeat == ScheduleRepeat.daily) return true;
      if (s.repeat == ScheduleRepeat.weekly) return s.date.weekday == day.weekday;
      return s.date.year == day.year && s.date.month == day.month && s.date.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? DateTime.now();
    final daySchedules = _schedulesForDay(selected);

    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now().subtract(const Duration(days: 365)),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: _schedulesForDay,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
            selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: daySchedules.isEmpty
              ? const Center(child: Text('No schedules for this day.'))
              : ListView.builder(
                  itemCount: daySchedules.length,
                  itemBuilder: (context, index) {
                    final s = daySchedules[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('Z${s.zoneNumber}')),
                      title: Text(
                        '${DateFormatters.timeOfDay(s.startTime)} - ${DateFormatters.timeOfDay(s.endTime)}',
                      ),
                      subtitle: Text(s.source == WaterSource.borewell ? 'Borewell' : 'Open Well'),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
