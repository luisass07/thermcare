import 'package:flutter_test/flutter_test.dart';
import 'package:thermcare/main.dart';

void main() {
  testWidgets('smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ThermCareApp());
  });
}
