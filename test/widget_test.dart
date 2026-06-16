import 'package:flutter_test/flutter_test.dart';

import 'package:smart_irrigation/main.dart';

void main() {
  testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartFarmApp());
    await tester.pump();

    expect(find.text('Smart Farm Irrigation'), findsOneWidget);
  });
}
