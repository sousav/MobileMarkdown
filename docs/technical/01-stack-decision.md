# Technical Stack Decision

> Date: February 2026
> Status: Decided
> Decision: **Flutter** with `markdown_widget` package

---

## Executive Summary

After evaluating six cross-platform approaches (React Native, Flutter, Kotlin Multiplatform + Compose, Native Swift+Kotlin, Capacitor/Ionic, .NET MAUI), **Flutter** is the clear winner for this project. It offers the best combination of development speed (2-3 weeks), bundle size (10-15 MB), markdown rendering quality, and long-term maintainability for a solo developer.

---

## 1. Approaches Evaluated

### Feature Matrix

| Criterion | React Native | Flutter | KMP + Compose | Native (Swift+Kotlin) | Capacitor | .NET MAUI |
|---|---|---|---|---|---|---|
| **Dev Speed (solo)** | Fast (2-3 wk) | Fast (2-3 wk) | Medium (4-6 wk) | Slow (6-8 wk) | Fast (1-2 wk) | Medium (3-4 wk) |
| **Bundle Size** | 15-25 MB | 10-15 MB | 15-20 MB | 5-8 MB | 8-15 MB | 25-35 MB |
| **Large File Perf** | Good | Excellent | Excellent | Best | Poor-Fair | Fair |
| **Native Feel** | Good | Very Good | Very Good | Perfect | Poor-Fair | Fair |
| **MD Rendering Libs** | Very Good | Good-Very Good | Fair | Excellent | Excellent | Poor |
| **File System Access** | Good | Good | Good | Perfect | Good | Good |
| **Share Sheet** | Good (plugins) | Good (plugins) | Manual work | Perfect | Fair | Fair |
| **Maintenance Burden** | Medium | Low | Medium-High | High (2 codebases) | Low | Medium |
| **Community** | Excellent | Excellent | Growing | Mature | Good | Small |
| **Risk Level** | Low-Medium | Low | High | Low tech/High effort | Medium | Very High |

---

## 2. Detailed Analysis

### Flutter (CHOSEN)

**Markdown Libraries:**
- **`markdown_widget`** (405 likes, 7.4K downloads): Code highlighting, dark mode, TOC, custom tags, select/copy, LaTeX. Works on all platforms. MIT licensed. Actively maintained.
- **`flutter_markdown_plus`** (95 likes, 140K downloads): Community continuation of Google's official `flutter_markdown`. CommonMark + GFM. BSD-3 licensed.

**File Handling:**
- `file_picker` - mature cross-platform file selection
- `share_handler` - receive shared files from other apps
- `path_provider` - platform-specific directories

**Performance:** Dart compiles AOT to native ARM. Impeller rendering engine provides native scrolling. `markdown_widget` integrates with ListView for lazy rendering of large documents. Parsing a 1MB file: ~20-50ms.

**Bundle Size:** Minimal Flutter app is 5-8 MB. With all dependencies: **10-15 MB**. Well under 20 MB target.

**Theming:** `ThemeData.light()` / `ThemeData.dark()` with `MarkdownConfig.darkConfig` gives 90% of theming with zero effort.

### React Native (Runner-up)

**Why not chosen:**
- `react-native-markdown-display` is semi-maintained (last release Dec 2023)
- No built-in syntax highlighting for code blocks
- JS bridge becomes bottleneck for large files (thousands of native views = jank)
- Slightly larger bundle size (18-25 MB)

**Would choose if:** Already had a React Native codebase or strong React expertise.

### Kotlin Multiplatform + Compose (Not viable)

**Why not chosen:**
- **No mature markdown rendering library exists.** This is a critical blocker.
- Building a full markdown renderer from scratch would take weeks
- Smaller ecosystem means more DIY for file picking, share handling
- Best suited for teams with existing Kotlin expertise

### Native Swift + Kotlin (Overkill)

**Why not chosen:**
- Two complete codebases to build and maintain
- Double development time (6-8 weeks vs 2-3 weeks)
- Best quality but worst developer efficiency for a solo dev
- Markwon (Android) is stable but unmaintained since Feb 2021

**Would choose if:** This were a commercial product with a team, or single-platform.

### Capacitor / Ionic (Insufficient)

**Why not chosen:**
- WebView performance unacceptable for large files
- Non-native feel (scroll physics, touch feedback differ)
- Receiving share intents is poorly supported

### .NET MAUI (Eliminated)

**Why not chosen:**
- Bundle size 25-35 MB (exceeds 20 MB target)
- No markdown rendering library
- Very small mobile community
- Stability issues reported

---

## 3. Markdown Parsing Libraries Reference

| Library | Language | CommonMark | GFM | Speed | Extensibility |
|---|---|---|---|---|---|
| **markdown-it** | JavaScript | Full | Via plugins | Fast | Excellent |
| **Dart markdown** | Dart | Full | Built-in | Fast (AOT) | Good |
| **commonmark-java** | Java/Kotlin | Full | Extensions | Fast | Good |
| **pulldown-cmark** | Rust | Full | Built-in | Fastest | Limited |
| **marked** | JavaScript | Full | Partial | Fastest JS | Good |
| **Markdig** | C# | Full | Full | Fast | Excellent |

For Flutter, the Dart `markdown` package handles parsing. It's mature, CommonMark-compliant, and GFM-capable out of the box.

---

## 4. Syntax Highlighting

| Library | Platform | Languages Supported | Bundle Impact |
|---|---|---|---|
| **flutter_highlight** | Flutter | 190+ | Moderate |
| **highlight.js** | Web/JS | 190+ | ~70KB core |
| Built into `markdown_widget` | Flutter | Uses flutter_highlight | Included |

`markdown_widget` includes syntax highlighting via `flutter_highlight`, so no additional dependency is needed.

---

## 5. File Handling & Share Sheet Integration

### Registering as .md File Handler

**Android** (`AndroidManifest.xml`):
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <data android:mimeType="text/markdown" />
    <data android:mimeType="text/x-markdown" />
    <data android:pathPattern=".*\\.md" />
    <data android:scheme="content" />
    <data android:scheme="file" />
</intent-filter>
```

**iOS** (`Info.plist`):
```xml
<key>CFBundleDocumentTypes</key>
<array>
    <dict>
        <key>CFBundleTypeName</key>
        <string>Markdown Document</string>
        <key>LSHandlerRank</key>
        <string>Default</string>
        <key>LSItemContentTypes</key>
        <array>
            <string>net.daringfireball.markdown</string>
        </array>
    </dict>
</array>
```

### Receiving from Share Sheet
- Flutter: `share_handler` package handles both Android intents and iOS share extensions
- Requires platform-specific configuration in addition to the Dart package

---

## 6. Decision Summary

| Aspect | Decision | Rationale |
|---|---|---|
| **Framework** | Flutter | Best speed/quality/size balance |
| **Language** | Dart | Single language, AOT compiled |
| **MD Rendering** | `markdown_widget` | Code highlighting + dark mode built-in |
| **MD Parsing** | Dart `markdown` (via markdown_widget) | CommonMark + GFM, AOT performance |
| **File Picking** | `file_picker` | Mature, cross-platform |
| **Share Receiving** | `share_handler` | Handles intents + share extensions |
| **State Management** | `StatefulWidget` / `ValueNotifier` | App too simple for Bloc/Riverpod |
| **Theming** | Material 3 with system dark mode | Built-in, zero overhead |
| **Min Android** | API 21 (Android 5.0) | Flutter default |
| **Min iOS** | iOS 12 | Flutter default |
| **Target Size** | <15 MB | Flutter compiles to native ARM |
