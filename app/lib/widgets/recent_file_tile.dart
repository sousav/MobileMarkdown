import 'package:flutter/material.dart';
import '../services/file_service.dart';

class RecentFileTile extends StatelessWidget {
  final RecentFile file;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const RecentFileTile({
    super.key,
    required this.file,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(file.path),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: Theme.of(context).colorScheme.error,
        child: Icon(
          Icons.delete,
          color: Theme.of(context).colorScheme.onError,
          semanticLabel: 'Remove from recents',
        ),
      ),
      onDismissed: (_) => onRemove(),
      child: ListTile(
        leading: Icon(
          Icons.description,
          color: Theme.of(context).colorScheme.primary,
          semanticLabel: 'Markdown file',
        ),
        title: Text(file.name, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          '${_truncatePath(file.path)} \u00B7 ${_relativeTime(file.lastOpened)}',
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: onTap,
      ),
    );
  }

  String _truncatePath(String path) {
    if (path.length <= 40) return path;
    // Show last segment of the directory
    final parts = path.split('/');
    if (parts.length <= 3) return path;
    return '.../${parts.sublist(parts.length - 3).join('/')}';
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}
