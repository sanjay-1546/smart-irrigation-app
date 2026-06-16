import '../entities/automation_rule.dart';

abstract class AutomationRepository {
  Future<List<AutomationRule>> getRules();
  Future<AutomationRule> addRule(AutomationRule rule);
  Future<void> setRuleEnabled(String id, bool enabled);
  Future<void> deleteRule(String id);
}
