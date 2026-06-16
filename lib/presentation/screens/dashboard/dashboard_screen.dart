import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/dashboard_provider.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../domain/entities/pump_status.dart';
import '../../widgets/section_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.load();
      provider.startAutoRefresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 1024 ? 4 : (width >= 600 ? 3 : 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.load,
        child: provider.isLoading && provider.weather == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Welcome, ${user?.name ?? 'User'}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (provider.weather != null) _WeatherCard(weather: provider.weather!),
                  const SizedBox(height: 16),
                  Text('Farm Status', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 1.3,
                    children: [
                      ...provider.pumps.map((p) => _PumpStatusCard(pump: p)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (provider.lastSync != null)
                    SectionCard(
                      child: Row(
                        children: [
                          const Icon(Icons.sync, size: 18),
                          const SizedBox(width: 8),
                          Text('Last sync: ${DateFormatters.relative(provider.lastSync!)}'),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }
}

class _WeatherCard extends StatelessWidget {
  final dynamic weather;

  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Current Weather (${weather.condition})',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _WeatherStat(
            icon: Icons.thermostat,
            label: 'Temp',
            value: '${weather.temperatureC.toStringAsFixed(1)}°C',
          ),
          _WeatherStat(
            icon: Icons.water_drop_outlined,
            label: 'Humidity',
            value: '${weather.humidityPercent.toStringAsFixed(0)}%',
          ),
          _WeatherStat(
            icon: Icons.umbrella_outlined,
            label: 'Rain Chance',
            value: '${weather.rainProbabilityPercent.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _WeatherStat({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _PumpStatusCard extends StatelessWidget {
  final PumpStatus pump;

  const _PumpStatusCard({required this.pump});

  @override
  Widget build(BuildContext context) {
    final isRunning = pump.state == DeviceState.running;
    final color = isRunning ? Colors.green : Colors.grey;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.water_outlined, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(pump.label, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            Text(
              isRunning ? 'Running' : 'Stopped',
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
            Text('Flow: ${pump.flowRateLpm.toStringAsFixed(0)} L/min'),
            Text('Water Level: ${pump.waterLevelPercent.toStringAsFixed(0)}%'),
          ],
        ),
      ),
    );
  }
}
