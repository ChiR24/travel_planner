import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:travel_planner_2/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('verify app initialization', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app starts successfully
      expect(find.text('Travel Planner'), findsOneWidget);
    });
  });
}
