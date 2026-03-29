# Application Architecture

> Date: February 2026
> Framework: Flutter
> Pattern: Simple layered architecture (no over-engineering)

---

## 1. Architecture Overview

```
+-----------------------------------------------+
|                  App Shell                      |
|  MaterialApp                                    |
|  ├── ThemeData (light/dark, system-aware)       |
|  ├── Route: / -> HomeScreen                     |
|  └── Route: /view -> ViewerScreen               |
+-----------------------------------------------+
|                   Screens                        |
|  ┌─────────────────┐  ┌──────────────────────┐  |
|  │   HomeScreen     │  │   ViewerScreen       │  |
|  │                  │  │                      │  |
|  │  - Empty state   │  │  - AppBar (filename) │  |
|  │  - Open button   │  │  - Share action      │  |
|  │  - Recent files  │  │  - MarkdownWidget()  │  |
|  │  - About/info    │  │  - Scroll to top FAB │  |
|  └─────────────────┘  └──────────────────────┘  |
+-----------------------------------------------+
|                  Services                        |
|  ┌──────────────────────────────────────────┐   |
|  │  FileService                             │   |
|  │  ├── pickFile() -> File                  │   |
|  │  ├── readFile(path) -> String            │   |
|  │  ├── getRecentFiles() -> List<RecentFile> │   |
|  │  └── saveRecentFile(path, name)          │   |
|  ├──────────────────────────────────────────┤   |
|  │  ShareReceiver                           │   |
|  │  ├── listenForSharedFiles()              │   |
|  │  └── handleIncomingFile(path) -> String  │   |
|  ├──────────────────────────────────────────┤   |
|  │  ThemeService                            │   |
|  │  ├── getThemeMode() -> ThemeMode         │   |
|  │  └── toggleTheme()                       │   |
|  └──────────────────────────────────────────┘   |
+-----------------------------------------------+
|             Platform Configuration              |
|  ├── AndroidManifest.xml (intent-filter .md)    |
|  └── Info.plist (UTType, Document Types)        |
+-----------------------------------------------+
```

---

## 2. Screen Flow

```
App Launch
    │
    ├── Launched normally ──────────────> HomeScreen
    │                                      │
    │                                      ├── Tap "Open File" ──> file_picker ──> ViewerScreen
    │                                      │
    │                                      └── Tap recent file ──> read file ──> ViewerScreen
    │
    ├── Launched via share sheet ────────> Read shared file ──> ViewerScreen
    │
    └── Launched via file tap (.md) ────> Read intent file ──> ViewerScreen
```

---

## 3. Data Model

```dart
// Minimal data model - no database, just shared_preferences for recents

class RecentFile {
  final String path;
  final String name;
  final DateTime lastOpened;
}

// Stored as JSON list in SharedPreferences
// Max 20 recent files, FIFO eviction
```

---

## 4. State Management

The app has exactly two states per screen:

**HomeScreen:**
- `List<RecentFile> recentFiles` (loaded from SharedPreferences on init)

**ViewerScreen:**
- `String? markdownContent` (null = loading, non-null = display)
- `String? errorMessage` (null = no error)
- `String fileName` (displayed in AppBar)

This is trivially managed with `StatefulWidget` and `setState`. No Bloc, no Riverpod, no Provider. The app is too simple to justify a state management library.

---

## 5. Key Implementation Details

### Markdown Rendering

```dart
// Using markdown_widget package
MarkdownWidget(
  data: markdownContent,
  config: isDarkMode
    ? MarkdownConfig.darkConfig
    : MarkdownConfig.defaultConfig,
  // Custom configs for code blocks, links, images
)
```

### File Picking

```dart
// Using file_picker package
final result = await FilePicker.platform.pickFiles(
  type: FileType.custom,
  allowedExtensions: ['md', 'markdown', 'txt'],
);
if (result != null) {
  final file = File(result.files.single.path!);
  final content = await file.readAsString();
  // Navigate to ViewerScreen with content
}
```

### Share Sheet Reception

```dart
// Using share_handler package
// In main.dart or HomeScreen initState
ShareHandlerPlatform.instance.getInitialSharedMedia().then((media) {
  if (media?.attachments != null) {
    // Handle incoming .md file
  }
});
ShareHandlerPlatform.instance.sharedMediaStream.listen((media) {
  // Handle incoming .md file while app is running
});
```

