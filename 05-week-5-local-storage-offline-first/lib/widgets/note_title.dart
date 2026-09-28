import 'package:flutter/material.dart';
import '../data/local/note.dart';

class NoteTile extends StatelessWidget {
  const NoteTile({super.key, required this.note, required this.onDelete});

  final Note note;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(note.title),
      subtitle: Text(
        '${note.body}\nDiperbarui: ${note.updatedAt}',
        style: const TextStyle(fontSize: 12),
      ),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            note.dirty ? Icons.cloud_off : Icons.cloud_done,
            color: note.dirty ? Colors.orange : Colors.green,
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Hapus catatan',
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}