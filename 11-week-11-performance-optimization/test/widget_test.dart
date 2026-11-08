import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week11_performance_optimization/features/study_ai/presentation/pages/study_ai_page.dart';

void main() {
  testWidgets('StudyAiPage renders with ProviderScope and RepaintBoundary',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: StudyAiPage(),
        ),
      ),
    );
    await tester.pump();

    // Verify AppBar title renders
    expect(find.text('NoteMind AI - Tutor Belajar'), findsOneWidget);

    // Verify RepaintBoundary exists for rendering isolation
    expect(find.byType(RepaintBoundary), findsWidgets);
  });
}
