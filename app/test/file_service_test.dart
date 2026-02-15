import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_markdown/services/file_service.dart';

void main() {
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

  group('RecentFile list serialization', () {
    test('serializes and deserializes a list of files', () {
      final files = [
        RecentFile(
          path: '/a.md',
          name: 'a.md',
          lastOpened: DateTime(2026, 2, 15),
        ),
        RecentFile(
          path: '/b.md',
          name: 'b.md',
          lastOpened: DateTime(2026, 2, 14),
        ),
        RecentFile(
          path: '/c.md',
          name: 'c.md',
          lastOpened: DateTime(2026, 2, 13),
        ),
      ];

      final jsonString = json.encode(files.map((f) => f.toJson()).toList());
      final decoded = (json.decode(jsonString) as List)
          .map((item) => RecentFile.fromJson(item as Map<String, dynamic>))
          .toList();

      expect(decoded.length, 3);
      expect(decoded[0].name, 'a.md');
      expect(decoded[1].name, 'b.md');
      expect(decoded[2].name, 'c.md');
    });

    test('FIFO eviction logic: list limited to 20 entries', () {
      // Simulate adding 25 files
      final files = List.generate(
        25,
        (i) => RecentFile(
          path: '/file_$i.md',
          name: 'file_$i.md',
          lastOpened: DateTime(2026, 1, 1).add(Duration(hours: i)),
        ),
      );

      // Simulate the eviction: keep only the last 20
      final evicted = files.toList();
      while (evicted.length > 20) {
        evicted.removeLast();
      }

      expect(evicted.length, 20);
      // The oldest files (file_20 through file_24 would be at the end,
      // but we remove from the end so file_20-24 are removed)
      expect(evicted.first.name, 'file_0.md');
      expect(evicted.last.name, 'file_19.md');
    });

    test('deduplication: adding same path replaces existing entry', () {
      final files = <RecentFile>[
        RecentFile(
          path: '/test.md',
          name: 'test.md',
          lastOpened: DateTime(2026, 2, 10),
        ),
        RecentFile(
          path: '/other.md',
          name: 'other.md',
          lastOpened: DateTime(2026, 2, 9),
        ),
      ];

      // Simulate adding /test.md again (newer timestamp)
      final newFile = RecentFile(
        path: '/test.md',
        name: 'test.md',
        lastOpened: DateTime(2026, 2, 15),
      );

      files.removeWhere((f) => f.path == newFile.path);
      files.insert(0, newFile);

      expect(files.length, 2);
      expect(files[0].path, '/test.md');
      expect(files[0].lastOpened, DateTime(2026, 2, 15));
      expect(files[1].path, '/other.md');
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
