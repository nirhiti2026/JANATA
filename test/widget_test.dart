import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('App starts and displays login screen', (WidgetTester tester) async {

    await tester.pumpWidget(const JanataApp());

    expect(find.text('JANATA - Civic Engagement Platform'), findsOneWidget);
  });
}
