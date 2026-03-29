import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_markdown/services/file_service.dart';
import 'package:mobile_markdown/services/share_receiver.dart';
import 'package:share_handler/share_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFileService extends FileService {
  FakeFileService({Map<String, String>? files, Set<String>? unreadablePaths})
    : files = files ?? <String, String>{},
      unreadablePaths = unreadablePaths ?? <String>{};

  final Map<String, String> files;
  final Set<String> unreadablePaths;
  final List<String> savedPaths = <String>[];
  final List<String> savedNames = <String>[];

  @override
  Future<String> readFile(String path) async {
    if (unreadablePaths.contains(path) || !files.containsKey(path)) {
      throw FileServiceException('Unreadable', FileServiceError.notFound);
    }

    return files[path]!;
  }

  @override
  Future<void> saveRecentFile(String path, String name) async {
    savedPaths.add(path);
    savedNames.add(name);
  }
}

class FakeShareHandlerPlatform extends ShareHandlerPlatform {
  FakeShareHandlerPlatform({this.initialMedia});

  SharedMedia? initialMedia;
  bool resetCalled = false;
  final StreamController<SharedMedia> _controller =
      StreamController<SharedMedia>.broadcast();

  @override
  Future<SharedMedia?> getInitialSharedMedia() async => initialMedia;

  @override
  Future<void> resetInitialSharedMedia() async {
    resetCalled = true;
    initialMedia = null;
  }

  @override
  Stream<SharedMedia> get sharedMediaStream => _controller.stream;

  void emit(SharedMedia media) {
    _controller.add(media);
  }

  Future<void> close() async {
    await _controller.close();
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ShareReceiver', () {
    test(
      'handles initial shared attachment and resets the initial media',
      () async {
        final fileService = FakeFileService(
          files: {'/shared/readme.md': '# Shared content'},
        );
        final platform = FakeShareHandlerPlatform(
          initialMedia: SharedMedia(
            attachments: [
              SharedAttachment(
                path: '/shared/readme.md',
                type: SharedAttachmentType.file,
              ),
            ],
          ),
        );
        final receiver = ShareReceiver(
          fileService: fileService,
          platform: platform,
        );

        String? receivedContent;
        String? receivedFileName;

        await receiver.init((content, fileName) {
          receivedContent = content;
          receivedFileName = fileName;
        });

        expect(receivedContent, '# Shared content');
        expect(receivedFileName, 'readme.md');
        expect(fileService.savedPaths, ['/shared/readme.md']);
        expect(fileService.savedNames, ['readme.md']);
        expect(platform.resetCalled, isTrue);

        receiver.dispose();
        await platform.close();
      },
    );

    test('uses the first valid attachment from warm share events', () async {
      final fileService = FakeFileService(
        files: {'/shared/good.md': '## From stream'},
        unreadablePaths: {'/shared/bad.md'},
      );
      final platform = FakeShareHandlerPlatform();
      final receiver = ShareReceiver(
        fileService: fileService,
        platform: platform,
      );

      String? receivedContent;
      String? receivedFileName;

      await receiver.init((content, fileName) {
        receivedContent = content;
        receivedFileName = fileName;
      });

      platform.emit(
        SharedMedia(
          attachments: [
            SharedAttachment(
              path: '/shared/bad.md',
              type: SharedAttachmentType.file,
            ),
            null,
            SharedAttachment(
              path: '/shared/good.md',
              type: SharedAttachmentType.file,
            ),
          ],
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(receivedContent, '## From stream');
      expect(receivedFileName, 'good.md');
      expect(fileService.savedPaths, ['/shared/good.md']);

      receiver.dispose();
      await platform.close();
    });

    test('falls back to shared text when attachments cannot be read', () async {
      final fileService = FakeFileService(unreadablePaths: {'/shared/bad.md'});
      final platform = FakeShareHandlerPlatform();
      final receiver = ShareReceiver(
        fileService: fileService,
        platform: platform,
      );

      String? receivedContent;
      String? receivedFileName;

      await receiver.init((content, fileName) {
        receivedContent = content;
        receivedFileName = fileName;
      });

      platform.emit(
        SharedMedia(
          attachments: [
            SharedAttachment(
              path: '/shared/bad.md',
              type: SharedAttachmentType.file,
            ),
          ],
          content: '**Shared text**',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(receivedContent, '**Shared text**');
      expect(receivedFileName, 'Shared Text');
      expect(fileService.savedPaths, isEmpty);

      receiver.dispose();
      await platform.close();
    });
  });
}
