import '../../domain/entities/automation_rule.dart';
import '../../domain/repositories/automation_repository.dart';

class MockAutomationRepository implements AutomationRepository {
  int _idCounter = 4;

  final List<AutomationRule> _rules = [
    const AutomationRule(
      id: 'r1',
      name: 'Auto Start on Low Moisture',
      conditionType: ConditionType.moistureBelow,
      thresholdValue: 30,
      action: AutomationActionType.startIrrigation,
      enabled: true,
    ),
    const AutomationRule(
      id: 'r2',
      name: 'Skip on Rain Forecast',
      conditionType: ConditionType.rainProbabilityAbove,
      thresholdValue: 70,
      action: AutomationActionType.skipIrrigation,
      enabled: true,
    ),
    const AutomationRule(
      id: 'r3',
      name: 'Stop Pumps on Low Water',
      conditionType: ConditionType.waterLevelBelow,
      thresholdValue: 20,
      action: AutomationActionType.stopPumps,
      enabled: false,
    ),
  ];

  @override
  Future<List<AutomationRule>> getRules() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_rules);
  }

  @override
  Future<AutomationRule> addRule(AutomationRule rule) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final created = AutomationRule(
      id: 'r${_idCounter++}',
      name: rule.name,
      conditionType: rule.conditionType,
      thresholdValue: rule.thresholdValue,
      action: rule.action,
      enabled: rule.enabled,
    );
    _rules.add(created);
    return created;
  }

  @override
  Future<void> setRuleEnabled(String id, bool enabled) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _rules.indexWhere((r) => r.id == id);
    if (idx != -1) {
      _rules[idx] = _rules[idx].copyWith(enabled: enabled);
    }
  }

  @override
  Future<void> deleteRule(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _rules.removeWhere((r) => r.id == id);
  }
}
