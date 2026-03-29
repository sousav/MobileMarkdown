import 'dart:async';

import 'package:share_handler/share_handler.dart';

import 'file_service.dart';

/// Callback for when a shared file is received.
typedef SharedFileCallback = void Function(String content, String fileName);

class ShareReceiver {
  ShareReceiver({FileService? fileService, ShareHandlerPlatform? platform})
    : _fileService = fileService ?? FileService(),
      _platform = platform ?? ShareHandlerPlatform.instance;

  final FileService _fileService;
  final ShareHandlerPlatform _platform;
  StreamSubscription<SharedMedia>? _subscription;
  SharedFileCallback? _onFileReceived;

  /// Initialize share receiver and listen for incoming files.
  ///
  /// [onFileReceived] is called with the file content and name when
  /// a file arrives via share sheet or intent.
  Future<void> init(SharedFileCallback onFileReceived) async {
    _onFileReceived = onFileReceived;

    _subscription = _platform.sharedMediaStream.listen(_handleSharedMedia);

    // Handle cold start: check for initial shared media
    await _handleInitialMedia();
  }

  Future<void> _handleInitialMedia() async {
    try {
      final media = await _platform.getInitialSharedMedia();
      if (media != null) {
        await _handleSharedMedia(media);
        // Reset to prevent duplicate handling
        await _platform.resetInitialSharedMedia();
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
