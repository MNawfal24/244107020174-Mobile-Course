import 'package:flutter_test/flutter_test.dart';
import 'package:week10_ai_assistant/core/errors/ai_exceptions.dart';
import 'package:week10_ai_assistant/features/study_ai/domain/entities/chat_message.dart';
import 'package:week10_ai_assistant/features/study_ai/domain/entities/study_persona.dart';

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
      final instructions = StudyPersona.values.map((p) => p.systemInstruction).toSet();
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
}
