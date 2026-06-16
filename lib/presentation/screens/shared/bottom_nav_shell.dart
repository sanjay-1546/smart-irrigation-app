import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../domain/entities/user.dart';
import '../alerts/alerts_screen.dart';
import '../analytics/analytics_screen.dart';
import '../automation/automation_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../farm_layout/farm_layout_screen.dart';
import '../irrigation/irrigation_control_screen.dart';
import '../monitoring/live_monitoring_screen.dart';
import '../schedule/schedule_list_screen.dart';
import '../settings/settings_screen.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget Function() builder;
  final List<UserRole> roles;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.builder,
    required this.roles,
  });
}

final List<_NavItem> _allNavItems = [
  _NavItem(
    label: 'Dashboard',
    icon: Icons.dashboard_outlined,
    builder: () => const DashboardScreen(),
    roles: [UserRole.admin, UserRole.farmer, UserRole.technician],
  ),
  _NavItem(
    label: 'Monitoring',
    icon: Icons.sensors_outlined,
    builder: () => const LiveMonitoringScreen(),
    roles: [UserRole.admin, UserRole.farmer, UserRole.technician],
  ),
  _NavItem(
    label: 'Control',
    icon: Icons.power_settings_new_outlined,
    builder: () => const IrrigationControlScreen(),
    roles: [UserRole.admin, UserRole.farmer],
  ),
  _NavItem(
    label: 'Schedule',
    icon: Icons.calendar_month_outlined,
    builder: () => const ScheduleListScreen(),
    roles: [UserRole.admin, UserRole.farmer],
  ),
  _NavItem(
    label: 'Alerts',
    icon: Icons.notifications_outlined,
    builder: () => const AlertsScreen(),
    roles: [UserRole.admin, UserRole.farmer, UserRole.technician],
  ),
  _NavItem(
    label: 'Analytics',
    icon: Icons.bar_chart_outlined,
    builder: () => const AnalyticsScreen(),
    roles: [UserRole.admin, UserRole.farmer],
  ),
  _NavItem(
    label: 'Farm Layout',
    icon: Icons.map_outlined,
    builder: () => const FarmLayoutScreen(),
    roles: [UserRole.admin, UserRole.farmer],
  ),
  _NavItem(
    label: 'Automation',
    icon: Icons.auto_mode_outlined,
    builder: () => const AutomationScreen(),
    roles: [UserRole.admin],
  ),
  _NavItem(
    label: 'Settings',
    icon: Icons.settings_outlined,
    builder: () => const SettingsScreen(),
    roles: [UserRole.admin, UserRole.farmer, UserRole.technician],
  ),
];

class BottomNavShell extends StatefulWidget {
  const BottomNavShell({super.key});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final role = user?.role ?? UserRole.farmer;
    final items = _allNavItems.where((item) => item.roles.contains(role)).toList();
    if (_index >= items.length) _index = 0;

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 600;

    final body = IndexedStack(
      index: _index,
      children: items.map((item) => item.builder()).toList(),
    );

    if (isWide) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              labelType: NavigationRailLabelType.all,
              leading: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.eco, size: 32),
              ),
              destinations: items
                  .map((item) => NavigationRailDestination(
                        icon: Icon(item.icon),
                        label: Text(item.label),
                      ))
                  .toList(),
            ),
            const VerticalDivider(width: 1),
            Expanded(child: body),
          ],
        ),
      );
    }

    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: items
            .map((item) => NavigationDestination(icon: Icon(item.icon), label: item.label))
            .toList(),
      ),
    );
  }
}
