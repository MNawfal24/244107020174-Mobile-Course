// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

//import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_navigation/main.dart';

void main() {
  testWidgets('Aplikasi dapat dimuat tanpa crash', (WidgetTester tester) async {
    // Memompa aplikasi kita yang sudah dibungkus ProviderScope Riverpod
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Memastikan kerangka dasar aplikasi berhasil dirender
    expect(find.byType(MyApp), findsOneWidget);
  });
}
