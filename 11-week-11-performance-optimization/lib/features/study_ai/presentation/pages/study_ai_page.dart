import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../../../../core/errors/ai_exceptions.dart';
import '../../domain/entities/study_persona.dart';
import '../../domain/entities/chat_message.dart';

class StudyAiPage extends ConsumerStatefulWidget {
  const StudyAiPage({super.key});

  @override
  ConsumerState<StudyAiPage> createState() => _StudyAiPageState();
}

class _StudyAiPageState extends ConsumerState<StudyAiPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();

    try {
      ref.read(chatNotifierProvider.notifier).sendMessage(text);
      _scrollToBottom();
    } catch (e) {
      if (e is ApiKeyMissingException) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              action: SnackBarAction(
                label: 'Atur',
                onPressed: _showApiKeySetup,
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _showApiKeySetup() {
    final keyController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Atur API Key Gemini'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dapatkan API key gratis dari: https://aistudio.google.com',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Paste API key di sini',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final key = keyController.text.trim();
              if (key.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API key tidak boleh kosong')),
                );
                return;
              }
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              await ref
                  .read(apiKeyNotifierProvider.notifier)
                  .saveKey(key);
              navigator.pop();
              scaffoldMessenger.showSnackBar(
                const SnackBar(content: Text('API key berhasil disimpan')),
              );
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _handleClearChat() {
    ref.read(chatNotifierProvider.notifier).clearHistory();
  }

  @override
  Widget build(BuildContext context) {
    // Root build hanya memantau status apiKeyProvider
    final apiKey = ref.watch(apiKeyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteMind AI - Tutor Belajar'),
        actions: [
          // Optimasi 1: RepaintBoundary & Consumer isolatif untuk Persona Selector
          const RepaintBoundary(
            child: _PersonaDropdownButton(),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus riwayat',
            onPressed: _handleClearChat,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Pengaturan API Key',
            onPressed: _showApiKeySetup,
          ),
        ],
      ),
      body: apiKey.when(
        data: (key) {
          if (key == null || key.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('API Key belum diatur'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _showApiKeySetup,
                    child: const Text('Atur API Key'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Optimasi 2: Info bar diisolasi dengan Consumer & RepaintBoundary
              const RepaintBoundary(
                child: _PersonaInfoBar(),
              ),
              // Optimasi 3: List message diisolasi dengan Consumer khusus
              Expanded(
                child: _ChatMessageList(scrollController: _scrollController),
              ),
              // Optimasi 4: Input bar diisolasi dengan Consumer & RepaintBoundary
              RepaintBoundary(
                child: _ChatInputBar(
                  inputController: _inputController,
                  onSend: _sendMessage,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

/// Widget isolatif untuk Persona Dropdown di AppBar
class _PersonaDropdownButton extends ConsumerWidget {
  const _PersonaDropdownButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPersona = ref.watch(selectedPersonaProvider);

    return PopupMenuButton<StudyPersona>(
      initialValue: selectedPersona,
      onSelected: (persona) {
        ref.read(selectedPersonaProvider.notifier).setPersona(persona);
      },
      itemBuilder: (ctx) => [
        for (final p in StudyPersona.values)
          PopupMenuItem(
            value: p,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.label,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  p.description,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Widget isolatif untuk Banner Info Persona Belajar
class _PersonaInfoBar extends ConsumerWidget {
  const _PersonaInfoBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPersona = ref.watch(selectedPersonaProvider);
    final metrics = ref.watch(cacheMetricsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.blue.shade50,
      child: Row(
        children: [
          const Icon(Icons.school_outlined, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${selectedPersona.label} • Private On-Device Caching',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
          if (metrics.hitCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '⚡ Cache Hit: ${metrics.hitCount}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget listview pesan yang hanya me-rebuild saat daftar pesan berubah
class _ChatMessageList extends ConsumerWidget {
  const _ChatMessageList({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fine-grained selector: hanya listen list messages
    final messages = ref.watch(chatNotifierProvider);

    if (messages.isEmpty) {
      return const _EmptyChatPlaceholder();
    }

    return ListView.builder(
      controller: scrollController,
      addRepaintBoundaries: true,
      itemCount: messages.length,
      itemBuilder: (ctx, idx) {
        // Setiap gelembung chat diisolasi dalam RepaintBoundary
        return RepaintBoundary(
          child: _ChatMessageBubble(message: messages[idx]),
        );
      },
    );
  }
}

/// Placeholder konstan saat pesan masih kosong
class _EmptyChatPlaceholder extends StatelessWidget {
  const _EmptyChatPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Mulai percakapan belajar',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

/// Widget gelembung chat terpisah dengan static styling
class _ChatMessageBubble extends StatelessWidget {
  const _ChatMessageBubble({required this.message});

  final ChatMessage message;

  static final _userDecoration = BoxDecoration(
    color: Colors.blue.shade500,
    borderRadius: BorderRadius.circular(12),
  );

  static final _modelDecoration = BoxDecoration(
    color: Colors.grey.shade200,
    borderRadius: BorderRadius.circular(12),
  );

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == MessageRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: isUser ? _userDecoration : _modelDecoration,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: message.status == MessageStatus.sending
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : message.status == MessageStatus.error
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '❌ Terjadi kesalahan',
                              style: TextStyle(color: Colors.red),
                            ),
                            if (message.errorMessage != null)
                              Text(
                                message.errorMessage!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        )
                      : Text(
                          message.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                          ),
                        ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Input bar yang hanya me-rebuild saat status pengiriman berubah
class _ChatInputBar extends ConsumerWidget {
  const _ChatInputBar({
    required this.inputController,
    required this.onSend,
  });

  final TextEditingController inputController;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Hanya pantau isGenerating status
    final isGenerating = ref.watch(isGeneratingProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: inputController,
              enabled: !isGenerating,
              minLines: 1,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: isGenerating
                    ? 'AI sedang berpikir...'
                    : 'Tanya sesuatu tentang pelajaran...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) {
                if (!isGenerating) onSend();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            icon: isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.send),
            onPressed: isGenerating ? null : onSend,
          ),
        ],
      ),
    );
  }
}
