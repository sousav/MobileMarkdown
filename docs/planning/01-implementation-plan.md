# Implementation Plan & Roadmap

> Date: February 2026
> Framework: Flutter
> Estimated Timeline: 15 working days (3 weeks)

---

## Phase 0: Project Setup (Day 1)

### Tasks
- [ ] Create Flutter project: `flutter create --org com.mobilemarkdown mobile_markdown`
- [ ] Configure `pubspec.yaml` with all dependencies
- [ ] Set up project structure (screens/, services/, widgets/, theme/)
- [ ] Configure linting rules (`analysis_options.yaml`)
- [ ] Initialize git repository with `.gitignore`
- [ ] Set up basic CI (GitHub Actions: `flutter analyze` + `flutter test`)
- [ ] Create app icon (simple, clean MD logo)

### Deliverables
- Runnable Flutter project skeleton
- CI pipeline running on push

---

## Phase 1: Core Viewer (Days 2-4)

### Tasks
- [ ] Implement `app_theme.dart` with Material 3 light/dark themes
- [ ] Implement `markdown_theme.dart` with `MarkdownConfig` for both modes
- [ ] Build `ViewerScreen` with `MarkdownWidget`
- [ ] Wire up system theme detection (`ThemeMode.system`)
- [ ] Add manual theme toggle (light/dark/system)
- [ ] Test rendering with sample markdown files covering:
  - Headings (h1-h6)
  - Bold, italic, strikethrough
  - Ordered and unordered lists
  - Nested lists
  - Code blocks (with syntax highlighting)
  - Inline code
  - Tables (GFM)
  - Checkboxes (GFM)
  - Images (local and remote)
  - Links (tappable, opens browser)
  - Blockquotes
  - Horizontal rules
  - HTML (graceful degradation)
- [ ] Handle large file rendering (test with 1MB+ markdown)
- [ ] Add scroll-to-top FAB

### Deliverables
- Viewer screen that beautifully renders any markdown string
- Light and dark theme support
- Performant rendering of large files

---

## Phase 2: File Handling (Days 5-7)

### Tasks
- [ ] Implement `FileService.pickFile()` using `file_picker`
  - Filter: `.md`, `.markdown`, `.txt`
  - Handle permission denials gracefully
- [ ] Implement `FileService.readFile(path)` with encoding detection
  - UTF-8 primary, fallback to Latin-1
  - Handle read errors (file not found, permission denied, too large)
- [ ] Implement recent files storage using `SharedPreferences`
  - Store last 20 files (path, name, timestamp)
  - FIFO eviction when list exceeds 20
  - Validate paths on load (remove stale entries)
- [ ] Build `HomeScreen` with:
  - "Open File" button (prominent, centered)
  - Recent files list (below button)
  - Empty state when no recent files
- [ ] Wire up navigation: HomeScreen -> pick file -> ViewerScreen
- [ ] Handle file open errors with user-friendly messages

### Deliverables
- Users can pick and view .md files from the filesystem
- Recent files list persists across app launches

---

## Phase 3: Share Sheet & Intent Handling (Days 8-10)

### Tasks
- [ ] Configure Android `AndroidManifest.xml` with intent filters for:
  - `ACTION_VIEW` with `text/markdown` and `text/x-markdown` MIME types
  - `ACTION_VIEW` with `.md` and `.markdown` file extension patterns
  - `ACTION_SEND` for receiving shared text/files
- [ ] Configure iOS `Info.plist` with:
  - `CFBundleDocumentTypes` for markdown files
  - `UTImportedTypeDeclarations` for `net.daringfireball.markdown`
- [ ] Implement `ShareReceiver` service using `share_handler`
  - Handle cold launch with shared file (app was not running)
  - Handle warm launch with shared file (app in background)
  - Handle shared plain text (render as markdown)
- [ ] Test on physical devices:
  - Android: Tap .md file in Files app -> opens in our app
  - Android: Share .md from another app -> opens in our app
  - iOS: Tap .md in Files app -> opens in our app
  - iOS: Share .md from another app -> opens in our app
- [ ] Handle edge cases:
  - File is not valid UTF-8
  - File is not actually markdown (just plain text - still render)
  - File is very large (>5MB - show warning)
  - File path is temporary (copy to app cache if needed)

### Deliverables
- App registers as .md file handler on both platforms
- Users can open .md files from any app via share sheet
- Tapping .md files in file managers opens our app

---

## Phase 4: Polish & UX (Days 11-12)

### Tasks
- [ ] Design and implement app icon
  - Simple, recognizable, works at small sizes
  - Light and dark variants for adaptive icons (Android)
- [ ] Implement splash screen (brief, matching theme)
- [ ] Add "About" dialog/screen
  - App version
  - Open source license
  - Link to GitHub repo
