import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/errors/ai_exceptions.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/study_persona.dart';

abstract class GeminiRepository {
  Future<String> generateResponse(
    String userQuery,
    List<ChatMessage> history,
    StudyPersona persona,
  );
}

class GeminiRepositoryImpl implements GeminiRepository {
  GeminiRepositoryImpl({
    required this._apiKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String _apiKey;
  final http.Client _client;
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent';

  @override
  Future<String> generateResponse(
    String userQuery,
    List<ChatMessage> history,
    StudyPersona persona,
  ) async {
    try {
      final contents = _buildContents(userQuery, history);
      final body = jsonEncode({
        'system_instruction': {
          'parts': [
            {'text': persona.systemInstruction}
          ]
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'maxOutputTokens': 500,
          'topP': 0.95,
        },
      });

      final response = await _client
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw GeminiException(
          'Gemini API error: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw GeminiException('Respons kosong dari Gemini API');
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      return parts[0]['text'] ?? '';
    } on GeminiException {
      rethrow;
    } catch (e) {
      throw NetworkAiException(e.toString());
    }
  }

  List<Map<String, dynamic>> _buildContents(
    String userQuery,
    List<ChatMessage> history,
  ) {
    final contents = <Map<String, dynamic>>[];

    for (final msg in history) {
      contents.add({
        'role': msg.role == MessageRole.user ? 'user' : 'model',
        'parts': [{'text': msg.text}]
      });
    }

    contents.add({
      'role': 'user',
      'parts': [{'text': userQuery}]
    });

    return contents;
  }
}
