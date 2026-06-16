import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/auth_provider.dart';
import '../../../application/providers/farm_layout_provider.dart';
import '../../../application/providers/settings_provider.dart';
import '../../../application/providers/theme_provider.dart';
import '../../../domain/entities/user.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/section_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _weatherKeyController;
  late TextEditingController _farmNameController;
  late TextEditingController _farmLocationController;

  @override
  void initState() {
    super.initState();
    _weatherKeyController = TextEditingController();
    _farmNameController = TextEditingController();
    _farmLocationController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = context.read<SettingsProvider>();
      await settings.load();
      if (!mounted) return;
      _weatherKeyController.text = settings.weatherApiKey ?? '';
      final farm = context.read<FarmLayoutProvider>().farm;
      _farmNameController.text = farm.name;
      _farmLocationController.text = farm.location;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _weatherKeyController.dispose();
    _farmNameController.dispose();
    _farmLocationController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      isDestructive: true,
    );
    if (confirmed && mounted) {
      await context.read<AuthProvider>().logout();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final farmProvider = context.watch<FarmLayoutProvider>();
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: 'Profile',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Name: ${user?.name ?? '-'}'),
                Text('Role: ${user?.role.label ?? '-'}'),
                Text('Email: ${user?.email ?? '-'}'),
                const SizedBox(height: 12),
                FilledButton.tonalIcon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Farm Information',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _farmNameController,
                  decoration: const InputDecoration(labelText: 'Farm Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _farmLocationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => farmProvider.updateFarm(farmProvider.farm.copyWith(
                    name: _farmNameController.text,
                    location: _farmLocationController.text,
                  )),
                  child: const Text('Save Farm Info'),
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Weather API Settings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _weatherKeyController,
                  decoration: const InputDecoration(labelText: 'OpenWeatherMap API Key'),
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => settings.saveWeatherApiKey(_weatherKeyController.text),
                  child: const Text('Save API Key'),
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Threshold Settings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Moisture Threshold: ${settings.moistureThreshold.toStringAsFixed(0)}%'),
                Slider(
                  value: settings.moistureThreshold,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${settings.moistureThreshold.toStringAsFixed(0)}%',
                  onChanged: settings.setMoistureThreshold,
                ),
                Text('Water Level Threshold: ${settings.waterLevelThreshold.toStringAsFixed(0)}%'),
                Slider(
                  value: settings.waterLevelThreshold,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: '${settings.waterLevelThreshold.toStringAsFixed(0)}%',
                  onChanged: settings.setWaterLevelThreshold,
                ),
              ],
            ),
          ),
          SectionCard(
            title: 'Theme',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Dark Mode'),
              value: themeProvider.isDark,
              onChanged: themeProvider.toggleDarkMode,
            ),
          ),
          SectionCard(
            title: 'Offline Mode (Demo)',
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use cached data instead of live data'),
              value: settings.offlineMode,
              onChanged: settings.setOfflineMode,
            ),
          ),
        ],
      ),
    );
  }
}
