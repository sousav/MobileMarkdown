import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile_markdown/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('App launch', () {
    testWidgets('shows HomeScreen with title and Open File button', (
      tester,
    ) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      // App bar title
      expect(find.text('MobileMarkdown'), findsOneWidget);

      // Open File button
      expect(find.text('Open File'), findsOneWidget);
      expect(find.byIcon(Icons.folder_open), findsOneWidget);

      // About button
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows empty state when no files are available', (
      tester,
    ) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Empty state message
      expect(find.text('No files yet'), findsOneWidget);
    });
  });

  group('About dialog', () {
    testWidgets('opens and shows app info', (tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Tap about button
      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pumpAndSettle();

      // About dialog content
      expect(find.text('MobileMarkdown'), findsWidgets);
      expect(find.text('1.0.0'), findsOneWidget);
      expect(find.text('A free, no-ads markdown viewer.'), findsOneWidget);
    });
  });

  group('Theme cycling', () {
    testWidgets('navigates to viewer and cycles theme', (tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to viewer with sample content via route
      final navigatorState = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      navigatorState.pushNamed(
        '/view',
        arguments: {
          'content': '# Hello\n\nThis is a test.',
          'fileName': 'test.md',
        },
      );
      await tester.pumpAndSettle();

      // Verify we're on the viewer screen
      expect(find.text('test.md'), findsOneWidget);

      // Find theme toggle - starts as system (brightness_auto)
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);

      // Tap to cycle: system -> light
      await tester.tap(find.byIcon(Icons.brightness_auto));
      await tester.pump();
      expect(find.byIcon(Icons.light_mode), findsOneWidget);

      // Tap to cycle: light -> dark
      await tester.tap(find.byIcon(Icons.light_mode));
      await tester.pump();
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);

      // Tap to cycle: dark -> system
      await tester.tap(find.byIcon(Icons.dark_mode));
      await tester.pump();
      expect(find.byIcon(Icons.brightness_auto), findsOneWidget);
    });
  });

  group('Viewer screen', () {
    testWidgets('renders markdown content', (tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      final navigatorState = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      navigatorState.pushNamed(
        '/view',
        arguments: {
          'content':
              '# Test Heading\n\nSome paragraph text.\n\n- Item 1\n- Item 2',
          'fileName': 'sample.md',
        },
      );
      await tester.pumpAndSettle();

      // File name in app bar
      expect(find.text('sample.md'), findsOneWidget);

      // Rendered heading
      expect(find.text('Test Heading'), findsOneWidget);

      // Copy button present
      expect(find.byIcon(Icons.content_copy), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      final navigatorState = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      navigatorState.pushNamed(
        '/view',
        arguments: {
          'content': '',
          'fileName': 'error.md',
          'errorMessage': 'File not found',
        },
      );
      await tester.pumpAndSettle();

      // Error message displayed
      expect(find.text('File not found'), findsOneWidget);

      // Open Another File button
      expect(find.text('Open Another File'), findsOneWidget);
    });

    testWidgets('navigates back from viewer to home', (tester) async {
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to viewer
      final navigatorState = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      navigatorState.pushNamed(
        '/view',
        arguments: {'content': '# Back Test', 'fileName': 'back.md'},
      );
      await tester.pumpAndSettle();

      expect(find.text('back.md'), findsOneWidget);

      // Press back via app bar back button
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      // Should be back on home screen
      expect(find.text('MobileMarkdown'), findsOneWidget);
      expect(find.text('Open File'), findsOneWidget);
    });
  });

  group('Theme persistence', () {
    testWidgets('persists theme preference across app restarts', (
      tester,
    ) async {
      // First launch - set theme to light
      await tester.pumpWidget(const MobileMarkdownApp());
      await tester.pump(const Duration(milliseconds: 500));

      // Navigate to viewer to access theme toggle
      final navigatorState = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      navigatorState.pushNamed(
        '/view',
        arguments: {'content': '# Persistence Test', 'fileName': 'persist.md'},
      );
      await tester.pumpAndSettle();

      // Cycle system -> light
      await tester.tap(find.byIcon(Icons.brightness_auto));
      await tester.pump(const Duration(milliseconds: 100));

      // Verify light mode is set
      expect(find.byIcon(Icons.light_mode), findsOneWidget);

      // Wait for SharedPreferences to persist
      await tester.pump(const Duration(milliseconds: 500));

      // Verify preference was saved
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('theme_mode'), 'light');
    });
  });
}
