import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders a simple smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Skill Circle'),
          ),
        ),
      ),
    );

    expect(find.text('Skill Circle'), findsOneWidget);
  });
}
