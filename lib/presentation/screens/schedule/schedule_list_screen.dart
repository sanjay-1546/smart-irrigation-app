import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/schedule_provider.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../domain/entities/schedule.dart';
import '../../widgets/confirm_dialog.dart';
import 'schedule_calendar_screen.dart';
import 'schedule_form_screen.dart';

class ScheduleListScreen extends StatefulWidget {
  const ScheduleListScreen({super.key});

  @override
  State<ScheduleListScreen> createState() => _ScheduleListScreenState();
}

class _ScheduleListScreenState extends State<ScheduleListScreen> {
  bool _showCalendar = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<ScheduleProvider>().load());
  }

  Future<void> _deleteSchedule(Schedule schedule) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete Schedule',
      message: 'Delete the schedule for ${schedule.zoneNumberLabel}? This cannot be undone.',
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      await context.read<ScheduleProvider>().deleteSchedule(schedule.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ScheduleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedules'),
        actions: [
          IconButton(
            icon: Icon(_showCalendar ? Icons.list : Icons.calendar_month),
            tooltip: _showCalendar ? 'List view' : 'Calendar view',
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ScheduleFormScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading && provider.schedules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _showCalendar
              ? ScheduleCalendarScreen(schedules: provider.schedules)
              : provider.schedules.isEmpty
                  ? const Center(child: Text('No schedules yet. Tap + to create one.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = provider.schedules[index];
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primaryContainer,
                              child: Text('Z${schedule.zoneNumber}'),
                            ),
                            title: Text(
                              '${DateFormatters.timeOfDay(schedule.startTime)} - ${DateFormatters.timeOfDay(schedule.endTime)}',
                            ),
                            subtitle: Text(
                              '${schedule.source == WaterSource.borewell ? 'Borewell' : 'Open Well'} • '
                              '${schedule.repeat == ScheduleRepeat.daily ? 'Daily' : schedule.repeat == ScheduleRepeat.weekly ? 'Weekly' : DateFormatters.date(schedule.date)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined),
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ScheduleFormScreen(existing: schedule),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _deleteSchedule(schedule),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}

extension on Schedule {
  String get zoneNumberLabel => 'Zone $zoneNumber';
}
