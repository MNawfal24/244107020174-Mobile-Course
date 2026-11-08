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

  int get cacheHitCount;
  int get cacheSize;
  void clearCache();
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

  static const int _maxCacheSize = 30;
  static const int _maxQueryLength = 3000;
  final Map<String, String> _lruCache = {};
  int _cacheHitCount = 0;

  @override
  int get cacheHitCount => _cacheHitCount;

  @override
  int get cacheSize => _lruCache.length;

  @override
  void clearCache() => _lruCache.clear();

  String _buildCacheKey(String query, StudyPersona persona) {
    return '${persona.name}::${query.trim().toLowerCase()}';
  }

  @override
  Future<String> generateResponse(
    String userQuery,
    List<ChatMessage> history,
    StudyPersona persona,
  ) async {
    // Memory Guard: cegah lonjakan heap akibat payload query terlalu besar
    if (userQuery.length > _maxQueryLength) {
      throw const GeminiException(
        'Panjang teks pertanyaan melebihi batas aman (maks 3000 karakter).',
      );
    }

    // Bounded LRU Cache: periksa cache in-memory untuk pertanyaan identik
    final cacheKey = _buildCacheKey(userQuery, persona);
    if (_lruCache.containsKey(cacheKey)) {
      _cacheHitCount++;
      // Pindahkan entri ke urutan paling baru (LRU refresher)
      final cachedResponse = _lruCache.remove(cacheKey)!;
      _lruCache[cacheKey] = cachedResponse;
      return cachedResponse;
    }

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
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw GeminiException(
          'Gemini API error: ${response.body}',
          statusCode: response.statusCode,
        );
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const GeminiException('Respons kosong dari Gemini API');
      }

      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      final answer = parts[0]['text'] as String? ?? '';

      // Simpan ke LRU Cache jika kapasitas mencukupi
      if (_lruCache.length >= _maxCacheSize) {
        _lruCache.remove(_lruCache.keys.first); // Evict oldest
      }
      _lruCache[cacheKey] = answer;

      return answer;
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
