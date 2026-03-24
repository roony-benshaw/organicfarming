import 'package:flutter_test/flutter_test.dart';
import 'package:organic_farming_app/main.dart';

void main() {
  testWidgets('Splash navigates to auth screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const OrganicFarmingApp());

    expect(find.text('Grow Naturally'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Welcome Farmer'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });
}
