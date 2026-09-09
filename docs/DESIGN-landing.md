---
name: cairn — Public Landing Page
description: A lockfile you read before you run it — an editor/diff register for the GitHub Pages marketing surface at docs/index.html.
colors:
  bg: "#fdfdfb"
  panel: "#ffffff"
  ink: "#1e1e1e"
  ink-soft: "#5b5b52"
  ink-faint: "#75756b"
  border: "#dcdcd3"
  border-soft: "#ece9e1"
  add: "#2f8f49"
  add-bg: "#eaf6ec"
  add-line: "#3fae5c"
  remove: "#b3372f"
  remove-bg: "#fbebe9"
  remove-line: "#d33f3f"
typography:
  hero:
    fontFamily: "var(--sans): -apple-system, BlinkMacSystemFont, Segoe UI, system-ui, sans-serif"
    fontSize: "clamp(28px, 4vw, 38px)"
    fontWeight: 600
    lineHeight: 1.25
    letterSpacing: "-0.015em"
  headline:
    fontFamily: "var(--sans)"
    fontSize: "22px"
    fontWeight: 600
    letterSpacing: "-0.01em"
  lede:
    fontFamily: "var(--sans)"
    fontSize: "17px"
    lineHeight: 1.55
  body:
    fontFamily: "var(--sans)"
    fontSize: "16px"
    lineHeight: 1.55
  mono:
    fontFamily: "var(--mono): 'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, monospace"
    fontSize: "12px–13px"
    fontFeature: "\"calt\" 0, \"liga\" 0 (ligatures disabled)"
rounded:
  xs: "2px"
  sm: "4px"
  md: "6px"
  lg: "8px"
spacing:
  section: "72px 0"
  section-mobile: "52px 0"
  hero-grid-gap: "20px"
  two-col-gap: "32px"
  wrap-max-width: "920px"
  wrap-padding: "0 24px"
components:
  btn-primary:
    backgroundColor: "{colors.add}"
    textColor: "#ffffff"
    rounded: "{rounded.md}"
    padding: "10px 16px"
  btn-primary-hover:
    backgroundColor: "{colors.add-line}"
  btn-secondary:
    backgroundColor: "transparent"
    textColor: "{colors.ink}"
    rounded: "{rounded.md}"
    padding: "10px 16px"
  diff-panel:
    backgroundColor: "{colors.panel}"
    rounded: "{rounded.lg}"
    padding: "0"
  lockfile-card:
    backgroundColor: "{colors.panel}"
    textColor: "{colors.ink}"
    rounded: "{rounded.lg}"
    padding: "18px 20px"
---

# Design System: cairn — Public Landing Page

**Scope of this file.** Governs `docs/index.html` only — cairn's public GitHub Pages landing/overview page. This is a deliberately separate visual world from the token-metering dashboard documented in `docs/DESIGN.md` (React/Tailwind app at `token-metering/frontend/src`, "Clean Minimal SaaS" world: Public Sans + Martian Mono, indigo accent, no-shadow rule). Per `docs/PRODUCT.md`'s explicit instruction, cairn-brand work must never edit the dashboard's components or fold its language into this one, and this file must never be merged into or overwrite `docs/DESIGN.md`'s dashboard record. If a future cairn-brand surface joins this landing page, extend this file; the dashboard's file and world stay untouched.

## Overview

**Creative North Star: "The Lockfile"**

This page's whole premise is that an install is a dependency you read like any other lockfile: exact, versioned, diffable. The build renders that literally — a full-width unified-diff view of a project's `CLAUDE.md` as the hero, resolved-version-style budget numbers beside it, and every "what cairn writes / never writes" claim laid out as a diffed manifest rather than an icon-plus-copy feature grid. Nothing on the page is illustrated or decorated; every visual device (diff coloring, gutter numbers, monospace, a terminal block) is a real artifact of the developer tool it's describing, not a metaphor borrowed from marketing.

The palette is a near-white editor ground with near-black ink, plus the two colors a diff tool already owns: green for additions, red held in strict reserve. A `prefers-color-scheme: dark` palette was added during finish review — not part of the original direction contract, but kept deliberately, since a developer-facing GitHub Pages surface with no dark-mode support is a real regression for a meaningful share of the audience. The dark palette reuses the same green/red semantic roles rather than inventing new meaning.

