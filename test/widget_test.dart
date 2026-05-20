
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pandara_health/main.dart';

void main() {
  testWidgets('App should render Pandara Health', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PandaraHealthApp()));

    // Verify that the splash screen text is shown.
    expect(find.text('Pandara Health'), findsOneWidget);
  });
}
