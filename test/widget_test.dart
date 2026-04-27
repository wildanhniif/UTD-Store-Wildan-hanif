import 'package:flutter_test/flutter_test.dart';
import 'package:utd_advanced_app/main.dart';
import 'package:utd_advanced_app/core/di/injection.dart';

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Setup Service Locator manually for test since it's called in real main()
    setupLocator();
    
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MainApp());

    // Wait for everything to settle
    await tester.pumpAndSettle();
  });
}
