import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/ai_exceptions.dart';
import '../../../../core/security/secure_storage_service.dart';
import '../../data/repositories/gemini_repository.dart';
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/study_persona.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>(
  (_) => FlutterSecureStorageService(),
);

final apiKeyProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageServiceProvider);
  return storage.readApiKey();
});

final geminiRepositoryProvider = Provider<GeminiRepository?>((ref) {
  final apiKeyAsync = ref.watch(apiKeyProvider);
  return apiKeyAsync.whenData((apiKey) {
    if (apiKey == null || apiKey.isEmpty) return null;
    return GeminiRepositoryImpl(apiKey: apiKey);
  }).value;
});

final selectedPersonaProvider =
    NotifierProvider<SelectedPersonaNotifier, StudyPersona>(
        SelectedPersonaNotifier.new);

class SelectedPersonaNotifier extends Notifier<StudyPersona> {
  @override
  StudyPersona build() => StudyPersona.summarizer;

  void setPersona(StudyPersona persona) => state = persona;
}

final chatNotifierProvider =
    NotifierProvider<ChatNotifier, List<ChatMessage>>(ChatNotifier.new);

final isGeneratingProvider = Provider<bool>((ref) {
  return ref.watch(chatNotifierProvider.select(
    (messages) => messages.any((m) => m.status == MessageStatus.sending),
  ));
});

final cacheMetricsProvider = Provider<({int hitCount, int cacheSize})>((ref) {
  final repo = ref.watch(geminiRepositoryProvider);
  if (repo == null) return (hitCount: 0, cacheSize: 0);
  return (hitCount: repo.cacheHitCount, cacheSize: repo.cacheSize);
});

class ChatNotifier extends Notifier<List<ChatMessage>> {
  @override
  List<ChatMessage> build() => [];

  Future<void> sendMessage(String text) async {
    final repository = ref.read(geminiRepositoryProvider);
    if (repository == null) {
      throw const ApiKeyMissingException();
    }

    final persona = ref.read(selectedPersonaProvider);
    final userMsg = ChatMessage(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.user,
      text: text,
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg];

    final tempId = 'm_${DateTime.now().millisecondsSinceEpoch}';
    final loadingMsg = ChatMessage(
      id: tempId,
      role: MessageRole.model,
      text: '',
      timestamp: DateTime.now(),
      status: MessageStatus.sending,
    );
    state = [...state, loadingMsg];

    try {
      final response = await repository.generateResponse(
        text,
        state.where((m) => m.status == MessageStatus.success).toList(),
        persona,
      );

      state = [
        for (final msg in state)
          if (msg.id != tempId)
            msg
          else
            msg.copyWith(text: response, status: MessageStatus.success),
      ];
    } catch (e) {
      state = [
        for (final msg in state)
          if (msg.id != tempId)
            msg
          else
            msg.copyWith(
              text: 'Error',
              status: MessageStatus.error,
              errorMessage: e.toString(),
            ),
      ];
    }
  }

  void clearHistory() => state = [];
}

class ApiKeyNotifier extends Notifier<AsyncValue<String?>> {
  @override
  AsyncValue<String?> build() {
    return ref.watch(apiKeyProvider);
  }

  Future<void> saveKey(String key) async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageServiceProvider);
    await storage.saveApiKey(key);
    ref.invalidate(apiKeyProvider);
    state = AsyncData(key);
  }

  Future<void> deleteKey() async {
    state = const AsyncLoading();
    final storage = ref.read(secureStorageServiceProvider);
    await storage.clearApiKey();
    ref.invalidate(apiKeyProvider);
    state = const AsyncData(null);
  }
}

final apiKeyNotifierProvider =
    NotifierProvider<ApiKeyNotifier, AsyncValue<String?>>(
  ApiKeyNotifier.new,
);
