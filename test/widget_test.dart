import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primexkey/core/app.dart';

void main() {
  testWidgets('App should render without errors', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: PrimeXKeyApp(),
      ),
    );

    // Basic smoke test
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
