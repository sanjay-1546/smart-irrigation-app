import 'package:flutter/material.dart';
import '../../domain/entities/automation_rule.dart';
import '../../domain/repositories/automation_repository.dart';

class AutomationProvider extends ChangeNotifier {
  final AutomationRepository repository;

  AutomationProvider({required this.repository});

  bool isLoading = false;
  List<AutomationRule> rules = [];

  Future<void> load() async {
    isLoading = true;
    notifyListeners();
    rules = await repository.getRules();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addRule(AutomationRule rule) async {
    await repository.addRule(rule);
    await load();
  }

  Future<void> setRuleEnabled(String id, bool enabled) async {
    await repository.setRuleEnabled(id, enabled);
    await load();
  }

  Future<void> deleteRule(String id) async {
    await repository.deleteRule(id);
    await load();
  }
}
