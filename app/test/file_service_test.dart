import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_markdown/services/file_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _recentFilesKey = 'recent_files';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('RecentFile JSON serialization', () {
    test('toJson produces valid JSON', () {
      final file = RecentFile(
        path: '/test/path/file.md',
        name: 'file.md',
        lastOpened: DateTime(2026, 2, 15, 10, 30),
      );

      final jsonMap = file.toJson();

      expect(jsonMap['path'], '/test/path/file.md');
      expect(jsonMap['name'], 'file.md');
      expect(jsonMap['lastOpened'], '2026-02-15T10:30:00.000');
    });

    test('fromJson creates correct RecentFile', () {
      final jsonMap = {
        'path': '/test/path/readme.md',
        'name': 'readme.md',
        'lastOpened': '2026-02-15T10:30:00.000',
      };

      final file = RecentFile.fromJson(jsonMap);

      expect(file.path, '/test/path/readme.md');
      expect(file.name, 'readme.md');
      expect(file.lastOpened, DateTime(2026, 2, 15, 10, 30));
    });

    test('round-trip serialization preserves data', () {
      final original = RecentFile(
        path: '/some/path/document.md',
        name: 'document.md',
        lastOpened: DateTime(2026, 1, 20, 14, 0),
      );

      final jsonString = json.encode(original.toJson());
      final decoded = RecentFile.fromJson(
        json.decode(jsonString) as Map<String, dynamic>,
      );

      expect(decoded.path, original.path);
      expect(decoded.name, original.name);
      expect(decoded.lastOpened, original.lastOpened);
    });
  });

  group('FileService file I/O', () {
    late Directory tempDir;
    late FileService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('mobile_markdown_file_');
      service = FileService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('readFile reads UTF-8 content', () async {
      final file = File('${tempDir.path}/utf8.md');
      await file.writeAsString('# Hello, Markdown!');

      final content = await service.readFile(file.path);

      expect(content, '# Hello, Markdown!');
    });

    test('readFile falls back to Latin-1 when UTF-8 decoding fails', () async {
      final file = File('${tempDir.path}/latin1.md');
      await file.writeAsBytes([0x63, 0x61, 0x66, 0xE9]);

      final content = await service.readFile(file.path);

      expect(content, 'caf\xe9');
    });

    test('readFile throws notFound for missing files', () async {
      expect(
        () => service.readFile('${tempDir.path}/missing.md'),
        throwsA(
          isA<FileServiceException>()
              .having((e) => e.type, 'type', FileServiceError.notFound)
              .having(
                (e) => e.message,
                'message',
                'This file could not be found',
              ),
        ),
      );
    });

    test('getFileSize returns size for existing files', () async {
      final file = File('${tempDir.path}/size.md');
      await file.writeAsString('12345');

      final fileSize = await service.getFileSize(file.path);

      expect(fileSize, 5);
    });

    test('getFileSize returns zero for missing files', () async {
      final fileSize = await service.getFileSize('${tempDir.path}/missing.md');

      expect(fileSize, 0);
    });
  });

  group('FileService recent files persistence', () {
    late Directory tempDir;
    late FileService service;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'mobile_markdown_recents_',
      );
      service = FileService();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    Future<List<Map<String, dynamic>>> loadRawRecentFiles() async {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_recentFilesKey);
      if (raw == null || raw.isEmpty) {
        return [];
      }

      return (json.decode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    }

    test(
      'getRecentFiles removes stale and malformed entries and persists cleanup',
      () async {
        final olderFile = File('${tempDir.path}/older.md');
        final newerFile = File('${tempDir.path}/newer.md');
        await olderFile.writeAsString('older');
        await newerFile.writeAsString('newer');

        SharedPreferences.setMockInitialValues({
          _recentFilesKey: json.encode([
            {
              'path': olderFile.path,
              'name': 'older.md',
              'lastOpened': '2026-01-01T12:00:00.000',
            },
            {
              'path': '${tempDir.path}/missing.md',
              'name': 'missing.md',
              'lastOpened': '2026-01-02T12:00:00.000',
            },
            {'path': newerFile.path, 'name': 'broken.md'},
            {
              'path': newerFile.path,
              'name': 'newer.md',
              'lastOpened': '2026-01-03T12:00:00.000',
            },
          ]),
        });

        final recentFiles = await service.getRecentFiles();
        final savedFiles = await loadRawRecentFiles();

        expect(recentFiles.map((file) => file.name).toList(), [
          'newer.md',
          'older.md',
        ]);
        expect(savedFiles.map((file) => file['name']).toList(), [
          'newer.md',
          'older.md',
        ]);
      },
    );

    test(
      'saveRecentFile deduplicates entries and caps the list at 20',
      () async {
        for (var i = 0; i < 21; i++) {
          await service.saveRecentFile('/file_$i.md', 'file_$i.md');
        }
        await service.saveRecentFile('/file_10.md', 'file_10.md');

        final savedFiles = await loadRawRecentFiles();
        final savedPaths = savedFiles.map((file) => file['path']).toList();

        expect(savedFiles.length, 20);
        expect(savedPaths.first, '/file_10.md');
        expect(savedPaths.where((path) => path == '/file_10.md').length, 1);
        expect(savedPaths.contains('/file_0.md'), isFalse);
      },
    );

    test('removeRecentFile deletes the matching recent file entry', () async {
      await service.saveRecentFile('/keep.md', 'keep.md');
      await service.saveRecentFile('/remove.md', 'remove.md');

      await service.removeRecentFile('/remove.md');

      final savedFiles = await loadRawRecentFiles();

      expect(savedFiles.length, 1);
      expect(savedFiles.single['path'], '/keep.md');
    });
  });

  group('FileServiceException', () {
    test('toString returns message', () {
      final exception = FileServiceException(
        'File not found',
        FileServiceError.notFound,
      );
      expect(exception.toString(), 'File not found');
      expect(exception.type, FileServiceError.notFound);
    });

    test('all error types are distinct', () {
      const types = FileServiceError.values;
      expect(types.length, 5);
      expect(types.contains(FileServiceError.notFound), isTrue);
      expect(types.contains(FileServiceError.permissionDenied), isTrue);
      expect(types.contains(FileServiceError.encodingError), isTrue);
      expect(types.contains(FileServiceError.tooLarge), isTrue);
      expect(types.contains(FileServiceError.unknown), isTrue);
    });
  });
}
