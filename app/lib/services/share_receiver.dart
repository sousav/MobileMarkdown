import 'dart:async';

import 'package:share_handler/share_handler.dart';
import 'file_service.dart';

/// Callback for when a shared file is received.
typedef SharedFileCallback = void Function(String content, String fileName);

class ShareReceiver {
  final FileService _fileService = FileService();
  StreamSubscription<SharedMedia>? _subscription;
  SharedFileCallback? _onFileReceived;

  /// Initialize share receiver and listen for incoming files.
  ///
  /// [onFileReceived] is called with the file content and name when
  /// a file arrives via share sheet or intent.
  void init(SharedFileCallback onFileReceived) {
    _onFileReceived = onFileReceived;

    // Handle cold start: check for initial shared media
    _handleInitialMedia();

    // Handle warm resume: listen for incoming shares while running
    _subscription = ShareHandlerPlatform.instance.sharedMediaStream.listen(
      _handleSharedMedia,
    );
  }

  Future<void> _handleInitialMedia() async {
    try {
      final media = await ShareHandlerPlatform.instance.getInitialSharedMedia();
      if (media != null) {
        await _handleSharedMedia(media);
        // Reset to prevent duplicate handling
        await ShareHandlerPlatform.instance.resetInitialSharedMedia();
      }
    } catch (_) {
      // Platform not available or no initial media — silently ignore
    }
  }

  Future<void> _handleSharedMedia(SharedMedia media) async {
    final callback = _onFileReceived;
    if (callback == null) return;

    // Try file attachments first
    final attachments = media.attachments;
    if (attachments != null && attachments.isNotEmpty) {
      for (final attachment in attachments) {
        if (attachment == null) continue;
        final path = attachment.path;
        try {
          final content = await _fileService.readFile(path);
          final fileName = path.split('/').last;
          await _fileService.saveRecentFile(path, fileName);
          callback(content, fileName);
          return; // Handle first valid file only
        } catch (_) {
          // Skip unreadable attachments
        }
      }
    }

    // Fall back to shared text content (treat as markdown)
    final textContent = media.content;
    if (textContent != null && textContent.isNotEmpty) {
      callback(textContent, 'Shared Text');
    }
  }

  /// Clean up resources.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onFileReceived = null;
  }
}
