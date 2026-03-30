# App Store Strategy (ASO & Organic Growth)

> Date: February 2026
> Budget: $0 marketing spend
> Strategy: Pure organic discovery via ASO and file association

---

## 1. App Store Optimization (ASO)

### App Name
**Primary:** "MobileMarkdown"
**Rationale:** Keep one consistent brand across Android, iOS, GitHub, store copy, and in-app UI. Use subtitle and keyword fields to capture exact-match search intent instead of fragmenting the product name.

**Store-facing support copy:**
- Subtitle / promo text: "Markdown Viewer for .md Files"
- Keyword focus: markdown viewer, md viewer, markdown reader, open md file

**Alternatives considered:**
- "Markdown Viewer" - stronger keyword match, but weaker long-term branding
- "MD Viewer" - short, but generic
- "Simple Markdown Viewer" - descriptive, but too long for some store displays

### Keywords (Apple App Store)

Primary (high intent, low competition):
```
markdown viewer, md viewer, markdown reader, md reader,
open md file, markdown file viewer, view markdown
```

Secondary (broader reach):
```
markdown, md file, text viewer, document viewer,
readme viewer, code viewer, markup viewer
```

### Description Strategy

**Short description (80 chars):**
> Open and view markdown (.md) files with beautiful formatting.

**Full description structure:**
1. One-line value proposition
2. What it does (5 bullet points)
3. What it does NOT do (sets expectations)
4. Supported markdown features list
5. Privacy statement (no data collection)

### Screenshots
- Screenshot 1: A beautifully rendered README with headings, lists, and code blocks
- Screenshot 2: Dark mode rendering
- Screenshot 3: Share sheet showing the app as a .md opener
- Screenshot 4: File picker opening a .md file
- Screenshot 5: A complex document with tables, images, and checkboxes

### Category
- **Primary:** Utilities (both stores)
- **Secondary:** Productivity (both stores)

---

## 2. File Association as Growth Engine

The strongest organic growth vector is file type registration:

### How it works:
1. User installs the app (from any source)
2. Next time they tap a `.md` file anywhere on their phone, the OS offers our app
3. On Android: shows in "Open with" dialog for `.md` files
4. On iOS: shows in "Open in" menu for `.md` files

### Why this matters:
- The app passively acquires usage whenever the user encounters a .md file
- No marketing needed - the OS promotes the app at the exact moment of need
- Creates a "set it and forget it" default handler relationship

---

## 3. Open Source as Marketing

### GitHub Repository Strategy
- MIT license (maximum adoption)
- Clean README with screenshots and feature list
- Contributing guidelines (welcome PRs)
- Issue templates for bug reports and feature requests
- Clear roadmap in repository

### Community Seeding (one-time, low effort)
- Post to r/Markdown: "I built a free, no-ads markdown viewer for Android + iOS"
- Post to r/androidapps and r/iOSApps: announcement with screenshots
- Post to r/ObsidianMD: "Lightweight read-only viewer for your vault on mobile"
- Submit to Hacker News as "Show HN"
- Submit to Product Hunt (free)
- Add to AlternativeTo as alternative to markdown editors

### F-Droid Distribution (Android)
- Submit to F-Droid for open-source app distribution
- Reaches users who specifically seek FOSS apps
- Additional discovery channel at zero cost

---

## 4. Review Strategy

### Prompting for Reviews
- Never show a review prompt on first launch
- After 5th file opened successfully, show a **non-intrusive** review prompt
- Use the platform-native review dialog (in-app review API)
- Never show again after dismissal (no nagging)
- Never gate features behind reviews

### Responding to Reviews
- Respond to all 1-3 star reviews within 48 hours
- Thank users for feature suggestions
- Direct bug reports to GitHub issues

---

## 5. Metrics to Track (Without Analytics SDK)

Since the app collects no analytics, track success through:

| Metric | Source | Target (Year 1) |
|---|---|---|
| Downloads | Play Console / App Store Connect | 5K-20K |
| Store rating | Store dashboards | 4.5+ |
| Review count | Store dashboards | 100+ |
| Crash-free rate | Play Console / Xcode | 99.5%+ |
| GitHub stars | GitHub | 100+ |
| GitHub issues (feature requests) | GitHub | Signal of engagement |

---

## 6. What We Explicitly Do NOT Do

| Activity | Why not |
|---|---|
| Paid ads | Zero budget, not justified for niche |
| Social media accounts | Maintenance burden for near-zero return |
| Blog / content marketing | Time better spent on product |
| Influencer outreach | Product is too niche |
| Cross-promotion | No other products to cross-promote |
| Email collection | No need, no backend |
| Push notifications | Nothing to notify about |
| A/B testing | User base too small for statistical significance |
