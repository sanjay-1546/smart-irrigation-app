class WeatherData {
  final double temperatureC;
  final double humidityPercent;
  final double rainProbabilityPercent;
  final String condition;

  const WeatherData({
    required this.temperatureC,
    required this.humidityPercent,
    required this.rainProbabilityPercent,
    required this.condition,
  });
}
