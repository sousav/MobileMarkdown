import 'dart:async';

import 'package:flutter/services.dart';

import 'file_service.dart';

typedef OpenedFileCallback = void Function(String content, String fileName);

class FileOpenReceiver {
  FileOpenReceiver({FileService? fileService})
    : _fileService = fileService ?? FileService();

  static const MethodChannel _methodChannel = MethodChannel(
    'com.mobilemarkdown/opened_file',
  );
  static const EventChannel _eventChannel = EventChannel(
    'com.mobilemarkdown/opened_file/events',
  );

  final FileService _fileService;
  StreamSubscription<dynamic>? _subscription;
  OpenedFileCallback? _onFileOpened;

  Future<void> init(OpenedFileCallback onFileOpened) async {
    _onFileOpened = onFileOpened;
    _subscription = _eventChannel.receiveBroadcastStream().listen(
      _handleOpenedFileEvent,
    );

    final initialFile = await _methodChannel.invokeMapMethod<String, dynamic>(
      'getInitialOpenedFile',
    );
    if (initialFile != null) {
      await _openFile(initialFile);
    }
  }

  Future<void> _handleOpenedFileEvent(dynamic event) async {
    if (event is Map) {
      await _openFile(Map<String, dynamic>.from(event));
    }
  }

  Future<void> _openFile(Map<String, dynamic> fileData) async {
    final callback = _onFileOpened;
    if (callback == null) {
      return;
    }

    final path = fileData['path'] as String?;
    final fileName = fileData['fileName'] as String?;
    if (path == null || fileName == null) {
      return;
    }

    try {
      await _fileService.persistUriPermission(path);
      final content = await _fileService.readFile(path);
      await _fileService.saveRecentFile(path, fileName);
      callback(content, fileName);
    } catch (_) {
      // Ignore unreadable files launched from external intents.
    }
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onFileOpened = null;
  }
}
