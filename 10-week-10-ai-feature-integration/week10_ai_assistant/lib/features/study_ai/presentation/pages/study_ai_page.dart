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
                onPressed: () => _showApiKeySetup(),
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

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatNotifierProvider);
    final apiKey = ref.watch(apiKeyProvider);
    final selectedPersona = ref.watch(selectedPersonaProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('NoteMind AI - Tutor Belajar'),
        actions: [
          PopupMenuButton<StudyPersona>(
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
                      Text(p.label, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        p.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Hapus riwayat',
            onPressed: () {
              ref.read(chatNotifierProvider.notifier).clearHistory();
            },
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
              Container(
                padding: const EdgeInsets.all(12),
                color: Colors.blue.shade50,
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${selectedPersona.label} • Data tidak disimpan di server',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
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
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: messages.length,
                        itemBuilder: (ctx, idx) {
                          final msg = messages[idx];
                          final isUser = msg.role == MessageRole.user;

                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: isUser
                                    ? CrossAxisAlignment.end
                                    : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isUser
                                          ? Colors.blue.shade500
                                          : Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: msg.status == MessageStatus.sending
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : msg.status == MessageStatus.error
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    '❌ Terjadi kesalahan',
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                  if (msg.errorMessage != null)
                                                    Text(
                                                      msg.errorMessage!,
                                                      style: const TextStyle(
                                                        fontSize: 11,
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                ],
                                              )
                                            : Text(
                                                msg.text,
                                                style: TextStyle(
                                                  color: isUser
                                                      ? Colors.white
                                                      : Colors.black87,
                                                ),
                                              ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      _formatTime(msg.timestamp),
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
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        minLines: 1,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Tanya sesuatu tentang pelajaran...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.send),
                      onPressed: _sendMessage,
                    ),
                  ],
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    if (dt.day == now.day &&
        dt.month == now.month &&
        dt.year == now.year) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}';
  }
}