### Theme Switching

```dart
MaterialApp(
  themeMode: ThemeMode.system, // Follow system by default
  theme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.light,
  ),
  darkTheme: ThemeData(
    useMaterial3: true,
    colorSchemeSeed: Colors.blue,
    brightness: Brightness.dark,
  ),
)
```

---

## 6. File Type Registration

### Android (`android/app/src/main/AndroidManifest.xml`)

Add intent filters to the main activity:

```xml
<!-- Open .md and .markdown files from file managers -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="content" />
    <data android:scheme="file" />
    <data android:mimeType="text/markdown" />
    <data android:mimeType="text/x-markdown" />
</intent-filter>

<!-- Catch .md and .markdown extensions even with generic MIME -->
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:scheme="content" />
    <data android:scheme="file" />
    <data android:mimeType="*/*" />
    <data android:pathPattern=".*\\.md" />
    <data android:pathPattern=".*\\.markdown" />
</intent-filter>

<!-- Receive shared text/files -->
<intent-filter>
    <action android:name="android.intent.action.SEND" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/*" />
</intent-filter>
```

### iOS (`ios/Runner/Info.plist`)

```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>Markdown</string>
        <key>CFBundleTypeRole</key>
        <string>Viewer</string>
        <key>LSHandlerRank</key>
        <string>Alternate</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>net.daringfireball.markdown</string>
            <string>public.plain-text</string>
        </array>
    </dict>
</array>

<key>UTImportedTypeDeclarations</key>
<array>
    <dict>
        <key>UTTypeIdentifier</key>
        <string>net.daringfireball.markdown</string>
        <key>UTTypeConformsTo</key>
        <array>
            <string>public.plain-text</string>
        </array>
        <key>UTTypeDescription</key>
        <string>Markdown Document</string>
        <key>UTTypeTagSpecification</key>
        <dict>
            <key>public.filename-extension</key>
            <array>
                <string>md</string>
                <string>markdown</string>
            </array>
            <key>public.mime-type</key>
            <array>
                <string>text/markdown</string>
                <string>text/x-markdown</string>
            </array>
        </dict>
    </dict>
</array>
```

---

## 7. Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  markdown_widget: ^2.3.2      # Markdown rendering with syntax highlighting
  file_picker: ^8.0.0           # Cross-platform file selection
  share_handler: ^0.0.21        # Receive files from share sheet
  path_provider: ^2.1.0         # Platform directories
  url_launcher: ^6.2.0          # Open links from markdown
  shared_preferences: ^2.2.0    # Store recent files list

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

Total direct dependencies: **6** (minimal)

---

## 8. Project Structure

```
lib/
  main.dart                     # App entry, MaterialApp, theme, routing
  screens/
    home_screen.dart            # File picker, recent files, empty state
    viewer_screen.dart          # Markdown rendering, AppBar, actions
  services/
    file_service.dart           # File picking, reading, recent files
    share_receiver.dart         # Share sheet / intent handling
  widgets/
    empty_state.dart            # "Open a markdown file" prompt
    recent_file_tile.dart       # List tile for recent files
  theme/
    app_theme.dart              # ThemeData definitions
    markdown_theme.dart         # MarkdownConfig for light/dark

android/
  app/src/main/AndroidManifest.xml  # Intent filters for .md files

ios/
  Runner/Info.plist                  # UTType declarations for .md files

test/
  file_service_test.dart
  widget_test.dart
```

---

## 9. What This Architecture Explicitly Does NOT Include

| Feature | Why excluded |
|---|---|
| Database (SQLite, Hive) | SharedPreferences suffices for 20 recent files |
| State management library | Two screens, two states. setState is fine. |
| Dependency injection | No complex dependency graph |
| Network layer | No backend, no API calls |
| Authentication | No user accounts |
| Analytics | No tracking, respects privacy |
| Ads SDK | Free, no ads |
| In-app purchases | Free, no upsells |
| Cloud sync | Out of scope; local-only viewer |
| Editing capability | This is a VIEWER, not an editor |

The simplicity is the product. Every feature not included is a deliberate decision.
