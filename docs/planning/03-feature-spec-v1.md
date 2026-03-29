# Feature Specification - v1.0

> Date: February 2026
> Scope: Minimum Lovable Product (MLP)
> Principle: Do one thing perfectly

---

## Core Philosophy

This app is a **viewer**, not an editor. It does for `.md` files what a PDF reader does for PDFs: open them, render them beautifully, and get out of the way. Every feature must serve this purpose. If a feature doesn't help users read markdown better, it doesn't belong in v1.

---

## Feature: Open Markdown Files

### From File Picker
- User taps "Open File" on home screen
- System file picker appears, filtered to `.md`, `.markdown`, `.txt` files
- User selects a file
- File content is read and rendered in the viewer

### From Share Sheet
- User selects a `.md` file in any app (email, messaging, file manager)
- User taps "Share" or "Open with"
- Our app appears as an option
- File content is read and rendered in the viewer

### From File Manager (Direct Tap)
- User taps a `.md` file in their device's file manager
- OS recognizes our app handles `.md` files
- File content is read and rendered in the viewer

### Accepted File Types
| Extension | MIME Type | Action |
|---|---|---|
| `.md` | `text/markdown` | Render as markdown |
| `.markdown` | `text/markdown` | Render as markdown |
| `.txt` | `text/plain` | Render as markdown (best effort) |

---

## Feature: Render Markdown

### Supported Syntax (CommonMark + GFM)

| Element | Supported | Notes |
|---|---|---|
| Headings (h1-h6) | Yes | Proper sizing and spacing |
| Bold | Yes | |
| Italic | Yes | |
| Strikethrough | Yes | GFM |
| Inline code | Yes | Monospace with background |
| Code blocks | Yes | With syntax highlighting |
| Blockquotes | Yes | Styled with left border |
| Ordered lists | Yes | Nested supported |
| Unordered lists | Yes | Nested supported |
| Task lists (checkboxes) | Yes | GFM, display-only (not interactive) |
| Tables | Yes | GFM, horizontally scrollable if wide |
| Links | Yes | Tappable, opens in browser |
| Images | Best effort | Remote URLs are blocked offline; unsupported sources show placeholders |
| Horizontal rules | Yes | |
| Line breaks | Yes | |
| HTML | Best effort | Strip tags or render simple HTML |

### Syntax Highlighting
- Code blocks with language annotation (```python, ```js, etc.)
- Support for common languages: Python, JavaScript, TypeScript, Java, Kotlin, Swift, Dart, C, C++, Go, Rust, Ruby, PHP, SQL, HTML, CSS, JSON, YAML, XML, Bash, Markdown
- Graceful fallback for unrecognized languages (render as plain monospace)

### Rendering Quality
- Typography: System font, proper line height, paragraph spacing
- Code blocks: Monospace font, slight background tint, rounded corners
- Tables: Bordered, alternating row colors, horizontally scrollable
- Images: Best effort rendering for supported sources; remote URLs show an offline placeholder
- Links: Distinct color, underlined, tappable

---

## Feature: Theme Support

### Modes
- **System** (default): Follow device light/dark mode setting
- **Light**: Force light theme
- **Dark**: Force dark theme

### Toggle
- Accessible from ViewerScreen AppBar (icon button)
- Cycles: System -> Light -> Dark -> System
- Preference persists across app launches

### Theme Design
- Light: White/off-white background, dark text, subtle code block background
- Dark: Dark gray/black background, light text, darker code block background
- Both: Accent color for links and headings (blue-ish)

---

## Feature: Recent Files

### Behavior
- Home screen shows a list of recently opened files
- Most recent file at the top
- Maximum 20 entries
- Shows: file name, file path (truncated), last opened date
- Tapping a recent file opens it in the viewer
- If file no longer exists at path, show toast and remove from list

### Storage
- Stored in SharedPreferences as JSON
- No external database required
- Cleared if app data is cleared (expected behavior)

---

## Feature: Home Screen

### Layout
- App name/logo at top
- Prominent "Open File" button (Material 3 FilledButton or FAB)
- Recent files list below (if any)
- Empty state illustration/message when no recent files:
  > "Open a Markdown file to get started"
  > "You can also share .md files from other apps"

---

## Feature: Viewer Screen

### Layout
- **AppBar:**
  - Back button (left)
  - File name as title (center, truncated with ellipsis)
  - Theme toggle (right, icon button)
  - Copy markdown button (right, icon button)
- **Body:**
  - Full-width rendered markdown
  - Scrollable (natural platform scroll physics)
  - Padding: 16dp horizontal
- **FAB (conditional):**
  - Scroll-to-top FAB appears after scrolling down
  - Disappears when near top

### Actions
- **Copy markdown:** Copy the rendered file contents to the clipboard
- **Theme toggle:** Switch between light/dark/system

---

## Non-Features (Explicitly Excluded from v1)

| Feature | Reason for exclusion |
|---|---|
| Editing | This is a viewer. Editing is a different app. |
| Cloud sync | No backend. Local files only. |
| User accounts | No server. No accounts. |
| Folders/organization | OS file system handles this. |
| Search within document | v1.x candidate if requested. |
| Table of contents | v1.x candidate if requested. |
| Export to PDF | v1.x candidate if requested. |
| Custom fonts/colors | v1.x candidate if requested. |
| Multiple tabs | Simplicity over features. |
| Bookmarks | v1.x candidate if requested. |
| Annotations | This is a viewer, not an annotation tool. |
| Mermaid diagrams | v1.x candidate if requested. |
| LaTeX math | v1.x candidate if requested. |
| Print | OS-level share-to-print is sufficient. |

---

## Error Handling

| Scenario | User-Facing Message | Action |
|---|---|---|
| File not found | "This file could not be found" | Show "Open Another File" button |
| Permission denied | "Permission needed to read this file" | Show system permission dialog |
| File too large (>10MB) | "This file is very large and may take a moment to load" | Show warning, then load |
| Encoding error | "This file couldn't be read. It may not be a text file." | Show "Open Another File" button |
| Empty file | "This file is empty" | Show "Open Another File" button |
| Invalid markdown | (Never shown - render best effort) | Always attempt to render |
| Remote image URL | Show offline image placeholder | Never fetch over network |

---

## Performance Requirements

| Metric | Target |
|---|---|
| Cold launch to home screen | < 1 second |
| File open to rendered view (< 100KB) | < 500ms |
| File open to rendered view (1MB) | < 2 seconds |
| Scroll performance (60fps) | No dropped frames during scroll |
| App install size (APK) | < 15 MB |
| App install size (IPA) | < 20 MB |
| Memory usage (1MB file loaded) | < 100 MB RAM |

---

## Privacy

- **No analytics.** Zero tracking, zero telemetry.
- **No network calls.** Remote image URLs are intentionally not fetched.
- **No data collection.** No accounts, no server, nothing leaves the device.
- **Recent files list** is stored locally on device only.
- **Privacy policy:** "This app does not collect, store, or transmit any personal data."
