// This is a basic Flutter widget test for the Ruche Connectée app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ruche_connectee/main.dart';

void main() {
  testWidgets('RucheConnecteeApp builds without crashing',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RucheConnecteeApp());

    // Verify that the app builds successfully
    // Since the app uses Firebase and routing, we just check it doesn't crash during build
    expect(find.byType(MaterialApp), findsOneWidget);

    // The app should be able to render without throwing exceptions
    await tester.pump();
  });
}
