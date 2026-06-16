enum ConditionType { moistureBelow, rainProbabilityAbove, waterLevelBelow }

enum AutomationActionType { startIrrigation, skipIrrigation, stopPumps }

class AutomationRule {
  final String id;
  final String name;
  final ConditionType conditionType;
  final double thresholdValue;
  final AutomationActionType action;
  final bool enabled;

  const AutomationRule({
    required this.id,
    required this.name,
    required this.conditionType,
    required this.thresholdValue,
    required this.action,
    required this.enabled,
  });

  String get description {
    final cond = switch (conditionType) {
      ConditionType.moistureBelow => 'Moisture < ${thresholdValue.toStringAsFixed(0)}%',
      ConditionType.rainProbabilityAbove => 'Rain Probability > ${thresholdValue.toStringAsFixed(0)}%',
      ConditionType.waterLevelBelow => 'Water Level < ${thresholdValue.toStringAsFixed(0)}%',
    };
    final act = switch (action) {
      AutomationActionType.startIrrigation => 'Start Irrigation',
      AutomationActionType.skipIrrigation => 'Skip Irrigation',
      AutomationActionType.stopPumps => 'Stop Pumps',
    };
    return 'IF $cond THEN $act';
  }

  AutomationRule copyWith({bool? enabled}) {
    return AutomationRule(
      id: id,
      name: name,
      conditionType: conditionType,
      thresholdValue: thresholdValue,
      action: action,
      enabled: enabled ?? this.enabled,
    );
  }
}