- [ ] Implement link handling in rendered markdown
  - Tapping links opens default browser via `url_launcher`
  - Long-press to copy link
- [ ] Add "Share" action in ViewerScreen AppBar
  - Share the source .md file to other apps
- [ ] Add "Open in" action (open same file in another app)
- [ ] Handle orientation changes gracefully
- [ ] Handle text scaling / accessibility settings
- [ ] Add haptic feedback on file selection
- [ ] Error states:
  - File not found -> friendly message + "Open another file" button
  - Encoding error -> friendly message
  - Empty file -> "This file is empty" state
- [ ] Loading state for large files (show spinner)
- [ ] Test with system font size: small, default, large, largest
- [ ] Test with TalkBack (Android) and VoiceOver (iOS)

### Deliverables
- Polished, accessible, production-ready UI
- All error states handled gracefully
- Accessibility compliance

---

## Phase 5: Testing & Quality (Day 13)

### Tasks
- [ ] Unit tests:
  - `FileService` - file reading, recent files management, encoding handling
  - `ShareReceiver` - intent parsing
- [ ] Widget tests:
  - `HomeScreen` - empty state, recent files display, button interactions
  - `ViewerScreen` - markdown rendering, loading state, error state
- [ ] Integration tests:
  - Full flow: launch -> pick file -> view -> back -> recent files updated
- [ ] Manual testing matrix:

| Device | OS Version | Test |
|---|---|---|
| Android phone | Latest | All flows |
| Android phone | API 21 | Basic flows |
| Android tablet | Latest | Layout |
| iPhone | Latest iOS | All flows |
| iPhone | iOS 12 | Basic flows |
| iPad | Latest | Layout |

- [ ] Performance testing:
  - Small file (<10KB): instant render
  - Medium file (100KB): <500ms render
  - Large file (1MB+): <2s render, smooth scrolling
- [ ] Test markdown spec compliance against CommonMark spec examples

### Deliverables
- Test coverage for critical paths
- Verified on target device matrix
- Performance benchmarks documented

---

## Phase 6: Store Submission (Days 14-15)

### Tasks
- [ ] Prepare store assets:
  - App icon (512x512 for Play Store, 1024x1024 for App Store)
  - Feature graphic (Play Store, 1024x500)
  - Screenshots: phone (6.5") and tablet (12.9") for both platforms
  - Short description (80 chars): "Open and view markdown files beautifully"
  - Full description (4000 chars): feature list, no hype
- [ ] Configure app signing:
  - Android: Generate upload keystore, configure Gradle
  - iOS: Configure provisioning profiles, certificates
- [ ] Build release:
  - `flutter build appbundle` (Android)
  - `flutter build ipa` (iOS)
- [ ] Submit to stores:
  - Google Play Console: Create listing, upload AAB, submit for review
  - App Store Connect: Create listing, upload IPA, submit for review
- [ ] Prepare GitHub release:
  - Clean up repo
  - Write README with screenshots
  - Add LICENSE (MIT or Apache-2.0)
  - Tag v1.0.0

### Deliverables
- App submitted to both stores
- GitHub repository public with v1.0.0 tag

---

## Post-Launch (Ongoing)

### Week 1 After Launch
- [ ] Monitor crash reports (Firebase Crashlytics or Play Console)
- [ ] Respond to initial reviews
- [ ] Fix any critical bugs

### Monthly
- [ ] Check for Flutter SDK updates
- [ ] Check for dependency updates
- [ ] Address store review feedback
- [ ] Estimated effort: 2-4 hours/month

---

## Future Versions (v1.x - only if demand warrants)

These features are explicitly OUT OF SCOPE for v1.0 but could be added later:

| Feature | Priority | Effort |
|---|---|---|
| Search within document | Medium | 1-2 days |
| Table of contents sidebar | Medium | 1-2 days |
| Custom themes (font, colors) | Low | 2-3 days |
| Export to PDF | Low | 2-3 days |
| Folder browsing (open directory of .md files) | Medium | 3-4 days |
| Mermaid diagram rendering | Low | 2-3 days |
| LaTeX math rendering | Low | 1-2 days (markdown_widget supports it) |
| Tablet split-view (file list + viewer) | Low | 2-3 days |
| Widget for home screen (recent files) | Very Low | 3-4 days |

**Rule: No feature gets added unless users ask for it.** The app's identity is simplicity. Every feature must earn its place.

---

## Timeline Summary

```
Week 1:  [Setup] [====Core Viewer====] [====File Handling====]
Week 2:  [====Share Sheet/Intents====] [=====Polish/UX=====]
Week 3:  [Testing] [==Store Submission==] [Launch]
```

**Total: 15 working days / 3 calendar weeks**
