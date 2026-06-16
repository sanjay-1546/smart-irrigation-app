import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/farm_layout_provider.dart';
import '../../../application/providers/irrigation_control_provider.dart';
import '../../../domain/entities/pump_status.dart';
import '../../widgets/section_card.dart';
import '../irrigation/irrigation_control_screen.dart';

class FarmLayoutScreen extends StatefulWidget {
  const FarmLayoutScreen({super.key});

  @override
  State<FarmLayoutScreen> createState() => _FarmLayoutScreenState();
}

class _FarmLayoutScreenState extends State<FarmLayoutScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmLayoutProvider>().load();
      context.read<IrrigationControlProvider>().load();
    });
  }

  Color _statusColor(DeviceState state, {double? moisture}) {
    if (moisture != null) {
      if (moisture < 25) return Colors.red;
      if (moisture < 45) return Colors.orange;
      return Colors.green;
    }
    switch (state) {
      case DeviceState.running:
        return Colors.green;
      case DeviceState.stopped:
        return Colors.grey;
      case DeviceState.fault:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmLayoutProvider>().farm;
    final irrigation = context.watch<IrrigationControlProvider>();
    final width = MediaQuery.of(context).size.width;
    final columns = width >= 900 ? 3 : 2;

    return Scaffold(
      appBar: AppBar(title: const Text('Farm Layout')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionCard(
            title: farm.name,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Location: ${farm.location}'),
                Text('Size: ${farm.sizeAcres} acres'),
                Text('Owner: ${farm.ownerName}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: columns,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.3,
            children: [
              ...irrigation.pumps.map((p) => _LayoutBox(
                    label: p.label,
                    icon: Icons.water_outlined,
                    color: _statusColor(p.state),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const IrrigationControlScreen()),
                    ),
                  )),
              ...irrigation.zones.map((z) => _LayoutBox(
                    label: z.name,
                    icon: Icons.grass_outlined,
                    color: _statusColor(z.state, moisture: z.moisturePercent),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const IrrigationControlScreen()),
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

class _LayoutBox extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _LayoutBox({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
