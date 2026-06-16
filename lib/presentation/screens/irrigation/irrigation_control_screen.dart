import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/irrigation_control_provider.dart';
import '../../../domain/entities/pump_status.dart';
import '../../../domain/entities/zone_status.dart';
import '../../widgets/confirm_dialog.dart';

class IrrigationControlScreen extends StatefulWidget {
  const IrrigationControlScreen({super.key});

  @override
  State<IrrigationControlScreen> createState() => _IrrigationControlScreenState();
}

class _IrrigationControlScreenState extends State<IrrigationControlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<IrrigationControlProvider>().load());
  }

  Future<void> _togglePump(PumpStatus pump) async {
    final provider = context.read<IrrigationControlProvider>();
    final turningOn = pump.state != DeviceState.running;
    final confirmed = await showConfirmDialog(
      context,
      title: turningOn ? 'Start ${pump.label}?' : 'Stop ${pump.label}?',
      message: turningOn
          ? 'This will start the ${pump.label} immediately.'
          : 'This will stop the ${pump.label} immediately.',
      confirmText: turningOn ? 'Start' : 'Stop',
    );
    if (confirmed) {
      await provider.setPumpState(
        pump.type,
        turningOn ? DeviceState.running : DeviceState.stopped,
      );
    }
  }

  Future<void> _toggleZone(ZoneStatus zone) async {
    final provider = context.read<IrrigationControlProvider>();
    final turningOn = zone.state != DeviceState.running;
    final confirmed = await showConfirmDialog(
      context,
      title: turningOn ? 'Start ${zone.name}?' : 'Stop ${zone.name}?',
      message: turningOn
          ? 'This will start irrigation for ${zone.name}.'
          : 'This will stop irrigation for ${zone.name}.',
      confirmText: turningOn ? 'Start' : 'Stop',
    );
    if (confirmed) {
      await provider.setZoneState(
        zone.zoneNumber,
        turningOn ? DeviceState.running : DeviceState.stopped,
      );
    }
  }

  Future<void> _emergencyStop() async {
    final provider = context.read<IrrigationControlProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Emergency Stop',
      message: 'This will immediately stop all pumps and zones. Continue?',
      confirmText: 'Stop Everything',
      isDestructive: true,
    );
    if (confirmed) {
      await provider.emergencyStopAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All pumps and zones have been stopped.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IrrigationControlProvider>();
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1024 ? 3 : (width >= 600 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Irrigation Control')),
      body: provider.isLoading && provider.zones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('Pumps', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: provider.pumps
                      .map((p) => _ControlCard(
                            title: p.label,
                            subtitle: 'Flow: ${p.flowRateLpm.toStringAsFixed(0)} L/min',
                            isRunning: p.state == DeviceState.running,
                            onToggle: () => _togglePump(p),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                Text('Zones', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                GridView.count(
                  crossAxisCount: columns,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 2.2,
                  children: provider.zones
                      .map((z) => _ControlCard(
                            title: z.name,
                            subtitle: 'Moisture: ${z.moisturePercent.toStringAsFixed(0)}%',
                            isRunning: z.state == DeviceState.running,
                            onToggle: () => _toggleZone(z),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _emergencyStop,
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('EMERGENCY STOP'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ControlCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isRunning;
  final VoidCallback onToggle;

  const _ControlCard({
    required this.title,
    required this.subtitle,
    required this.isRunning,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    isRunning ? 'Running' : 'Stopped',
                    style: TextStyle(
                      color: isRunning ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isRunning ? Colors.red.shade600 : Colors.green.shade600,
              ),
              onPressed: onToggle,
              child: Text(isRunning ? 'Stop' : 'Start'),
            ),
          ],
        ),
      ),
    );
  }
}
