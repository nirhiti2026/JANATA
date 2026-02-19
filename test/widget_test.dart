// Widget tests for the JANATA app
//
// Run tests with: flutter test

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/app.dart';

void main() {
  testWidgets('App starts and displays login screen', (WidgetTester tester) async {
    // Build the JanataApp and trigger a frame
    await tester.pumpWidget(const JanataApp());

    // Verify app title is set correctly
    expect(find.text('JANATA - Civic Engagement Platform'), findsOneWidget);
  });
}
