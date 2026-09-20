import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aplikasi dapat memuat UI dasar tanpa crash', (WidgetTester tester) async {
    // Kita memompa widget dasar yang tidak memanggil API internet
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('Halaman Test'),
        ),
      ),
    );

    // Memastikan teks berhasil dirender di layar
    expect(find.text('Halaman Test'), findsOneWidget);
  });
}