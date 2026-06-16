import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/alert_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatters.dart';
import '../../../domain/entities/alert.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_badge.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AlertProvider>().load());
  }

  IconData _iconFor(AlertType type) {
    switch (type) {
      case AlertType.lowMoisture:
        return Icons.water_drop_outlined;
      case AlertType.lowWaterLevel:
        return Icons.opacity_outlined;
      case AlertType.motorFailure:
        return Icons.engineering_outlined;
      case AlertType.sensorFailure:
        return Icons.sensors_off_outlined;
      case AlertType.noWaterFlow:
        return Icons.block_outlined;
      case AlertType.weatherWarning:
        return Icons.cloud_outlined;
    }
  }

  Color _colorFor(AlertSeverity severity) {
    switch (severity) {
      case AlertSeverity.critical:
        return AppColors.critical;
      case AlertSeverity.warning:
        return AppColors.warning;
      case AlertSeverity.info:
        return AppColors.info;
    }
  }

  Future<void> _dismiss(AppAlert alert) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Dismiss Alert',
      message: 'Dismiss "${alert.title}"?',
      confirmText: 'Dismiss',
    );
    if (confirmed && mounted) {
      await context.read<AlertProvider>().dismiss(alert.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Alerts')),
      body: provider.isLoading && provider.alerts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.load,
              child: provider.alerts.isEmpty
                  ? const Center(child: Text('No alerts. Everything looks good!'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.alerts.length,
                      itemBuilder: (context, index) {
                        final alert = provider.alerts[index];
                        final color = _colorFor(alert.severity);
                        return Card(
                          color: alert.read ? null : color.withValues(alpha: 0.06),
                          child: ListTile(
                            onTap: () => context.read<AlertProvider>().markAsRead(alert.id),
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.15),
                              child: Icon(_iconFor(alert.type), color: color),
                            ),
                            title: Text(alert.title,
                                style: TextStyle(
                                    fontWeight:
                                        alert.read ? FontWeight.normal : FontWeight.bold)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(alert.message),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormatters.relative(alert.timestamp),
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                StatusBadge.severity(alert.severity),
                                const SizedBox(height: 2),
                                SizedBox(
                                  height: 28,
                                  width: 28,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(Icons.close, size: 16),
                                    onPressed: () => _dismiss(alert),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
