import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:week11_performance_optimization/core/errors/ai_exceptions.dart';
import 'package:week11_performance_optimization/features/study_ai/data/repositories/gemini_repository.dart';
import 'package:week11_performance_optimization/features/study_ai/domain/entities/chat_message.dart';
import 'package:week11_performance_optimization/features/study_ai/domain/entities/study_persona.dart';

class MockHttpClient extends http.BaseClient {
  int requestCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requestCount++;
    const responseBody =
        '{"candidates":[{"content":{"parts":[{"text":"Jawaban Gemini"}]}}]}';
    return http.StreamedResponse(
      Stream.value(utf8.encode(responseBody)),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

void main() {
  group('StudyPersona Tests', () {
    test('Persona has non-empty label and system instruction', () {
      for (final persona in StudyPersona.values) {
        expect(persona.label.isNotEmpty, true);
        expect(persona.systemInstruction.isNotEmpty, true);
        expect(persona.description.isNotEmpty, true);
      }
    });

    test('Persona system instructions are distinct', () {
      final instructions =
          StudyPersona.values.map((p) => p.systemInstruction).toSet();
      expect(instructions.length, StudyPersona.values.length);
    });

    test('All three personas exist', () {
      expect(StudyPersona.values.length, 3);
      expect(StudyPersona.values.contains(StudyPersona.summarizer), true);
      expect(StudyPersona.values.contains(StudyPersona.quizGenerator), true);
      expect(StudyPersona.values.contains(StudyPersona.socraticTutor), true);
    });
  });

  group('ChatMessage Tests', () {
    test('ChatMessage copyWith works correctly', () {
      final now = DateTime.now();
      final msg = ChatMessage(
        id: '1',
        role: MessageRole.user,
        text: 'Halo',
        timestamp: now,
      );

      final updated = msg.copyWith(
        text: 'Halo Gemini',
        status: MessageStatus.success,
      );

      expect(updated.id, '1');
      expect(updated.role, MessageRole.user);
      expect(updated.text, 'Halo Gemini');
      expect(updated.status, MessageStatus.success);
      expect(updated.errorMessage, null);
    });

    test('ChatMessage has correct default status', () {
      final msg = ChatMessage(
        id: '1',
        role: MessageRole.model,
        text: 'Response',
        timestamp: DateTime.now(),
      );

      expect(msg.status, MessageStatus.success);
    });

    test('ChatMessage can have error status with message', () {
      final msg = ChatMessage(
        id: '1',
        role: MessageRole.model,
        text: 'Failed',
        timestamp: DateTime.now(),
        status: MessageStatus.error,
        errorMessage: 'Network error',
      );

      expect(msg.status, MessageStatus.error);
      expect(msg.errorMessage, 'Network error');
    });
  });

  group('AiExceptions Tests', () {
    test('GeminiException produces valid string output', () {
      const ex = GeminiException('Quota exceeded', statusCode: 429);
      expect(ex.toString(), contains('Quota exceeded'));
      expect(ex.toString(), contains('429'));
    });

    test('ApiKeyMissingException produces user-friendly string', () {
      const ex = ApiKeyMissingException();
      expect(ex.toString(), contains('API Key Gemini belum disetel'));
    });

    test('NetworkAiException contains error message', () {
      const ex = NetworkAiException('Connection timeout');
      expect(ex.toString(), contains('Connection timeout'));
      expect(ex.toString(), contains('Gagal terhubung ke Gemini API'));
    });
  });

  group('Performance & Caching Tests (GeminiRepository)', () {
    test('LRU cache avoids redundant network requests for identical queries',
        () async {
      final mockClient = MockHttpClient();
      final repo = GeminiRepositoryImpl(
        apiKey: 'test-key',
        client: mockClient,
      );

      // Request pertama -> hit API
      final res1 = await repo.generateResponse(
        'Jelaskan OOP',
        [],
        StudyPersona.summarizer,
      );
      expect(res1, 'Jawaban Gemini');
      expect(mockClient.requestCount, 1);
      expect(repo.cacheHitCount, 0);
      expect(repo.cacheSize, 1);

      // Request kedua dengan query dan persona sama -> ambil dari LRU cache
      final res2 = await repo.generateResponse(
        'Jelaskan OOP',
        [],
        StudyPersona.summarizer,
      );
      expect(res2, 'Jawaban Gemini');
      expect(mockClient.requestCount, 1); // Tidak ada HTTP call baru
      expect(repo.cacheHitCount, 1);
    });

    test('LRU cache evicts oldest entry when exceeding maximum capacity (30)',
        () async {
      final mockClient = MockHttpClient();
      final repo = GeminiRepositoryImpl(
        apiKey: 'test-key',
        client: mockClient,
      );

      // Isi cache sebanyak 30 entri
      for (int i = 0; i < 30; i++) {
        await repo.generateResponse(
          'Pertanyaan $i',
          [],
          StudyPersona.summarizer,
        );
      }
      expect(repo.cacheSize, 30);
      expect(mockClient.requestCount, 30);

      // Tambah 1 entri ke-31 -> kapasitas tetap 30 karena oldest di-evict
      await repo.generateResponse(
        'Pertanyaan 30',
        [],
        StudyPersona.summarizer,
      );
      expect(repo.cacheSize, 30);
      expect(mockClient.requestCount, 31);
    });

    test('Memory guard throws exception for queries exceeding 3000 chars',
        () async {
      final mockClient = MockHttpClient();
      final repo = GeminiRepositoryImpl(
        apiKey: 'test-key',
        client: mockClient,
      );

      final massiveText = 'A' * 3001;

      expect(
        () => repo.generateResponse(massiveText, [], StudyPersona.summarizer),
        throwsA(isA<GeminiException>()),
      );
      expect(mockClient.requestCount, 0); // Dihentikan sebelum network call
    });

    test('clearCache resets cache size', () async {
      final mockClient = MockHttpClient();
      final repo = GeminiRepositoryImpl(
        apiKey: 'test-key',
        client: mockClient,
      );

      await repo.generateResponse('Test', [], StudyPersona.summarizer);
      expect(repo.cacheSize, 1);

      repo.clearCache();
      expect(repo.cacheSize, 0);
    });
  });
}
