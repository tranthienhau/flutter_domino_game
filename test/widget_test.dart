import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_domino_game/main.dart';

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const CaribbeanDominoApp());
    expect(find.text('Caribbean'), findsOneWidget);
  });
}
