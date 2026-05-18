// Basic smoke test — Firebase is initialized only in lib/main.dart.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Material smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('db_notes')),
        ),
      ),
    );

    expect(find.text('db_notes'), findsOneWidget);
  });
}