**Key Characteristics:**
- Near-white ground (`--bg` `#fdfdfb`) and near-black ink (`--ink` `#1e1e1e`), with a full dark-mode counterpart reusing the same semantic roles
- Sans for every heading and every sentence of prose; monospace exclusively for measured, diffed, or path content — never as a "technical" costume
- Diff-green marks what cairn adds; diff-red is reserved exclusively for "never writes" / teardown-removal semantics and appears nowhere else
- Flat, bordered surfaces — no shadows, no gradients, no icon system; the sticky header's `backdrop-filter: blur(6px)` is the page's one blur, functional (nav legibility over scrolling content), not decorative
- File-label chrome (a small mono label, e.g. `budget.lock`, `install`, the `cairn 1.0 → cairn 2.0` diff-tab) appears only as a panel's own title strip, never floating above a heading

## Colors

An editor/diff palette: a near-white/near-black neutral pair carries all prose and structure; two reserved diff colors carry the page's actual argument (what's added, what's permanently excluded).

### Primary
- **Diff Green** (`--add` `#2f8f49`, line accent `--add-line` `#3fae5c`, wash `--add-bg` `#eaf6ec`): marks every "add" line in the hero's `CLAUDE.md` diff and the terminal block's prompt glyphs implicitly via link color; also the page's link color, primary-button fill, focus-ring color, and the `+` sign / capsule values (`≤ 40,000 tokens`, resolved budget numbers) throughout. This is the page's only "go" color.
- **Diff Red** (`--remove` `#b3372f`, line accent `--remove-line` `#d33f3f`, wash `--remove-bg` `#fbebe9`): reserved exclusively for "never writes" / teardown-removal semantics — the hero-adjacent manifest's `−` rows and their `never writes` list. It does not appear anywhere else on the page (confirmed during finish review, where the metrics table's superseded "before" values were deliberately moved off this color onto a muted strikethrough instead, specifically to keep the reservation exclusive).

### Neutral
- **Ground** (`--bg` `#fdfdfb`): the page background.
- **Panel** (`--panel` `#ffffff`): every diff-panel, lockfile-card, and attend-block surface.
- **Ink** (`--ink` `#1e1e1e` light / `#ecece2` dark): primary text, headings, resolved-row values. Both weights hand-verified ≥4.5:1 against their background (WCAG relative luminance; the local automated contrast check runs in degraded mode on this project and could not compute it directly).
- **Ink Soft** (`--ink-soft` `#5b5b52` light / `#a7a79a` dark): secondary text — lede copy, nav links at rest, YAML values.
- **Ink Faint** (`--ink-faint` `#75756b` light / `#8a8a7e` dark): tertiary text — file-labels, table headers, diff gutter numbers, context lines. Also hand-verified ≥4.5:1 on small text in both themes (this value was darkened in both themes during finish review specifically to clear that floor; it measured ~3.3:1 light / ~3.9:1 dark before the fix).
- **Border** (`--border` `#dcdcd3`) / **Border Soft** (`--border-soft` `#ece9e1`): the two hairline weights for panel edges, section dividers, and table rules. Border-soft is reserved for lighter internal dividers (resolved-row separators, section bottom-borders).

