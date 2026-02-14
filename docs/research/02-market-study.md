# Market Study: Mobile Markdown Viewer

> Date: February 2026
> Status: Complete
> Verdict: Niche but real demand; viable as a hobby/portfolio project, not a business

---

## Executive Summary

There is a genuine, unmet need for a simple mobile markdown viewer. The market is niche (estimated 8-20M potential users globally who need mobile markdown viewing), but the capturable audience for a free, no-marketing app is realistically 10K-500K downloads over its lifetime. The app is worth building as a portfolio/open-source project but has no viable commercial path.

---

## 1. Market Size Estimates

### Total Addressable Market (TAM): ~50-80M people

| Segment | Estimated Size | Basis |
|---|---|---|
| Software developers worldwide | ~28-30M | GitHub: 180M+ accounts; ~30M active professionals |
| GitHub active users | ~100M+ | GitHub About page |
| Obsidian users | ~5-6M | r/ObsidianMD: 285K members (3-5% of user base) |
| Notion users | ~30M+ | r/Notion: 443K members; Notion reported 30M+ |
| Other markdown-adjacent users | ~3-5M | Combined communities |
| Students/academics using markdown | ~5-10M | Subset of developers learning to code |
| Technical writers | ~1-2M | Niche professional segment |

### Serviceable Addressable Market (SAM): ~8-20M users

- 15-25% of markdown users have a recurring need to view .md files on mobile
- Stack Overflow 2024: **29.1% of all developers use "Markdown File" as an async collaboration tool** (3rd most popular, ahead of Trello, Notion, and GitHub Discussions)

### Serviceable Obtainable Market (SOM): 10K-500K downloads

- Organic discovery through app store search: ~0.1-1% of SAM
- Year 1: 5K-20K downloads
- Year 2-3: 20K-100K cumulative
- Long tail (5+ years): 200K-500K cumulative

---

## 2. User Segments

### Segment A: Developers Reading Docs on Mobile (5-10M potential)
- **Behavior:** Browse GitHub repos, read READMEs, review PRs on phone
- **Current solution:** GitHub app renders markdown; mostly solved
- **Pain level: LOW** - GitHub/GitLab apps handle this
- **Opportunity: LOW**

### Segment B: Obsidian/Logseq Users Wanting Lightweight Mobile Viewer (500K-1M)
- **Behavior:** Write notes on desktop, want read-only reference on phone
- **Current solution:** Obsidian mobile (free but heavyweight, accidental editing)
- **Pain level: MEDIUM**
- **Key quote:** *"Is there a read only viewer app out there for markdown? Ideally one that can navigate an obsidian directory?"* (r/ObsidianMD)
- **Opportunity: MEDIUM-HIGH**

