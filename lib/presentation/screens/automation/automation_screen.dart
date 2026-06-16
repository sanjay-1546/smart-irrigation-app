import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../application/providers/automation_provider.dart';
import '../../../domain/entities/automation_rule.dart';
import '../../widgets/section_card.dart';

class AutomationScreen extends StatefulWidget {
  const AutomationScreen({super.key});

  @override
  State<AutomationScreen> createState() => _AutomationScreenState();
}

class _AutomationScreenState extends State<AutomationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<AutomationProvider>().load());
  }

  Future<void> _showAddRuleDialog() async {
    final nameController = TextEditingController();
    final thresholdController = TextEditingController(text: '30');
    var conditionType = ConditionType.moistureBelow;
    var action = AutomationActionType.startIrrigation;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Add Automation Rule'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Rule Name'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<ConditionType>(
                  initialValue: conditionType,
                  decoration: const InputDecoration(labelText: 'Condition'),
                  items: const [
                    DropdownMenuItem(
                        value: ConditionType.moistureBelow, child: Text('Moisture Below')),
                    DropdownMenuItem(
                        value: ConditionType.rainProbabilityAbove,
                        child: Text('Rain Probability Above')),
                    DropdownMenuItem(
                        value: ConditionType.waterLevelBelow,
                        child: Text('Water Level Below')),
                  ],
                  onChanged: (v) => setStateDialog(() => conditionType = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: thresholdController,
                  decoration: const InputDecoration(labelText: 'Threshold Value (%)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<AutomationActionType>(
                  initialValue: action,
                  decoration: const InputDecoration(labelText: 'Action'),
                  items: const [
                    DropdownMenuItem(
                        value: AutomationActionType.startIrrigation,
                        child: Text('Start Irrigation')),
                    DropdownMenuItem(
                        value: AutomationActionType.skipIrrigation,
                        child: Text('Skip Irrigation')),
                    DropdownMenuItem(
                        value: AutomationActionType.stopPumps, child: Text('Stop Pumps')),
                  ],
                  onChanged: (v) => setStateDialog(() => action = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final threshold = double.tryParse(thresholdController.text) ?? 0;
                final name = nameController.text.trim().isEmpty
                    ? 'Custom Rule'
                    : nameController.text.trim();
                context.read<AutomationProvider>().addRule(AutomationRule(
                      id: '',
                      name: name,
                      conditionType: conditionType,
                      thresholdValue: threshold,
                      action: action,
                      enabled: true,
                    ));
                Navigator.of(context).pop();
              },
              child: const Text('Add Rule'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AutomationProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Automation')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRuleDialog,
        child: const Icon(Icons.add),
      ),
      body: provider.isLoading && provider.rules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SectionCard(
                  title: 'Automation Status',
                  child: Text(
                    '${provider.rules.where((r) => r.enabled).length} of ${provider.rules.length} rules active',
                  ),
                ),
                const SizedBox(height: 8),
                ...provider.rules.map((rule) => Card(
                      child: SwitchListTile(
                        title: Text(rule.name),
                        subtitle: Text(rule.description),
                        value: rule.enabled,
                        onChanged: (value) =>
                            context.read<AutomationProvider>().setRuleEnabled(rule.id, value),
                        secondary: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () => context.read<AutomationProvider>().deleteRule(rule.id),
                        ),
                      ),
                    )),
              ],
            ),
    );
  }
}
