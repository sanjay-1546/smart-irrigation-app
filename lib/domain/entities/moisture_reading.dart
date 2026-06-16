class MoistureReading {
  final DateTime timestamp;
  final int zoneNumber;
  final double moisturePercent;

  const MoistureReading({
    required this.timestamp,
    required this.zoneNumber,
    required this.moisturePercent,
  });
}
