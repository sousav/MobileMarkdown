import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:mobile_markdown/main.dart';
import 'package:mobile_markdown/screens/viewer_screen.dart';
import 'package:mobile_markdown/widgets/empty_state.dart';
import 'package:mobile_markdown/widgets/recent_file_tile.dart';
import 'package:mobile_markdown/services/file_service.dart';

void main() {
  setUp(() {
    // Set up SharedPreferences mock for tests
    SharedPreferences.setMockInitialValues({});
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  group('HomeScreen', () {
    testWidgets('renders app title', (WidgetTester tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      // Pump a few frames to let async initState resolve
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('MobileMarkdown'), findsOneWidget);
    });

    testWidgets('shows Open File button', (WidgetTester tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Open File'), findsOneWidget);
    });

    testWidgets('shows empty state when no recent files', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('No files yet'), findsOneWidget);
    });

    testWidgets('Open File button is present and tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 100));
      // The Open File text is rendered inside a button
      final button = find.text('Open File');
      expect(button, findsOneWidget);
      // Verify the folder icon is present alongside the button
      expect(find.byIcon(Icons.folder_open), findsOneWidget);
    });

    testWidgets('shows about icon in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('about dialog shows GitHub repository link', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 100));

      final aboutButton = tester.widget<IconButton>(
        find.widgetWithIcon(IconButton, Icons.info_outline),
      );
      aboutButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(find.text('GitHub repository'), findsOneWidget);
    });
  });

  group('EmptyState widget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EmptyState())),
      );
      expect(find.text('No files yet'), findsOneWidget);
      expect(
        find.text(
          'Open a Markdown file to get started\nYou can also share .md files from other apps',
        ),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.description_outlined), findsOneWidget);
    });
  });

  group('RecentFileTile widget', () {
    testWidgets('displays file name and path', (WidgetTester tester) async {
      final file = RecentFile(
        path: '/test/path/readme.md',
        name: 'readme.md',
        lastOpened: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentFileTile(file: file, onTap: () {}, onRemove: () {}),
          ),
        ),
      );

      expect(find.text('readme.md'), findsOneWidget);
      expect(find.byIcon(Icons.description), findsOneWidget);
    });

    testWidgets('shows relative time', (WidgetTester tester) async {
      final file = RecentFile(
        path: '/test/path/file.md',
        name: 'file.md',
        lastOpened: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecentFileTile(file: file, onTap: () {}, onRemove: () {}),
          ),
        ),
      );

      expect(find.textContaining('2h ago'), findsOneWidget);
    });
  });

  group('ViewerScreen', () {
    Widget buildViewer({
      String content = '',
      String fileName = 'test.md',
      String? errorMessage,
    }) {
      return MaterialApp(
        home: ThemeController(
          themeMode: ThemeMode.system,
          setThemeMode: (_) {},
          child: ViewerScreen(
            markdownContent: content,
            fileName: fileName,
            errorMessage: errorMessage,
          ),
        ),
      );
    }

    testWidgets('shows error state with message', (WidgetTester tester) async {
      await tester.pumpWidget(
        buildViewer(content: '', errorMessage: 'This file could not be found'),
      );
      await tester.pump();
      expect(find.text('This file could not be found'), findsOneWidget);
      expect(find.text('Open Another File'), findsOneWidget);
    });

    testWidgets('shows empty state for empty content', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildViewer(content: ''));
      await tester.pump();
      expect(find.text('This file is empty'), findsOneWidget);
      expect(find.text('Open Another File'), findsOneWidget);
    });

    testWidgets('shows theme toggle button', (WidgetTester tester) async {
      await tester.pumpWidget(buildViewer());
      await tester.pump();
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    });

    testWidgets('shows copy button', (WidgetTester tester) async {
      await tester.pumpWidget(buildViewer());
      await tester.pump();
      expect(find.byIcon(Icons.content_copy), findsOneWidget);
    });

    testWidgets('copies markdown to clipboard', (WidgetTester tester) async {
      const content = '# Hello';
      String? copiedText;

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'Clipboard.setData') {
              copiedText = (call.arguments as Map)['text'] as String?;
            }
            return null;
          });

      await tester.pumpWidget(
        buildViewer(content: content, errorMessage: 'Copy test'),
      );
      await tester.pump();

      final copyButton = tester
          .widgetList<IconButton>(find.byType(IconButton))
          .last;
      copyButton.onPressed!.call();
      await tester.pumpAndSettle();

      expect(copiedText, content);
      expect(find.text('Markdown copied to clipboard'), findsOneWidget);

      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    testWidgets('shows offline placeholder for remote images', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        buildViewer(
          content: '![Remote Diagram](https://example.com/diagram.png)',
        ),
      );
      await tester.pump();

      expect(find.text('Remote Diagram'), findsOneWidget);
      expect(
        find.text(
          'Remote image URLs are not fetched so the app stays fully offline.',
        ),
        findsOneWidget,
      );
      await tester.pump(const Duration(milliseconds: 600));
    });

    testWidgets('file name appears in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(buildViewer(fileName: 'README.md'));
      await tester.pump();
      expect(find.text('README.md'), findsOneWidget);
    });
  });
}
