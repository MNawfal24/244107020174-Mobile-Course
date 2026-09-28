import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'setting_page.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(darkModeProvider).value ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SwitchListTile(
        title: const Text('Mode Gelap'),
        value: isDarkMode,
        onChanged: (_) => ref.read(darkModeProvider.notifier).toggle(),
      ),
    );
  }
}