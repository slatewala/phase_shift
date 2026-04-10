import 'package:flutter_test/flutter_test.dart';

import 'package:phase_shift/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PhaseShiftApp());
    await tester.pump();

    // Start screen should show the game title.
    expect(find.text('PHASE\nSHIFT'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);
  });
}