### Segment C: Non-Technical Users Receiving .md Files (1-3M)
- **Behavior:** Receive .md files via email/messaging; don't know what they are
- **Current solution:** Files open as raw text; users are confused
- **Pain level: HIGH**
- **Key quote:** *"Does anyone know how to open these files on iPhone?"* (r/iphone)
- **Opportunity: HIGH** (but these users don't know to search "markdown viewer")

### Segment D: Students Using Markdown for Notes (500K-2M)
- **Behavior:** Notes in markdown via VS Code/Typora, want to review on phone
- **Current solution:** Cloud sync + existing note apps
- **Pain level: LOW-MEDIUM**
- **Opportunity: LOW**

### Segment E: Technical Writers (100K-500K)
- **Behavior:** Write docs in markdown, need mobile preview
- **Current solution:** Editor preview features; web-based renderers
- **Pain level: LOW**
- **Opportunity: LOW**

### Segment F: Bloggers Writing in Markdown (500K-1M)
- **Behavior:** Draft blog posts in markdown, review on phone
- **Current solution:** CMS preview
- **Pain level: LOW**
- **Opportunity: LOW**

---

## 3. Demand Signals

### Search & Trends
- "markdown editor" has steady, moderate search volume
- "markdown viewer" is significantly lower - people search for editors, not viewers
- The distinction matters: most explicit demand is for **editing**, not viewing

### Reddit Evidence

| Subreddit | Members | Signal |
|---|---|---|
| r/Markdown | 13K | Small but dedicated; posts asking for viewer go unanswered |
| r/ObsidianMD | 285K | Multiple posts explicitly requesting mobile read-only viewer |
| r/PKMS | 63K | Knowledge management enthusiasts interested in lightweight tools |
| r/androidapps | 700K | Infrequent but recurring markdown app requests |
| r/iphone | 2.4M | Posts about "how to open .md files" confirm pain point |

### Stack Overflow 2024 Survey
- **29.1%** of developers use "Markdown File" as an async tool
- **13%** use Obsidian as an async tool
- Markdown is a mainstream part of the developer workflow

---

## 4. How Users Currently Solve This Problem

| Workaround | Platform | Quality | Friction |
|---|---|---|---|
| Open .md in text editor | Both | Poor (raw syntax) | Low friction, bad output |
| Obsidian mobile | Both | Good but heavy (100MB+) | High setup friction |
| GitHub/GitLab mobile app | Both | Good for repo files only | Only repo files |
| Cloud storage preview | Both | Inconsistent (Google Drive = raw text) | Medium |
| iA Writer, Bear | iOS mostly | Good but paid ($5-50) | Payment barrier |
| Convert to PDF first | Both | Works but tedious | High friction |
| Browser via web renderer | Both | Varies | High friction |
| Simple Markdown (Android) | Android | Decent but editor-focused | Medium |
| iOS Files app | iOS | Shows raw text | Terrible |

**No well-known, free, cross-platform, view-only renderer exists that registers as a file handler.**

---

## 5. Distribution Feasibility Without Marketing

### Primary Channel: App Store Optimization (ASO)
- Keywords "markdown viewer," "md file reader," "open md file" have low competition
- Niche is narrow enough to rank #1-3 for these terms
- iOS advantage: .md files have no native handler in Files app, driving searches

### Secondary: GitHub / Open Source Visibility
- Open-sourcing gains visibility through stars, HN/Reddit posts
- Developer communities are receptive to free, open-source tools
- A "Show HN" post could drive initial adoption

### Tertiary: Word of Mouth
- Utility apps spread through "what app do you use for X" discussions
- r/ObsidianMD, r/androidapps, r/iphone communities recommend tools

### Strongest Vector: File Association / Intent Handling
- Android: registering as intent handler for .md means users discover the app when they tap a .md file
- iOS: registering as document handler provides similar discovery
- **The app finds users, not the other way around**

### Comparable Success Stories
- **Termux:** Grew to millions of downloads through community alone
- **Obsidian:** Grew primarily through developer word-of-mouth
- **VLC:** One of the most successful "just works" utility apps

### Realistic Growth Projections
| Timeframe | Downloads |
|---|---|
| Year 1 | 5K-20K |
| Year 2-3 | 20K-100K |
| Long tail (5+ years) | 200K-500K |

**Verdict: Feasible but slow.** Won't go viral, but can find its users organically.

---

## 6. Sustainability Analysis

### Development Cost
- Initial build: 2-4 weeks for a solo developer
- Core tech: markdown parser + file picker + intent handling
- Complexity: Low

### Ongoing Costs

| Item | Annual Cost |
|---|---|
| Apple Developer Program | $99/year |
| Google Play (one-time) | $25 total |
| Hosting (none needed) | $0 |
| CI/CD (GitHub Actions free tier) | $0 |
| **Total** | **~$100/year** |

### Maintenance Effort
- Narrow scope (view-only) = minimal maintenance
- Occasional OS compatibility updates
- Estimated: 2-4 hours per quarter

### Monetization Path
- **None viable.** This is too niche for ads, subscriptions, or premium features.
- Donations (GitHub Sponsors, Buy Me a Coffee) typically generate <$50/month for niche apps.
- Accept this as a portfolio/open-source project, not a revenue source.

---

## 7. Risk Assessment

| Risk | Severity | Detail |
|---|---|---|
| Market too small | **MEDIUM-HIGH** | Capturable market is 100K-500K lifetime. Fine for hobby, not business. |
| Already solved | **MEDIUM** | Partially addressed by Obsidian/Markor but not precisely solved. |
| No real demand | **MEDIUM-LOW** | Reddit evidence confirms real pain. 29.1% dev markdown usage rate. |
| Platform fragmentation cost | **MEDIUM** | Cross-platform framework mitigates this. |
| Platform makes it obsolete | **LOW-MEDIUM** | Apple/Google could add native .md rendering at any time. |
| Maintenance exceeds value | **LOW** | View-only app is technically simple; ~$100/year hard costs. |

---

## 8. Honest Recommendation

### Build it if:
- You want a clean portfolio piece
- You enjoy solving a focused problem
- You want to scratch your own itch
- You value shipping a complete, polished product that helps a small group

### Don't build it if:
- You're looking for user growth, revenue, or scale
- You want a product that will meaningfully impact your career through numbers
- You have limited time and higher-impact projects available

### Sweet spot:
Build it as an **open-source, Android-first** project. Android has weaker existing solutions, allows sideloading (F-Droid), and has a lower barrier ($25 vs $99/year). If it gains traction, expand to iOS. Keep scope ruthlessly narrow.

### Market Viability Score

| As a business | As a portfolio/hobby project |
|---|---|
| **3/10** | **7/10** |
