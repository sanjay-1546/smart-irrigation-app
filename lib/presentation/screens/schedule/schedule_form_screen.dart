import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/schedule_provider.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../domain/entities/schedule.dart';

class ScheduleFormScreen extends StatefulWidget {
  final Schedule? existing;

  const ScheduleFormScreen({super.key, this.existing});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  late int _zone;
  late WaterSource _source;
  late TimeOfDay _start;
  late TimeOfDay _end;
  late ScheduleRepeat _repeat;
  late DateTime _date;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _zone = e?.zoneNumber ?? 1;
    _source = e?.source ?? WaterSource.borewell;
    _start = e?.startTime ?? const TimeOfDay(hour: 6, minute: 0);
    _end = e?.endTime ?? const TimeOfDay(hour: 6, minute: 30);
    _repeat = e?.repeat ?? ScheduleRepeat.none;
    _date = e?.date ?? DateTime.now();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() => isStart ? _start = picked : _end = picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final provider = context.read<ScheduleProvider>();
    final schedule = Schedule(
      id: widget.existing?.id ?? '',
      zoneNumber: _zone,
      source: _source,
      startTime: _start,
      endTime: _end,
      repeat: _repeat,
      date: _date,
    );
    if (widget.existing != null) {
      await provider.updateSchedule(schedule);
    } else {
      await provider.createSchedule(schedule);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Schedule' : 'New Schedule')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _zone,
              decoration: const InputDecoration(labelText: 'Zone'),
              items: List.generate(4, (i) => i + 1)
                  .map((z) => DropdownMenuItem(value: z, child: Text('Zone $z')))
                  .toList(),
              onChanged: (v) => setState(() => _zone = v ?? _zone),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<WaterSource>(
              initialValue: _source,
              decoration: const InputDecoration(labelText: 'Water Source'),
              items: const [
                DropdownMenuItem(value: WaterSource.borewell, child: Text('Borewell')),
                DropdownMenuItem(value: WaterSource.openWell, child: Text('Open Well')),
              ],
              onChanged: (v) => setState(() => _source = v ?? _source),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Date'),
              subtitle: Text(DateFormatters.date(_date)),
              trailing: const Icon(Icons.calendar_today_outlined),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start Time'),
              subtitle: Text(DateFormatters.timeOfDay(_start)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End Time'),
              subtitle: Text(DateFormatters.timeOfDay(_end)),
              trailing: const Icon(Icons.access_time),
              onTap: () => _pickTime(false),
            ),
            const SizedBox(height: 8),
            Text('Repeat', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('None'),
                  selected: _repeat == ScheduleRepeat.none,
                  onSelected: (_) => setState(() => _repeat = ScheduleRepeat.none),
                ),
                ChoiceChip(
                  label: const Text('Repeat Daily'),
                  selected: _repeat == ScheduleRepeat.daily,
                  onSelected: (_) => setState(() => _repeat = ScheduleRepeat.daily),
                ),
                ChoiceChip(
                  label: const Text('Repeat Weekly'),
                  selected: _repeat == ScheduleRepeat.weekly,
                  onSelected: (_) => setState(() => _repeat = ScheduleRepeat.weekly),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(isEditing ? 'Save Changes' : 'Create Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}