### Named Rules
**The Diff-Semantics Rule.** Green means "cairn adds this"; red means "cairn will never write this / removes this on teardown." Neither color is available for any other purpose — not a chart, not a generic emphasis, not a muted or superseded value. A value that needs de-emphasis (the metrics table's superseded "before" numbers) gets a muted strikethrough treatment instead of diff-red, specifically so red's reservation stays exclusive.

## Typography

**Display/Body Font:** system sans stack (`-apple-system, BlinkMacSystemFont, "Segoe UI", system-ui, sans-serif`), used for every heading and every sentence of prose.
**Mono Font:** JetBrains Mono (400/500/600/700, with `ui-monospace, SFMono-Regular, Menlo, monospace` fallback), used exclusively for measured, diffed, or path content.

**Character:** Two faces doing two distinct jobs, split by function rather than by size. There is no separate display face — the hero `h1` is simply the largest instance of the same sans used for a paragraph.

### Hierarchy
- **Hero** (600 weight, `clamp(28px, 4vw, 38px)`, 1.25 line-height, sans): the single `h1`, max-width `20ch`.
- **Headline** (600 weight, 22px, sans, `-0.01em` tracking): every section `h2`. Corrected during finish review from mono to sans — mono is reserved for measured/diffed content, not prose headings; this is now a real, enforced split, not aspirational.
- **Lede** (400 weight, 17px, `--ink-soft`, sans, max-width 62ch): the one-sentence framing under each `h2` and under the hero `h1`.
- **Body** (400 weight, 16px, 1.55 line-height, sans): running prose, footer copy.
- **Mono/UI** (400–700 weight, 12–13px, `--mono`): diff-body lines, table.metrics, the manifest lists, YAML key/value rows, file-labels, the wordmark, buttons, and the version tag. Font-ligatures are explicitly disabled (`font-variant-ligatures: none; font-feature-settings: "calt" 0, "liga" 0`) everywhere this face appears.

### Named Rules
**The Sans/Mono Split Rule.** Sans carries every heading and every sentence of prose; mono carries only what is measured, diffed, or a path/filename. A number, a file path, or a line of diffed content is never set in sans; a heading or a sentence of explanation is never set in mono.

**The No-Ligatures Rule.** Every mono context disables contextual alternates and ligatures. Found live during finish review: JetBrains Mono's ligatures were rendering literal `<!--`/`-->` diff syntax as arrow glyphs, which is wrong for a page whose entire premise is showing exact, verbatim file content.

## Layout

Single centered column, `.wrap` capped at `max-width: 920px` with `24px` side padding. Sections run a fixed vertical rhythm: `72px 0` padding with a `1px` `--border-soft` bottom rule between sections (last section has none). The hero adds `56px` top padding above the standard section rhythm.

Two responsive grid patterns recur: the hero's two-column `1.3fr 1fr` diff-panel + lockfile-cards row (`gap: 20px`), and a `1fr 1fr` two-column pattern for the writes/never-writes manifest (`gap: 32px`). Both collapse to a single column under `760px`. Every child of both grid patterns carries `min-width: 0` — a real, load-bearing rule fixing a genuine overflow bug found during finish review (long diff lines and manifest paths were pushing grid tracks wider than their column, breaking the layout at narrow widths).

Every table (`table.spec`, `table.metrics`) is wrapped in a `.table-scroll` (`overflow-x: auto`) container — also a load-bearing fix from the same review pass, not incidental styling, so a wide table degrades to horizontal scroll instead of forcing page-level horizontal overflow.

At `760px`: section padding drops to `52px 0`, hero top padding drops to `40px`, hero lede bottom margin drops to `24px`, diff-panel bottom margin drops to `20px`, table font-size drops to `12px`, and non-essential top-nav links (everything but the GitHub link) hide. This mobile tightening was a best-effort mitigation made without a genuine sub-500px screenshot in the same review session; it is recorded as mitigated, not fully verified against a live render.

## Elevation & Depth

Flat. There is no shadow vocabulary — no `box-shadow` anywhere in the shipped CSS. Every panel (diff-panel, lockfile-card, attend-block, metric-diff) is a white/`--panel` surface distinguished from the `--bg` ground by a `1px` `--border` only. The one exception is the sticky top header, which uses `backdrop-filter: blur(6px)` over a `color-mix(in srgb, var(--bg) 92%, transparent)` background — a functional effect (keeping the nav legible over scrolling diff content), not decorative glass.

### Named Rules
**The Border-Only Depth Rule.** Every panel is flat at rest, separated from its ground by a single `1px` border, never a shadow. The sticky header's blur is the one authored exception, justified by the specific problem of content scrolling beneath a fixed nav, not extended anywhere else.

## Shapes

Corners run small and consistent: `8px` on every diff-panel, lockfile-card, metric-diff, and attend-block; `6px` on buttons; `4px` on the version-tag pill; `2px` on the focus-ring corner radius. Circles are reserved for the diff-tab's small status dot. Borders are a single hairline weight (`1px`) throughout, in one of two tones (`--border` for structural edges, `--border-soft` for lighter internal dividers like resolved-row and manifest-list separators) — no dashed borders, no border-weight changes to signal state.

## Components

### Buttons
- **Shape:** `rounded-md` (6px), mono label text (13px, 500 weight)
- **Primary:** `--add` background, white text, `10px 16px` padding; hover shifts to `--add-line`.
- **Secondary:** transparent background, `1px` `--border` border, `--ink` text; hover shifts border to `--ink-soft`.

### Diff Panel (signature component)
The page's core recurring device: a bordered, `8px`-radius panel with a `diff-tab` title strip (small dot + mono filename, e.g. `CLAUDE.md`, `terminal`) and a monospace `diff-body` below it. Each `diff-line` carries a numeric or `$`/`+`/`-` gutter and a content cell; `.add` lines get `--add-bg` fill with `--add` text, `.remove` lines get `--remove-bg` fill with `--remove` text, `.ctx` lines stay `--ink-faint`. Used for the hero's `CLAUDE.md` before/after diff and the footer's terminal install block.

### Lockfile Card
A bordered `8px`-radius panel (`18px 20px` padding) whose header is a `file-label` (e.g. `budget.lock // resolved, per feature`, `install`) acting as the card's own title — never a heading kicker. Holds either `resolved-row` key/value pairs (mono, value in `--ink` or capsule `--add`) or a stacked CTA button group.

### Metrics Table
`table.metrics` (mono, 13px) inside a `metric-diff` panel with its own `diff-tab` title. `td.before` renders muted with a strikethrough (`--ink-faint`, `text-decoration: line-through`, decoration color `--border`) rather than diff-red, to keep diff-red's reservation exclusive to never-writes/teardown semantics. `td.after` renders in `--add`, bold.

### Manifest List
`.manifest-list` (mono, 13px): a borderless list where each row carries a `+`/`−` sign (`--add`/`--remove` respectively) and a `path`. Used for the "writes" / "never writes" two-column split — the page's factual proof device, not a decorative icon-plus-text list.

### File-Label (panel-title chrome only)
A small mono, `--ink-faint` label (12px, slight letter-spacing). Its only legitimate placement is as a panel's own title strip directly inside that panel (`budget.lock`, `install`, the `+ writes` / `− never writes` column headers). Corrected during finish review: file-label kickers previously sat above `h1`/`h2` headings project-wide and were removed rather than folded into panel chrome, since the existing diff-tab/manifest chrome already carries the "this is a file" identity without a floating label.

### Navigation
Sticky top bar (`position: sticky; top: 0`), translucent-blurred background, bottom `1px` border. Mono wordmark (`~/ cairn`, 17px, 700 weight) at left; sans nav links (13px, `--ink-soft`, hover to `--ink`) plus a mono version-tag pill at right. Below `760px`, all links but the GitHub link and the version tag hide.

## Do's and Don'ts

### Do:
- **Do** keep diff-green (`--add`/`--add-line`/`--add-bg`) as the page's only "go" color — links, primary buttons, focus rings, and additive diff/manifest rows.
- **Do** keep diff-red (`--remove`/`--remove-line`/`--remove-bg`) exclusive to "never writes" / teardown-removal semantics; de-emphasize superseded values with a muted strikethrough instead.
- **Do** set every heading and every sentence of prose in sans; set every measured value, diffed line, or path in mono.
- **Do** disable font-ligatures (`font-variant-ligatures: none`, `"calt" 0, "liga" 0`) on every mono context.
- **Do** wrap every table in `.table-scroll` and give every grid/flex two-column child `min-width: 0`.
- **Do** place a file-style mono label only as a panel's own title strip (diff-tab, lockfile-card header), never floating above an `h1`/`h2`.

### Don't:
- **Don't** put a kicker or eyebrow label above a heading — the heading (plus existing diff-tab/manifest chrome) carries the "file" identity on its own.
- **Don't** set an `h1`/`h2` in mono; mono is reserved for measured/diffed/path content, not prose headings.
- **Don't** add `box-shadow` or hard-offset block shadows anywhere — this is a bordered, flat editor world, not a neobrutalist one.
- **Don't** extend diff-red beyond "never writes"/teardown semantics into a general de-emphasis or muted-value color.
- **Don't** re-introduce ligatures on any mono/code context; JetBrains Mono's contextual alternates render literal diff syntax (`<!--`, `-->`) as arrow glyphs, which misrepresents verbatim file content.
