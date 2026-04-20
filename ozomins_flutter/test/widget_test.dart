import 'package:flutter_test/flutter_test.dart';
import 'package:ozomins_flutter/main.dart';

void main() {
  testWidgets('Ozomins app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OzominsApp());
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Splash screen should render the app name
    expect(find.text('Ozomins'), findsOneWidget);
  });
}
