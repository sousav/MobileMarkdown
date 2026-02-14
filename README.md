# MobileMarkdown

A free, no-ads, cross-platform markdown viewer for Android and iOS. Opens `.md` files and renders them beautifully. That's it.

## The Problem

There is no simple, free, cross-platform app that just opens and renders markdown files on mobile. Every existing option is either an editor, a knowledge management platform, paid, platform-specific, or abandoned. Tapping a `.md` file on your phone either shows raw text or "no app can open this."

## The Solution

MobileMarkdown does for `.md` files what a PDF reader does for PDFs: open them, render them beautifully, and get out of the way.

## Features (v1.0)

- Open `.md` files from file picker, share sheet, or file manager
- Beautiful markdown rendering (CommonMark + GFM)
- Syntax highlighting for code blocks
- Tables, checkboxes, images, links
- Light / Dark / System theme
- Recent files list
- No ads. No accounts. No tracking. No upsells.

## Technical Stack

- **Framework:** Flutter
- **Markdown:** `markdown_widget` (CommonMark + GFM + syntax highlighting)
- **File handling:** `file_picker` + `share_handler`
- **Target size:** < 15 MB

## Documentation

| Document | Description |
|---|---|
| [Competitive Analysis](docs/research/01-competitive-analysis.md) | Exhaustive review of every existing markdown app on mobile |
| [Market Study](docs/research/02-market-study.md) | TAM/SAM/SOM, user segments, demand validation, risk assessment |
| [Stack Decision](docs/technical/01-stack-decision.md) | Comparison of 6 frameworks, decision rationale |
| [Architecture](docs/technical/02-architecture.md) | App architecture, data model, project structure, platform config |
| [Implementation Plan](docs/planning/01-implementation-plan.md) | 15-day phased development roadmap |
| [App Store Strategy](docs/planning/02-app-store-strategy.md) | ASO, organic growth, distribution plan |
| [Feature Spec v1](docs/planning/03-feature-spec-v1.md) | Detailed feature specification with error handling and performance targets |

## Key Findings

**The gap is real.** No free, no-ads, cross-platform, view-only markdown app exists. The closest competitors:

| App | Why it fails for this use case |
|---|---|
| Obsidian | Vault-locked, can't open arbitrary files, complex, heavy |
| Markor | Android-only, editor-first, dated UI |
| Joplin | Database-locked, can't open arbitrary files |
| Simple Markdown | Android-only, editor-first, buggy |
| Bear | Apple-only, subscription |
| iA Writer | No Android, $50/platform |

## Project Status

**Phase: Planning complete. Ready for implementation.**

## License

MIT
