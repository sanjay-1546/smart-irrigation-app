class WaterUsagePoint {
  final DateTime date;
  final double litersUsed;
  final double pumpRuntimeMinutes;
  final double rainfallMm;

  const WaterUsagePoint({
    required this.date,
    required this.litersUsed,
    required this.pumpRuntimeMinutes,
    required this.rainfallMm,
  });
}
