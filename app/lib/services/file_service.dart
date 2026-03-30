import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Maximum number of recent files to store.
const int _maxRecentFiles = 20;

/// Maximum file size before showing a warning (10 MB).
const int maxFileSizeBytes = 10 * 1024 * 1024;

/// SharedPreferences key for recent files.
const String _recentFilesKey = 'recent_files';

const MethodChannel _androidFileChannel = MethodChannel(
  'com.mobilemarkdown/file',
);

/// A recently opened file entry.
class RecentFile {
  final String path;
  final String name;
  final DateTime lastOpened;

  RecentFile({
    required this.path,
    required this.name,
    required this.lastOpened,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'name': name,
    'lastOpened': lastOpened.toIso8601String(),
  };

  factory RecentFile.fromJson(Map<String, dynamic> json) {
    return RecentFile(
      path: json['path'] as String,
      name: json['name'] as String,
      lastOpened: DateTime.parse(json['lastOpened'] as String),
    );
  }
}

/// Typed exception for file operations.
class FileServiceException implements Exception {
  final String message;
  final FileServiceError type;

  FileServiceException(this.message, this.type);

  @override
  String toString() => message;
}

/// Error types for file operations.
enum FileServiceError {
  notFound,
  permissionDenied,
  encodingError,
  tooLarge,
  unknown,
}

class FileService {
  bool _isContentUri(String path) => path.startsWith('content://');

  /// Opens the system file picker filtered to markdown/text files.
  Future<FilePickerResult?> pickFile() async {
    return FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown', 'txt'],
    );
  }

  /// Reads a file as a string with encoding fallback.
  ///
  /// Tries UTF-8 first, then falls back to Latin-1 if a FormatException occurs.
  /// Throws [FileServiceException] for file not found, permission denied,
  /// or encoding failures.
  Future<String> readFile(String path) async {
    if (_isContentUri(path)) {
      final bytes = await _readContentUriBytes(path);
      return _decodeText(bytes);
    }

    final file = File(path);

    if (!await file.exists()) {
      throw FileServiceException(
        'This file could not be found',
        FileServiceError.notFound,
      );
    }

    try {
      final bytes = await file.readAsBytes();

      return _decodeText(bytes);
    } on FileSystemException catch (e) {
      if (e.osError?.errorCode == 13) {
        throw FileServiceException(
          'Permission needed to read this file',
          FileServiceError.permissionDenied,
        );
      }
      throw FileServiceException(
        'This file could not be found',
        FileServiceError.notFound,
      );
    }
  }

  /// Returns the file size in bytes, or 0 if the file doesn't exist.
  Future<int> getFileSize(String path) async {
    if (_isContentUri(path)) {
      final size = await _androidFileChannel.invokeMethod<int>(
        'getContentUriSize',
        {'uri': path},
      );
      return size ?? 0;
    }

    final file = File(path);
    if (await file.exists()) {
      return file.length();
    }
    return 0;
  }

  Future<void> persistUriPermission(String path) async {
    if (!_isContentUri(path)) {
      return;
    }

    try {
      await _androidFileChannel.invokeMethod<void>('persistUriPermission', {
        'uri': path,
      });
    } on PlatformException {
      // Ignore providers that do not expose persistable permissions.
    }
  }

  /// Retrieves the list of recently opened files, sorted by lastOpened descending.
  /// Removes stale entries where the file no longer exists.
  Future<List<RecentFile>> getRecentFiles() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_recentFilesKey);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      final files = <RecentFile>[];

      for (final item in jsonList) {
        try {
          final recentFile = RecentFile.fromJson(item as Map<String, dynamic>);
          if (await pathExists(recentFile.path)) {
            files.add(recentFile);
          }
        } catch (_) {
          // Skip malformed entries
        }
      }

      // Sort by most recent first
      files.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));

      // Persist cleaned list
      await _saveRecentFilesList(prefs, files);

      return files;
    } catch (_) {
      return [];
    }
  }

  /// Adds or updates a file in the recent files list.
  /// Enforces max [_maxRecentFiles] entries with FIFO eviction.
  Future<void> saveRecentFile(String path, String name) async {
    final prefs = await SharedPreferences.getInstance();
    final files = await _loadRecentFilesRaw(prefs);

    // Remove existing entry for same path (deduplication)
    files.removeWhere((f) => f.path == path);

    // Add new entry at front
    files.insert(
      0,
      RecentFile(path: path, name: name, lastOpened: DateTime.now()),
    );

    // Enforce max size
    while (files.length > _maxRecentFiles) {
      files.removeLast();
    }

    await _saveRecentFilesList(prefs, files);
  }

  /// Removes a specific recent file entry.
  Future<void> removeRecentFile(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final files = await _loadRecentFilesRaw(prefs);
    files.removeWhere((f) => f.path == path);
    await _saveRecentFilesList(prefs, files);
  }

  Future<bool> pathExists(String path) async {
    if (_isContentUri(path)) {
      final exists = await _androidFileChannel.invokeMethod<bool>(
        'contentUriExists',
        {'uri': path},
      );
      return exists ?? false;
    }

    return File(path).exists();
  }

  Future<List<int>> _readContentUriBytes(String path) async {
    try {
      await persistUriPermission(path);
      final bytes = await _androidFileChannel.invokeMethod<Uint8List>(
        'readContentUri',
        {'uri': path},
      );
      if (bytes == null) {
        throw FileServiceException(
          'This file could not be found',
          FileServiceError.notFound,
        );
      }
      return bytes;
    } on PlatformException catch (e) {
      if (e.code == 'not_found') {
        throw FileServiceException(
          'This file could not be found',
          FileServiceError.notFound,
        );
      }
      if (e.code == 'permission_denied') {
        throw FileServiceException(
          'Permission needed to read this file',
          FileServiceError.permissionDenied,
        );
      }
      throw FileServiceException(
        "This file couldn't be read. It may not be a text file.",
        FileServiceError.encodingError,
      );
    }
  }

  String _decodeText(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } on FormatException {
      try {
        return latin1.decode(bytes);
      } catch (_) {
        throw FileServiceException(
          "This file couldn't be read. It may not be a text file.",
          FileServiceError.encodingError,
        );
      }
    }
  }

  /// Loads recent files without validation (for internal use).
  Future<List<RecentFile>> _loadRecentFilesRaw(SharedPreferences prefs) async {
    final jsonString = prefs.getString(_recentFilesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => RecentFile.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Persists the recent files list to SharedPreferences.
  Future<void> _saveRecentFilesList(
    SharedPreferences prefs,
    List<RecentFile> files,
  ) async {
    final jsonString = json.encode(files.map((f) => f.toJson()).toList());
    await prefs.setString(_recentFilesKey, jsonString);
  }
}
