import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/analytics_provider.dart';
import '../../../domain/repositories/analytics_repository.dart';
import '../../widgets/section_card.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AnalyticsProvider>().load());
  }

  String _periodLabel(AnalyticsPeriod p) {
    switch (p) {
      case AnalyticsPeriod.daily:
        return 'Daily';
      case AnalyticsPeriod.weekly:
        return 'Weekly';
      case AnalyticsPeriod.monthly:
        return 'Monthly';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: provider.isLoading && provider.moistureTrend.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<AnalyticsPeriod>(
                  segments: AnalyticsPeriod.values
                      .map((p) => ButtonSegment(value: p, label: Text(_periodLabel(p))))
                      .toList(),
                  selected: {provider.period},
                  onSelectionChanged: (selection) =>
                      provider.setPeriod(selection.first),
                ),
                const SizedBox(height: 16),
                SectionCard(
                  title: 'Moisture Trend',
                  child: SizedBox(
                    height: 220,
                    child: _MoistureTrendChart(provider: provider),
                  ),
                ),
                SectionCard(
                  title: 'Water Usage (Liters)',
                  child: SizedBox(
                    height: 220,
                    child: _WaterUsageBarChart(provider: provider),
                  ),
                ),
                SectionCard(
                  title: 'Pump Runtime (Minutes)',
                  child: SizedBox(
                    height: 220,
                    child: _PumpRuntimeBarChart(provider: provider),
                  ),
                ),
                SectionCard(
                  title: 'Rainfall (mm)',
                  child: SizedBox(
                    height: 220,
                    child: _RainfallLineChart(provider: provider),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MoistureTrendChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _MoistureTrendChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final colors = [Colors.green, Colors.blue, Colors.orange, Colors.purple];
    final lines = <LineChartBarData>[];
    for (var zone = 1; zone <= 4; zone++) {
      final readings = provider.moistureTrend.where((r) => r.zoneNumber == zone).toList();
      final spots = readings
          .asMap()
          .entries
          .map((e) => FlSpot(e.key.toDouble(), e.value.moisturePercent))
          .toList();
      lines.add(LineChartBarData(
        spots: spots,
        isCurved: true,
        color: colors[zone - 1],
        barWidth: 2,
        dotData: const FlDotData(show: false),
      ));
    }
    return LineChart(LineChartData(lineBarsData: lines, titlesData: const FlTitlesData(show: false)));
  }
}

class _WaterUsageBarChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _WaterUsageBarChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final groups = provider.waterUsage.asMap().entries.map((e) {
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: e.value.litersUsed, color: Colors.blue),
      ]);
    }).toList();
    return BarChart(BarChartData(barGroups: groups, titlesData: const FlTitlesData(show: false)));
  }
}

class _PumpRuntimeBarChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _PumpRuntimeBarChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final groups = provider.waterUsage.asMap().entries.map((e) {
      return BarChartGroupData(x: e.key, barRods: [
        BarChartRodData(toY: e.value.pumpRuntimeMinutes, color: Colors.green),
      ]);
    }).toList();
    return BarChart(BarChartData(barGroups: groups, titlesData: const FlTitlesData(show: false)));
  }
}

class _RainfallLineChart extends StatelessWidget {
  final AnalyticsProvider provider;
  const _RainfallLineChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final spots = provider.waterUsage
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.rainfallMm))
        .toList();
    return LineChart(LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.cyan,
          barWidth: 2,
          belowBarData: BarAreaData(show: true, color: Colors.cyan.withValues(alpha: 0.2)),
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
    ));
  }
}
