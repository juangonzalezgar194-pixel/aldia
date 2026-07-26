import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aldia/main.dart';

void main() {
  testWidgets('AlDia app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AlDiaApp());

    // Aquí puedes agregar tus propias verificaciones según las pantallas
    // reales de AlDía. Por ejemplo, si tu primera pantalla es un login:
    // expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}