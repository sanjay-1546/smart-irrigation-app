import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/irrigation_control_provider.dart';
import '../../widgets/gauge_widget.dart';
import '../../widgets/status_badge.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key});

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<IrrigationControlProvider>();
      provider.load();
      provider.startAutoRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IrrigationControlProvider>();
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1024 ? 4 : (width >= 600 ? 2 : 1);

    return Scaffold(
      appBar: AppBar(title: const Text('Live Monitoring')),
      body: provider.isLoading && provider.zones.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.load,
              child: GridView.count(
                padding: const EdgeInsets.all(16),
                crossAxisCount: columns,
                childAspectRatio: 1.1,
                children: provider.zones.map((zone) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GaugeWidget(percent: zone.moisturePercent, label: zone.name),
                          const SizedBox(height: 12),
                          StatusBadge.moisture(zone.level),
                          const SizedBox(height: 4),
                          Text(
                            zone.state.name == 'running' ? 'Irrigating' : 'Idle',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}
